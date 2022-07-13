import 'package:flutter/foundation.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:sqflite/sqflite.dart';
import "dart:convert" as convert;

class NotesStore extends ChangeNotifier {
  static const _tableName = "notes";
  static const _databaseFileName = "note_that.db";

  Database? _db;
  bool ready = false;
  List<NoteData> _notesStored = [];

  NotesStore();

  Future<void> initDatabase() async {
    await openDatabase(_databaseFileName, version: 1,
        onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY, body_serialized TEXT)");
      _db = db;
      notifyListeners();
    }, onOpen: (db) async {
      ready = true;
      _db = db;
      updateAllNotesStored();
    });
  }

  Future<void> closeDatabase() async {
    await _db!.close();
  }

  Database? getDatabase() => _db;

  Future<void> updateAllNotesStored() async {
    if (_db != null) {
      List<Map<String, dynamic>> notesMap = await _db!.query(_tableName);
      List<NoteData> notes = [];

      for (var noteDataFromDb in notesMap) {
        NoteData noteStored = NoteData.fromSerialized(
            id: noteDataFromDb["id"],
            serializedData: convert
                .jsonDecode(noteDataFromDb["body_serialized"])
                .cast<String>());
        notes.add(noteStored);
      }

      _notesStored = notes;
      notifyListeners();
    }
  }

  List<NoteData> getNotes(String? searchTerm) {
    if (searchTerm == null || searchTerm == "") {
      return _notesStored;
    } else {
      return (_notesStored.where((noteStored) {
        for (var individualBodyData in noteStored.getBodyData()) {
          if (individualBodyData.search(searchTerm)) {
            return true;
          }
        }
        return false;
      })).toList();
    }
  }

  int getNewNoteId() => _notesStored.length;

  Future<void> addNote({required NoteData noteNew}) async {
    if (_db != null) {
      await _db!.insert(_tableName,
          {"id": _notesStored.length, "body_serialized": noteNew.serialize()});
      updateAllNotesStored();
    }
  }

  Future<void> deleteNote({required NoteData noteToDelete}) async {
    if (_db != null) {
      await _db!.delete(_tableName,
          where: "id = ?", whereArgs: [noteToDelete.getId()]);
      updateAllNotesStored();
    }
  }

  Future<void> updateNote({required NoteData noteUpdated}) async {
    if (_db != null) {
      await _db!.update(
          _tableName,
          {
            "id": noteUpdated.getId(),
            "body_serialized": noteUpdated.serialize()
          },
          where: "id = ?",
          whereArgs: [noteUpdated.getId()]);
      updateAllNotesStored();
    }
  }
}
