import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class NoteService {
  NoteService._();

  static final NoteService instance = NoteService._();
  static const String _notesKey = 'notes_json';

  Future<List<Note>> getNotes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawNotes = prefs.getString(_notesKey);

    if (rawNotes == null || rawNotes.isEmpty) {
      return <Note>[];
    }

    final List<dynamic> decoded = jsonDecode(rawNotes) as List<dynamic>;
    return decoded
        .map((dynamic item) => Note.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      notes.map((Note note) => note.toJson()).toList(),
    );
    await prefs.setString(_notesKey, encoded);
  }

  Future<void> addNote(Note note) async {
    final List<Note> notes = await getNotes();
    notes.add(note);
    await saveNotes(notes);
  }

  Future<void> updateNote(Note updatedNote) async {
    final List<Note> notes = await getNotes();
    final int index = notes.indexWhere((Note note) => note.id == updatedNote.id);

    if (index == -1) {
      return;
    }

    notes[index] = updatedNote;
    await saveNotes(notes);
  }

  Future<void> deleteNote(String noteId) async {
    final List<Note> notes = await getNotes();
    notes.removeWhere((Note note) => note.id == noteId);
    await saveNotes(notes);
  }

  Future<Note?> toggleFavorite(String noteId) async {
    final List<Note> notes = await getNotes();
    final int index = notes.indexWhere((Note note) => note.id == noteId);

    if (index == -1) {
      return null;
    }

    final Note updatedNote = notes[index].copyWith(
      isFavorite: !notes[index].isFavorite,
    );
    notes[index] = updatedNote;
    await saveNotes(notes);
    return updatedNote;
  }
}
