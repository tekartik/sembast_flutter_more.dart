import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_db_explorer/src/data/db_data.dart';
import 'package:sembast_db_explorer/src/screen/db_home_screen.dart';

/// Navigate through stores and record.
Future<void> showDatabaseExplorer(
    BuildContext context, Database database) async {
  var data = DbData(database);
  await Navigator.of(context)
      .push<void>(MaterialPageRoute(builder: (BuildContext context) {
    return DbHomeScreen(
      data: data,
    );
  }));
}
