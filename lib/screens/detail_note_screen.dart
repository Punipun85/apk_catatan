import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';
import '../services/note_service.dart';
import 'add_edit_note_screen.dart';

class DetailNoteScreen extends StatefulWidget {
  const DetailNoteScreen({super.key, required this.note});

  final Note note;

  @override
  State<DetailNoteScreen> createState() => _DetailNoteScreenState();
}

class _DetailNoteScreenState extends State<DetailNoteScreen> {
  late Note _note;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(date);
  }

  Future<void> _toggleFavorite() async {
    final Note? updatedNote = await NoteService.instance.toggleFavorite(_note.id);
    if (updatedNote == null || !mounted) {
      return;
    }

    setState(() {
      _note = updatedNote;
      _hasChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedNote.isFavorite
              ? 'Catatan ditambahkan ke favorit'
              : 'Catatan dihapus dari favorit',
        ),
      ),
    );
  }

  Future<void> _editNote() async {
    final bool? didChange = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => AddEditNoteScreen(note: _note),
      ),
    );

    if (!mounted) {
      return;
    }

    if (didChange == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteNote() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Catatan?'),
          content: const Text(
            'Apakah kamu yakin ingin menghapus catatan ini?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await NoteService.instance.deleteNote(_note.id);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil dihapus')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }

        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context, _hasChanges),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Detail Catatan'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Favorit',
              onPressed: _toggleFavorite,
              icon: Icon(
                _note.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: _note.isFavorite ? Colors.amber : null,
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: _editNote,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              tooltip: 'Hapus',
              onPressed: _deleteNote,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _note.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _MetaChip(
                          icon: Icons.category_rounded,
                          label: _note.category,
                        ),
                        _MetaChip(
                          icon: Icons.star_rounded,
                          label: _note.isFavorite ? 'Favorit' : 'Bukan favorit',
                          color: _note.isFavorite ? Colors.amber : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _note.content,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Tanggal dibuat',
                      value: _formatDate(_note.createdAt),
                    ),
                    _InfoRow(
                      label: 'Terakhir diedit',
                      value: _note.updatedAt == null
                          ? '-'
                          : _formatDate(_note.updatedAt!),
                    ),
                    _InfoRow(
                      label: 'Status favorit',
                      value: _note.isFavorite ? 'Aktif' : 'Tidak aktif',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color chipColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: chipColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
