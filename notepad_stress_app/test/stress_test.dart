import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:tekartik_notepad_sembast_app/app.dart';
import 'package:tekartik_notepad_sembast_app/model/model.dart';
import 'package:tekartik_notepad_sembast_app/provider/note_provider.dart';
import 'package:tekartik_notepad_stress_app/src/stress.dart';

/// A stress without its print traces (one per created note).
Stress newSilentStress() => runZoned(
  Stress.new,
  zoneSpecification: ZoneSpecification(print: (_, _, _, _) {}),
);

Future<int> noteCount() async =>
    noteProvider.notesStore.count(await noteProvider.ready);

void main() {
  setUp(() async {
    noteProvider = DbNoteProvider(newDatabaseFactoryMemory());
    await noteProvider.ready;
    // Start from no note (the provider adds 2 welcome notes).
    await noteProvider.clearAllNotes();
  });
  tearDown(() async {
    await noteProvider.db!.close();
  });

  test('filtering matches the title or the content', () async {
    Future<void> add(String title, String content, int date) =>
        noteProvider.saveNote(
          DbNote()
            ..title.v = title
            ..content.v = content
            ..date.v = date,
        );
    await add('Water', 'none', 1);
    await add('none', 'later', 2);
    await add('none', 'none', 3);
    var stress = newSilentStress()..toggleFiltering();
    var notes = await stress.onNotes().first;
    expect(notes.map((note) => note.date.v), [2, 1]);
  });

  test('start again while the previous run ends', () async {
    var stress = newSilentStress();
    stress.toggle();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(await noteCount(), greaterThan(0));
    // Stop and start right away: the previous run still holds its lock
    // (its remove task sleeps 5 seconds between checks).
    stress.toggle();
    stress.toggle();
    expect(stress.isRunning, isTrue);
    await Future<void>.delayed(const Duration(seconds: 6));
    var count = await noteCount();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(await noteCount(), greaterThan(count), reason: 'notes created');
    stress.toggle();
    // The tasks see the stop at their next step.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }, timeout: const Timeout(Duration(seconds: 30)));
}
