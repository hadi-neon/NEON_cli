import 'package:NEON_cli/src/commands/commands.dart';
import 'package:NEON_cli/src/version.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:process_run/shell.dart';

/// The package name.
const packageName = 'NEON_cli';

/// {@template very_vollgas_command_runner}
/// A [CommandRunner] for the NEON CLI.
/// {@endtemplate}

class VeryVollgasCommandRunner extends CommandRunner<int> {
  /// {@macro very_vollgas_command_runner}
  VeryVollgasCommandRunner({
    required Shell shell,
    Logger? logger,
  })  : _logger = logger ?? Logger(),
        super('NEON',
            '🥵 Ein absolutes High-Performer-Tool, vom wilden Typen für wilde Typen.') {
    argParser
      ..addFlag(
        'version',
        negatable: false,
        help: 'Einmal die aktuelle Version to go bitte.',
      );

    addCommand(AbfahrtCommand(logger: logger, shell: shell));
    addCommand(UpdateCommand(logger: logger));
  }

  /// Standard timeout duration for the CLI.
  static const timeout = Duration(milliseconds: 500);

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final _argResults = parse(args);
      return await runCommand(_argResults) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    int? exitCode = ExitCode.unavailable.code;
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }
    return exitCode;
  }

  //TODO: update implementieren (git pull doer so)

}
