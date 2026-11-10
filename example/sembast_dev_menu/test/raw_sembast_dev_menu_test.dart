@TestOn('vm')
library;

import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

/// Runs the raw menu (lib/src/raw_sembast_dev_menu.dart, its database in
/// `.local/raw_sembast_dev_menu/test.db`) in [dir] with the [commands]
/// typed, returns its output lines.
Future<List<String>> _runRawMenu(String dir, String commands) async {
  var script = absolute('lib', 'src', 'raw_sembast_dev_menu.dart');
  var shell = Shell(workingDirectory: dir, verbose: false);
  var result = await shell.run('dart run ${shellArgument(script)} $commands');
  return result.outLines.toList();
}

/// A record listed by 'list item' (`<key>: {...}`).
final _listedRecord = RegExp(r'\d+: \{');

void main() {
  group('raw menu', () {
    late Directory dir;
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('raw_sembast_dev_menu');
    });
    tearDown(() async {
      await dir.delete(recursive: true);
    });

    test('delete db deletes the menu database only', () async {
      var other = File(join(dir.path, 'test.db'));
      await other.writeAsString('not the menu database');
      // add item, delete db, list item, exit.
      var lines = await _runRawMenu(dir.path, '4 0 7 .');
      expect(lines.where(_listedRecord.hasMatch), isEmpty, reason: '$lines');
      expect(other.existsSync(), isTrue);
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('clear item deletes the records', () async {
      // add item, clear item, list item, exit.
      var lines = await _runRawMenu(dir.path, '4 3 7 .');
      expect(lines.where(_listedRecord.hasMatch), isEmpty, reason: '$lines');
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
