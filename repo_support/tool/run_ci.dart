import 'package:dev_test/package.dart';
import 'package:path/path.dart';

Future main() async {
  for (var dir in [
    'sembast_flutter',
    'cloud_firestore_type_adapters',
  ]) {
    await packageRunCi(join('..', dir));
  }
  await packageRunCi('.');
}
