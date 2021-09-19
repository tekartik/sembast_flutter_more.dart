// ignore_for_file: avoid_print

import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import 'package:tekartik_notepad_sembast_app/app.dart';
import 'package:tekartik_notepad_sembast_app/model/model.dart';
import 'package:tekartik_notepad_sembast_app/provider/note_provider.dart';

import 'import.dart';

var autoStart = false;
// var autoStart = devWarning(true);
// var autoFiltering = '28';

class Task {
  late final Stress stress;
  var running = true;

  Future<void> run() async {
    print('no action');
  }

  Task(this.stress) {
    stress.subject.firstWhere((element) => !element.running).then((_) {
      dispose();
    });
    // Auto shutdown after 30mn
    sleep(30 * 60 * 1000).then((_) {
      dispose();
    });
  }

  void dispose() {
    if (running) {
      print('disposing task');
    }
    running = false;
  }

  Future start() async {
    await run();
  }
}

class CreateTask extends Task {
  CreateTask(Stress stress) : super(stress);

  @override
  Future<void> run() async {
    var i = 0;
    while (running) {
      i++;
      print('adding note $i');
      var title = lorem(paragraphs: 1, words: 4);
      var content = lorem(paragraphs: 2, words: 60);

      await noteProvider.saveNote(DbNote()
        //..id.v = _noteId
        ..title.v = '$title $i'
        ..content.v = content
        ..date.v = DateTime.now().millisecondsSinceEpoch);
      await sleep(300);
    }
  }
}

class RemoveOldTask extends Task {
  RemoveOldTask(Stress stress) : super(stress);

  @override
  Future<void> run() async {
    while (running) {
      var count = await noteProvider.notesStore.count(await noteProvider.ready);
      print(count);
      var maxCount = 10000;
      if (count > maxCount) {
        var result = await noteProvider.notesStore.delete(
            await noteProvider.ready,
            finder: Finder(
                sortOrders: [SortOrder('date', true)],
                limit: count - maxCount));
        print('deleted: $result');
      }
      await sleep(5000);
    }
  }
}

class StressState {
  final bool running;
  final bool filtering;

  StressState({required this.running, required this.filtering});
}

class Stress {
  final subject = BehaviorSubject<StressState>.seeded(
      StressState(running: false, filtering: false));

  bool get isRunning => subject.value.running;

  bool get isFiltering => subject.value.filtering;
  Task? task;
  final _lock = Lock();

  String get filterText => 'ater';

  Future<void> _listener(bool running) async {
    print('Running $running');
    if (running && !_lock.locked) {
      await _lock.synchronized(() async {
        print('_locked Running $isRunning');
        if (isRunning) {
          var futures = [CreateTask(this).start(), RemoveOldTask(this).start()];
          await Future.wait(futures);
        }
      });
    }
  }

  Future<void> run() async {}

  Stress() {
    subject.listen((state) {
      _listener(state.running);
    });
    if (autoStart) {
      subject.add(StressState(running: true, filtering: false));
    }
  }

  void toggle() {
    subject.add(StressState(running: !isRunning, filtering: isFiltering));
  }

  void toggleFiltering() {
    subject.add(StressState(running: isRunning, filtering: !isFiltering));
  }

  bool _contains(String? content, String value) {
    return content?.toLowerCase().contains(value) ?? false;
  }

  Stream<List<DbNote>> onNotes() {
    if (noteProvider.db == null || !isFiltering) {
      return noteProvider.onNotes();
    } else {
      return noteProvider.notesStore
          .query(
              finder: Finder(
                  sortOrders: [SortOrder('date', false)],
                  filter: Filter.custom((record) =>
                      _contains(snapshotToNote(record).content.v, filterText) ||
                      _contains(snapshotToNote(record).content.v, filterText))))
          .onSnapshots(noteProvider.db!)
          .transform(noteProvider.notesTransformer);
    }
  }
}
