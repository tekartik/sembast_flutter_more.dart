import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_db_explorer/src/data/db_data.dart';
import 'package:sembast_db_explorer/src/screen/record_home_screen.dart';

class StoreHomeScreen extends StatefulWidget {
  final StoreData data;
  const StoreHomeScreen({Key? key, required this.data}) : super(key: key);

  @override
  _StoreHomeScreenState createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  StoreRef get store => widget.data.store;
  late Stream<List<RecordSnapshot>> _recordsStream;

  @override
  void initState() {
    var db = widget.data.database;
    _recordsStream = store.query().onSnapshots(db);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(store.name),
      ),
      body: StreamBuilder<List<RecordSnapshot>>(
          stream: _recordsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var list = snapshot.data!;
            var count = list.length;
            return ListView.builder(
              itemBuilder: (_, index) {
                var record = list[index];
                return ListTile(
                  title: Text(record.key.toString()),
                  onTap: () async {
                    await goToRecordHomeScreen(
                        context, widget.data, record.key);
                  },
                );
              },
              itemCount: count,
            );
          }),
    );
  }
}

/// Navigate through stores and record.
Future<void> goToStoreHomeScreen(
    BuildContext context, DbData data, String store) async {
  await Navigator.of(context)
      .push(MaterialPageRoute(builder: (BuildContext context) {
    return StoreHomeScreen(data: StoreData(data, StoreRef(store)));
  }));
}
