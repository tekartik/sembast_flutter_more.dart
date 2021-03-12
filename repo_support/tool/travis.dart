import 'package:path/path.dart';
import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  for (var dir in [
    'sembast_flutter',
    'cloud_firestore_type_adapters',
  ]) {
    shell = shell.pushd(join('..', dir));
    await shell.run('''
  
  flutter packages get
  dart tool/travis.dart
  
''');
    shell = shell.popd();
  }
}
