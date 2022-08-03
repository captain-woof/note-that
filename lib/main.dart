import 'package:flutter/material.dart';
import 'package:note_that/pages/home/home.dart';
import 'package:note_that/pages/noteEditor/noteEditor.dart';
import 'package:note_that/pages/webView/webView.dart';
import 'package:note_that/stores/notesStore.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/theme/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Run the Flutter app
  runApp(const NoteThat());
}

class NoteThat extends StatelessWidget {
  const NoteThat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NotesStore>(create: (context) {
          // Providing NotesStore
          NotesStore notesStore = NotesStore();
          notesStore.initDatabase();
          return notesStore;
        }),
        ChangeNotifierProvider<NoteData>(
            create: (context) => NoteData.blank()), // Providing SelectedNote
      ],
      child: MaterialApp(
        title: "NoteThat",
        theme: ThemeCustom.getThemeData(),
        routes: {
          "/": (context) => const HomePage(),
          "/note_editor": (context) => const NoteEditor(),
          "/web_view": (context) => const WebView()
        },
      ),
    );
  }
}
