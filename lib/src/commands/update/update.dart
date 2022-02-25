import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:process_run/shell.dart';
import 'package:meta/meta.dart';

import 'package:path/path.dart' as path;

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
            'Der Pfad, zu dem CLI-Repo auf deinem Rechner. Um das Flag nicht mehr setzen zu müssen, clone das Repoo in das Verzeichnis $_defaultCliPath!',
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

  final _defaultCliPath = path.join('~', 'NEON_cli');

  @override
  Future<int> run() async {
    final generateDone = _logger.progress('Up am Daten...');

    _logger.alert('NEON CLI V2 BITCHEZ');

    final _updateShell = Shell(workingDirectory: _cliPath, verbose: true);

    try {
      await _updateShell.run('git pull');
    } catch (e) {
      _logger.err('Irgendetwas ist beim git pull schiefgelaufen...\n\n$e');
    }
    generateDone('NEON CLI ist up-to-date!');
    return ExitCode.success.code;
  }

  /// Gets the cli path.
  ///
  /// Uses the [_defaultCliPath] if the `--cli-path` option is not explicitly specified.
  String get _cliPath {
    final cliPath = _argResults['cli-path'] as String? ?? _defaultCliPath;
    return cliPath;
  }
}
