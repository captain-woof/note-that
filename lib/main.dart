import 'package:flutter/material.dart';
import 'package:note_that/pages/home.dart';
import 'package:note_that/pages/noteEditor.dart';
import 'package:note_that/providers/note.dart';
import 'package:note_that/theme/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const NoteThat());
}

class NoteThat extends StatelessWidget {
  const NoteThat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NoteProvider>(create: (context) {
          NoteProvider noteProvider = NoteProvider();
          noteProvider.initDatabase();
          return noteProvider;
        })
      ],
      child: MaterialApp(
        title: "NoteThat",
        theme: ThemeCustom.getThemeData(),
        routes: {
          "/": (context) => const HomePage(),
          "/note_editor": (context) => const NoteEditor()
        },
      ),
    );
  }
}
