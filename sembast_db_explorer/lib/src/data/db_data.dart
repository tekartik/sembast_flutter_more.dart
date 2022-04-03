import 'package:sembast/sembast.dart';

class DbData {
  final Database database;

  DbData(this.database);
}

class StoreData {
  Database get database => dbData.database;
  final DbData dbData;
  final StoreRef store;

  StoreData(this.dbData, this.store);
}

class RecordData {
  final StoreData storeData;
  final RecordRef record;
  Database get database => storeData.database;
  RecordData(this.storeData, this.record);
}
