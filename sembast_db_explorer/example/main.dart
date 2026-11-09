import 'package:material_ui/material_ui.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:sembast_db_explorer/sembast_db_explorer.dart';

/// A sample database in memory (runs on every platform, web included).
Future<Database> openSampleDatabase() async {
  var db = await newDatabaseFactoryMemory().openDatabase('sample.db');
  var people = intMapStoreFactory.store('people');
  await people.add(db, {'name': 'Alice', 'age': 30});
  await people.add(db, {
    'name': 'Bob',
    'tags': ['admin', 'dev'],
  });
  await StoreRef<String, String>('settings').record('theme').put(db, 'dark');
  return db;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var db = await openSampleDatabase();
  // material_ui's MaterialApp: the explorer screens are material_ui widgets.
  runApp(MaterialApp(home: HomePage(database: db)));
}

/// A page with a button opening the explorer.
class HomePage extends StatelessWidget {
  /// The database to explore, opened by the app.
  final Database database;

  /// A page with a button opening the explorer.
  const HomePage({super.key, required this.database});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('sembast_db_explorer example')),
    body: Center(
      child: FilledButton(
        // Stores, then records, then a record value; back to return here.
        onPressed: () => showDatabaseExplorer(context, database),
        child: const Text('Explore the database'),
      ),
    ),
  );
}
