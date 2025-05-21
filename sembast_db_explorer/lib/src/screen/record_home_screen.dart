import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_db_explorer/src/data/db_data.dart';
import 'package:sembast_db_explorer/src/text/text.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class RecordHomeScreen extends StatefulWidget {
  final RecordData data;
  const RecordHomeScreen({super.key, required this.data});

  @override
  State<RecordHomeScreen> createState() => _RecordHomeScreenState();
}

class _RecordHomeScreenState extends State<RecordHomeScreen> {
  RecordRef get record => widget.data.record;
  late Stream<RecordSnapshot?> _recordStream;

  @override
  void initState() {
    var db = widget.data.database;
    _recordStream = record.onSnapshot(db);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(record.key.toString())),
      body: StreamBuilder<RecordSnapshot?>(
        stream: _recordStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var recordSnapshot = snapshot.data;
          if (recordSnapshot == null) {
            return Center(child: Text(textNotFound));
          }
          String? result;
          try {
            result = jsonPretty(recordSnapshot.value);
          } catch (_) {
            result = recordSnapshot.toString();
          }
          return Text(result ?? '<no_data>');
        },
      ),
    );
  }
}

/// Navigate through stores and record.
Future<void> goToRecordHomeScreen(
  BuildContext context,
  StoreData data,
  Object key,
) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return RecordHomeScreen(data: RecordData(data, data.store.record(key)));
      },
    ),
  );
}
