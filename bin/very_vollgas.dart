import 'package:process_run/shell.dart';
import 'package:universal_io/io.dart';
import 'package:very_vollgas_cli/src/command_runner.dart';

Future<void> main(List<String> args) async {
  var shell = Shell(verbose: false);
  await _flushThenExit(await VeryVollgasCommandRunner(shell: shell).run(args));
}

/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future _flushThenExit(int status) {
  return Future.wait<void>([stdout.close(), stderr.close()])
      .then<void>((_) => exit(status));
}
