import 'package:sembast_flutter_example/db/db.dart';

class DbNote extends DbRecord {
  final title = stringField('title');
  final content = stringField('content');

  @override
  List<Field> get fields => [title, content];
}
