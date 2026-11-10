# tekartik_notepad_stress_app

Stress test of sembast in a Flutter app: the notepad of
[notepad_sembast](https://github.com/alextekartik/flutter_app_example/tree/master/notepad_sembast)
(same database, note and edit pages) with a list page that keeps showing the
notes while they are written.

* Play (first app bar button): a task adds notes as fast as it can, another
  one keeps the 10000 most recent notes (checked every 5 seconds). Pause
  stops both (a play right after waits for them to end).
* Filter (second button): the list only shows the notes whose title or
  content contains `ater` (a `Filter.custom` query listened with
  `onSnapshots`).
* The bottom bar counts the notes.

## Run

The platform folders are not committed: create the ones you need first.

```sh
flutter create --platforms=android,linux,web .
flutter run   # -d linux, -d chrome, a device...
```

`flutter test` runs `test/stress_test.dart` (filter, play after a quick
pause) on an in memory database.
