import 'package:flutter/material.dart';
import 'package:sembast_flutter_example/main.dart';
import 'package:sembast_flutter_example/model/model.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class NotePage extends StatefulWidget {
  final int noteId;

  const NotePage({Key key, @required this.noteId}) : super(key: key);
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Note',
      )),
      body: StreamBuilder<DbNote>(
        stream: noteProvider.onNote(widget.noteId),
        builder: (context, snapshot) {
          var note = snapshot.data;
          if (note == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(children: <Widget>[
            ListTile(
                title: Text(
              note.title.v,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            ListTile(title: Text(note.content.v ?? ''))
          ]);
        },
      ),
    );
  }
}
