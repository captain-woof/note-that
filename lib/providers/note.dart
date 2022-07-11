import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  late final int id;
  late final String title;
  late final String body;

  Note({required this.id, required this.title, required this.body});

  Note.fromMap({required Map<String, dynamic> noteData}) {
    id = noteData["id"];
    title = noteData["title"];
    body = noteData["body"];
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "title": title, "body": body};
  }
}

class NoteProvider extends ChangeNotifier {
  static const _tableName = "notes";
  static const _databaseFileName = "note_that.db";

  Database? _db;
  bool ready = false;
  List<Note> notesStored = [];

  NoteProvider();

  Future<void> initDatabase() async {
    await openDatabase(_databaseFileName, version: 1,
        onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY, title TEXT, body TEXT)");
      _db = db;
      notifyListeners();
    }, onOpen: (db) async {
      ready = true;
      _db = db;
      notesStored = await getNotes(null);
      notifyListeners();
    });
  }

  Future<void> closeDatabase() async {
    await _db!.close();
  }

  Database? getDatabase() => _db;

  Future<List<Note>> getNotes(String? searchTerm) async {
    List<Note> notes = [];

    if (_db != null) {
      List<Map<String, dynamic>> notesMap;

      if (searchTerm != null) {
        notesMap = await _db!.query("notes",
            where: "title LIKE %?% OR body LIKE %?%",
            whereArgs: [searchTerm, searchTerm]);
      } else {
        notesMap = await _db!.query("notes");
      }

      var notesMapIterator =
          notesMap.map((noteData) => Note.fromMap(noteData: noteData));
      notes = [...notesMapIterator];
    }

    return notes;
  }

  Future<void> addNote({required Note noteNew}) async {
    if (_db != null) {
      await _db!.insert(_tableName, noteNew.toMap());
      notesStored = await getNotes(null);
      notifyListeners();
    }
  }

  Future<void> deleteNote({required Note noteToDelete}) async {
    if (_db != null) {
      await _db!
          .delete(_tableName, where: "id = ?", whereArgs: [noteToDelete.id]);
      notesStored = await getNotes(null);
      notifyListeners();
    }
  }

  Future<void> updateNote({required Note noteUpdated}) async {
    if (_db != null) {
      await _db!.update(_tableName, noteUpdated.toMap(),
          where: "id = ?", whereArgs: [noteUpdated.id]);
      notesStored = await getNotes(null);
      notifyListeners();
    }
  }
}
