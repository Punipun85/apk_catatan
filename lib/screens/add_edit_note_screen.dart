import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  const AddEditNoteScreen({super.key, this.note});

  final Note? note;

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  static const List<String> categories = <String>[
    'Pribadi',
    'Kuliah',
    'Kerja',
    'Ide',
    'Penting',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _selectedCategory;

  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCategory = widget.note?.category ?? categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    final Note? note = widget.note;
    if (note == null) {
      return _titleController.text.trim().isNotEmpty ||
          _contentController.text.trim().isNotEmpty ||
          _selectedCategory != categories.first;
    }

    return _titleController.text.trim() != note.title ||
        _contentController.text.trim() != note.content ||
        _selectedCategory != note.category;
  }

  Future<bool> _handleBackNavigation() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final bool? shouldLeave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar tanpa menyimpan?'),
          content: const Text('Perubahan yang kamu buat akan hilang.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    return shouldLeave ?? false;
  }

  Future<void> _saveNote() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final DateTime now = DateTime.now();

    if (_isEditing) {
      final Note updatedNote = widget.note!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        updatedAt: now,
      );
      await NoteService.instance.updateNote(updatedNote);
    } else {
      final Note newNote = Note(
        id: now.microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        isFavorite: false,
        createdAt: now,
      );
      await NoteService.instance.addNote(newNote);
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Catatan berhasil diperbarui'
              : 'Catatan berhasil ditambahkan',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        final bool shouldLeave = await _handleBackNavigation();
        if (context.mounted && shouldLeave) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Catatan' : 'Tambah Catatan'),
          actions: <Widget>[
            TextButton(
              onPressed: _saveNote,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Judul catatan',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (String? value) {
                    final String text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Judul wajib diisi';
                    }
                    if (text.length < 3) {
                      return 'Judul minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  minLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Isi catatan',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 92),
                      child: Icon(Icons.notes_rounded),
                    ),
                  ),
                  validator: (String? value) {
                    final String text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Isi wajib diisi';
                    }
                    if (text.length < 5) {
                      return 'Isi minimal 5 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  items: categories
                      .map(
                        (String category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
