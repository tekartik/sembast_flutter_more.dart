import 'package:dev_test/package.dart';
import 'package:path/path.dart';

Future main() async {
  for (var dir in [
    'sembast_flutter',
    'cloud_firestore_type_adapters',
    'notepad_stress_app',
    'sembast_db_explorer',
  ]) {
    await packageRunCi(join('..', dir));
  }
  await packageRunCi('.');
}
