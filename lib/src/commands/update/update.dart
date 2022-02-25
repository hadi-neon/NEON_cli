import 'dart:io';

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
        help: 'Der Pfad, zu dem CLI-Repo auf deinem Rechner.',
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
  String get invocation => 'NEON update <cli-path>';

  @visibleForTesting
  ArgResults? argResultOverrides;

  ArgResults get _argResults => argResultOverrides ?? argResults!;

  @override
  Future<int> run() async {
    final generateDone = _logger.progress('Up am Daten...');

    final _updateShell = Shell(workingDirectory: _cliPath, verbose: false);

    try {
      await _updateShell.run('git pull');
    } catch (e) {
      _logger.err('Irgendetwas ist beim git pull schiefgelaufen...\n\n$e');
      return ExitCode.software.code;
    }

    try {
      await _updateShell.run('dart pub global deactivate NEON_cli');
    } catch (e) {
      _logger.err(
          'Irgendetwas ist beim Deaktivieren der alten CLI Version schiefgelaufen...\nVersuche es manuell:\n\n\ndart pub global deactivate NEON_cli\n\n$e');
      return ExitCode.software.code;
    }

    try {
      await _updateShell.run('dart pub global activate --source path .');
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
    final cliPath = _argResults['cli-path'] as String? ??
        path.basename(path.normalize(_cliDirectory.absolute.path));
    return cliPath;
  }

  Directory get _cliDirectory {
    final rest = _argResults.rest;
    _validateCLIDirectoryArg(rest);
    return Directory(rest.first);
  }

  void _validateCLIDirectoryArg(List<String> args) {
    if (args.isEmpty) {
      throw UsageException(
        'Du musst das Verzeichnis, in dem die CLI liegt, angeben!.',
        usage,
      );
    }

    if (args.length > 1) {
      throw UsageException(
          'Du musst dich leider für ein Verzeichnis entscheiden...', usage);
    }
  }
}
