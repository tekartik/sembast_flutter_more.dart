import 'package:flutter/material.dart';
import 'package:sembast/utils/database_utils.dart';
import 'package:sembast_db_explorer/src/data/db_data.dart';
import 'package:sembast_db_explorer/src/screen/store_home_screen.dart';
import 'package:sembast_db_explorer/src/text/text.dart';

class DbHomeScreen extends StatefulWidget {
  final DbData data;
  const DbHomeScreen({super.key, required this.data});

  @override
  State<DbHomeScreen> createState() => _DbHomeScreenState();
}

class _DbHomeScreenState extends State<DbHomeScreen> {
  late List<String> _stores;
  void _refreshStoreList() {
    var db = widget.data.database;
    _stores = getNonEmptyStoreNames(db).toList();
  }

  @override
  void initState() {
    _refreshStoreList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(textDbHomeScreenTitle)),
      body: ListView.builder(
        itemBuilder: (_, index) {
          var store = _stores[index];
          return ListTile(
            title: Text(store),
            onTap: () async {
              await goToStoreHomeScreen(context, widget.data, store);
            },
          );
        },
        itemCount: _stores.length,
      ),
    );
  }
}
