import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_notepad_sembast_app/model/model.dart';
import 'package:tekartik_notepad_sembast_app/page/edit_page.dart';
import 'package:tekartik_notepad_sembast_app/page/note_page.dart';
import 'package:tekartik_notepad_stress_app/app.dart';
import 'package:tekartik_notepad_stress_app/src/stress.dart';

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_statements
    stress;
    return ValueStreamBuilder<StressState>(
      stream: stress.subject,
      builder: (context, snapshot) {
        var running = snapshot.data?.running ?? false;
        var filtering = snapshot.data?.filtering ?? false;
        return Scaffold(
          appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(running ? Icons.pause : Icons.play_arrow),
                  tooltip: 'Running',
                  onPressed: () {
                    stress.toggle();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Running: ${stress.isRunning}')));
                  },
                ),
                IconButton(
                  icon: Icon(filtering ? Icons.pause : Icons.play_arrow),
                  tooltip: 'Filtering',
                  onPressed: () {
                    stress.toggleFiltering();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Filtering: ${stress.isFiltering}')));
                  },
                ),
              ],
              title: Text(
                'NotePad stress',
              )),
          body: StreamBuilder<List<DbNote>>(
            stream: stress.onNotes(),
            builder: (context, snapshot) {
              var notes = snapshot.data;
              if (notes == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    var note = notes[index];
                    return ListTile(
                      title: Text(note.title.v ?? ''),
                      subtitle: note.content.v?.isNotEmpty ?? false
                          ? Text(LineSplitter.split(note.content.v!).first)
                          : null,
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return NotePage(
                            noteId: note.id.v!,
                          );
                        }));
                      },
                    );
                  });
            },
          ),
          bottomNavigationBar: BottomAppBar(
            child: ListTile(
                dense: true,
                title: StreamBuilder<List<DbNote>>(
                    stream: stress.onNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var count = snapshot.data!.length;
                        return Text('count $count');
                      }
                      return Text('counting...');
                    })),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return EditNotePage(
                  initialNote: null,
                );
              }));
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
