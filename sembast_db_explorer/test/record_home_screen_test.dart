import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sembast/sembast.dart' hide Finder;
import 'package:sembast/sembast_memory.dart' show newDatabaseFactoryMemory;
import 'package:sembast_db_explorer/src/data/db_data.dart';
import 'package:sembast_db_explorer/src/screen/record_home_screen.dart';

void main() {
  late Database db;
  var store = StoreRef<int, Object>('store');

  /// Pumps until [finder] finds a widget, giving the database real time.
  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  Future<void> pumpRecordScreen(WidgetTester tester, int key) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecordHomeScreen(
          data: RecordData(StoreData(DbData(db), store), store.record(key)),
        ),
      ),
    );
  }

  setUp(() async {
    db = await newDatabaseFactoryMemory().openDatabase('record_home.db');
  });
  tearDown(() async {
    await db.close();
  });

  testWidgets('missing record shows not found', (tester) async {
    await pumpRecordScreen(tester, 1);
    await pumpUntilFound(tester, find.text('Not found'));
    expect(find.text('Not found'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('record value is shown scrollable', (tester) async {
    await tester.runAsync(() => store.record(1).put(db, {'name': 'test'}));
    await pumpRecordScreen(tester, 1);
    var value = find.textContaining('"name": "test"');
    await pumpUntilFound(tester, value);
    expect(value, findsOneWidget);
    expect(
      find.ancestor(of: value, matching: find.byType(SingleChildScrollView)),
      findsOneWidget,
    );
  });
}
