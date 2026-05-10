import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'about_screen.dart';
import 'add_edit_note_screen.dart';
import 'detail_note_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final Future<void> Function(bool value) onThemeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> categoryFilters = <String>[
    'Semua',
    'Pribadi',
    'Kuliah',
    'Kerja',
    'Ide',
    'Penting',
    'Favorit',
  ];

  final TextEditingController _searchController = TextEditingController();

  List<Note> _allNotes = <Note>[];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  String _selectedSort = 'Terbaru';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    final List<Note> notes = await NoteService.instance.getNotes();
    if (!mounted) {
      return;
    }

    setState(() {
      _allNotes = notes;
      _isLoading = false;
    });
  }

  List<Note> get _filteredNotes {
    List<Note> notes = List<Note>.from(_allNotes);

    if (_selectedFilter == 'Favorit') {
      notes = notes.where((Note note) => note.isFavorite).toList();
    } else if (_selectedFilter != 'Semua') {
      notes = notes
          .where((Note note) => note.category == _selectedFilter)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      notes = notes.where((Note note) {
        return note.title.toLowerCase().contains(_searchQuery) ||
            note.content.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    switch (_selectedSort) {
      case 'Terlama':
        notes.sort((Note a, Note b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Judul A-Z':
        notes.sort(
          (Note a, Note b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case 'Judul Z-A':
        notes.sort(
          (Note a, Note b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case 'Terbaru':
      default:
        notes.sort((Note a, Note b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return notes;
  }

  Future<void> _openAddNote() async {
    final bool? didChange = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const AddEditNoteScreen(),
      ),
    );

    if (didChange == true) {
      await _loadNotes();
    }
  }

  Future<void> _openDetail(Note note) async {
    final bool? didChange = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => DetailNoteScreen(note: note),
      ),
    );

    if (didChange == true) {
      await _loadNotes();
    }
  }

  Future<void> _openSettings() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SettingsScreen(
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _handleMenuSelection(String value) async {
    if (value == 'settings') {
      await _openSettings();
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AboutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Note> notes = _filteredNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Harian'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Pengaturan'),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Text('Tentang Aplikasi'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddNote,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadNotes,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: <Widget>[
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari judul atau isi catatan',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Hapus pencarian',
                                onPressed: () => _searchController.clear(),
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categoryFilters.map((String filter) {
                        final bool isSelected = _selectedFilter == filter;
                        return ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSort,
                      decoration: const InputDecoration(
                        labelText: 'Urutkan',
                        prefixIcon: Icon(Icons.sort_rounded),
                      ),
                      items: const <String>[
                        'Terbaru',
                        'Terlama',
                        'Judul A-Z',
                        'Judul Z-A',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedSort = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_allNotes.isEmpty)
                      const SizedBox(
                        height: 360,
                        child: EmptyState(
                          title: 'Belum ada catatan',
                          subtitle:
                              'Tekan tombol + untuk membuat catatan pertama',
                        ),
                      )
                    else if (notes.isEmpty)
                      const SizedBox(
                        height: 360,
                        child: EmptyState(
                          title: 'Catatan tidak ditemukan',
                          subtitle:
                              'Coba ubah kata kunci pencarian atau filter kategori.',
                          icon: Icons.search_off_rounded,
                        ),
                      )
                    else
                      ...notes.map(
                        (Note note) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NoteCard(
                            note: note,
                            onTap: () => _openDetail(note),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
