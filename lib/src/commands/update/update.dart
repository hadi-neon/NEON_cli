import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:process_run/cmd_run.dart';
import 'package:meta/meta.dart';

/// {@template update_command}
/// `NEON update` command updates the NEON CLI.
/// {@endtemplate}
class UpdateCommand extends Command<int> {
  /// {@macro update_command}
  UpdateCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser
      ..addOption(
        'cli-path',
        help:
            'Der Pfad zu dem CLI-Repo auf deinem Rechner. Sollte eigentlich $_defaultCLIPath sein! 🧐',
      );
  }

  final Logger _logger;

  @override
  String get description =>
      'Updated die NEON CLI auf den neuesten Stand der Dinge';

  @override
  String get summary => '$invocation\n$description';

  @override
  String get name => 'update';

  @override
  String get invocation => 'NEON update';

  @visibleForTesting
  ArgResults? argResultOverrides;

  ArgResults get _argResults => argResultOverrides ?? argResults!;

  final _defaultCLIPath = '~/NEON_cli';

  @override
  Future<int> run() async {
    final generateDone = _logger.progress('Up am Daten...');

    try {
      final pullCmd = ProcessCmd(
        'git',
        ['-C', _cliPath, 'pull'],
      );
      await runCmd(pullCmd);
    } catch (e) {
      _logger.err('Irgendetwas ist beim git pull schiefgelaufen...\n\n$e');
      return ExitCode.software.code;
    }

    try {
      final deactivateCmd = ProcessCmd(
          'dart', ['pub', 'global', 'deactivate' 'NEON_cli'],
          runInShell: true);
      final tmp = await runCmd(deactivateCmd);
      print(tmp);
    } catch (e) {
      _logger.err(
          'Irgendetwas ist beim Deaktivieren der alten CLI Version schiefgelaufen...\nVersuche es manuell:\n\n\ndart pub global deactivate NEON_cli\n\n$e');
      return ExitCode.software.code;
    }

    try {
      final activateCmd = ProcessCmd(
          'dart', ['pub', 'global', 'activate', '--source', 'path', _cliPath],
          runInShell: true);
      final tmp2 = await runCmd(activateCmd);
      print(tmp2);
    } catch (e) {
      _logger.err(
          'Irgendetwas ist beim Aktivieren der neuen CLI Version schiefgelaufen...\nVersuche es manuell (wenn du im Verzeichnis bist, in dem das NEON_cli Repo liegt):\n\n\ndart pub global activate --source path ./NEON_cli\n\n$e');
      return ExitCode.software.code;
    }

    generateDone('NEON CLI ist up-to-date!');
    return ExitCode.success.code;
  }

  /// Gets the specified cli path.
  ///
  String get _cliPath {
    final cliPath = _argResults['cli-path'] as String? ?? _defaultCLIPath;
    return cliPath;
  }
}
