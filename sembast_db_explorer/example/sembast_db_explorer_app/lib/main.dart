import 'package:flutter/material.dart';
import 'package:sembast_db_explorer/sembast_db_explorer.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

var factory = getDatabaseFactory();

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Db explorer app example'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> showExplorer() async {
    if (mounted) {
      var db = await factory.openDatabase('sembast_db_explorer_app.db',
          version: 2, onVersionChanged: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          var testStore = intMapStoreFactory.store('test');
          await testStore.add(db, {'test': 1});
        }
      });
      if (mounted) {
        await showDatabaseExplorer(context, db);
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      showExplorer();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Tap the button to explore sample database',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showExplorer,
        tooltip: 'Show explorer',
        child: const Icon(Icons.view_array),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
