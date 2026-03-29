import 'package:dev_build/shell.dart';

Future<void> main() async {
  await run('flutter test --platform chrome');
}
