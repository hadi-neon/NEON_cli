import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/shell.dart';
import 'package:universal_io/io.dart';
import 'package:very_vollgas_cli/src/cli/cli.dart';
import 'package:very_vollgas_cli/src/commands/abfahrt/file_copy_wizard.dart';
import 'package:very_vollgas_cli/src/commands/abfahrt/info_plist_wizard.dart';
import 'package:very_vollgas_cli/src/commands/abfahrt/mason_wizard.dart';
import 'package:very_vollgas_cli/src/commands/abfahrt/scripts_wizard.dart';

const template_name = 'NEON_template_project';
const git_url = 'github.com:julien-neon/NEON_template_project.git';
const tmpDirName = 'tmp';

// A valid Dart identifier that can be used for a package, i.e. no
// capital letters.
// https://dart.dev/guides/language/language-tour#important-concepts
final RegExp _identifierRegExp = RegExp('[a-z_][a-z0-9_]*');

/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef GeneratorBuilder = Future<MasonGenerator> Function(MasonBundle);

/// {@template abfahrt_command}
/// `very_vollgas abfahrt` command creates code from the NEON Template Project.
/// {@endtemplate}
class AbfahrtCommand extends Command<int> {
  /// {@macro abfahrt_command}
  AbfahrtCommand({
    Logger? logger,
    required Shell shell,
  })  : _shell = shell,
        _logger = logger ?? Logger() {
    argParser
      ..addOption(
        'project-name',
        help: 'Der Name des Projektes (muss dem NEON-🔥-Standard entsprechen).'
            'Muss ein valider dart Package Name sein.',
      );
  }

  final Logger _logger;
  final Shell _shell;

  @override
  String get description =>
      'Erstellt ein neues Projekt nach NEON Maßstäben (to the 🌝) im angegebenen Verzeichnis.';

  @override
  String get summary => '$invocation\n$description';

  @override
  String get name => 'abfahrt';

  @override
  String get invocation => 'very_vollgas abfahrt <output directory>';

  /// [ArgResults] which can be overridden for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  ArgResults get _argResults => argResultOverrides ?? argResults!;

  @override
  Future<int> run() async {
    final tmpDir = path.join(Directory.current.path, tmpDirName);
    final templateDirectory = path.join(tmpDir, template_name);
    final projectDirectory = path.join(Directory.current.path, _projectName);
    final _copyWiz = FileCopyWizard(
      projectName: _projectName,
      templateDir: templateDirectory,
      projectDir: projectDirectory,
    );

    final _plistWiz = InfoPlistWizard(
      templateDir: templateDirectory,
      projectDir: projectDirectory,
    );

    final projectName = _projectName;

    final generateDone = _logger.progress('Bin Sachen am machen');

    try {
      await _shell.run('mkdir $tmpDirName');
      final _tmpShell = Shell(workingDirectory: tmpDir, verbose: false);
      _logger.alert('\nDas Template fliegt hier irgendwo rum: $git_url...\n');
      await _tmpShell.run(
        'git clone git@$git_url',
      );
    } catch (e) {
      _logger.err(
          '\nBeim git pull ist etwas schiefgelaufen... Hast du einen Ordner namens $template_name oder $tmpDirName/$template_name im aktuellen Verzeichnis? Steckt das WLAN-Kabel?');
      await _cleanUp(tmpDir: tmpDir);
      generateDone('Abbruch...');
      return ExitCode.cantCreate.code;
    }

    try {
      await _shell.run('flutter create $projectName');
    } catch (e) {
      _logger.err(
          '\nBei flutter create $projectName ist etwas schiefgelaufen...:\n\n$e');
      await _cleanUp(tmpDir: tmpDir);
      generateDone('Abbruch...');
      return ExitCode.cantCreate.code;
    }

    _logger.alert(
        '\nSchritt 1 abgeschlossen! Hier ging sonst immer was schief. Heute nicht!\n');

    _logger.alert("************************************");
    _logger.alert("NEON TEMPLATE PROJECT MAGIC STARTS NOW");
    _logger.alert("************************************");

    try {
      await _copyWiz.run();
      _logger.alert('\nDie Files sind kopiert!\n');
    } catch (e) {
      _logger
          .err('\nBeim Kopieren der Files ist etwas schiefgelaufen...:\n\n$e');
      await _cleanUp(tmpDir: tmpDir, projectDir: projectDirectory);
      generateDone('Abbruch...');
      return ExitCode.cantCreate.code;
    }

    try {
      await _plistWiz.run();
      _logger.alert('Info.plist hab ich mal neu durchgewürfelt!\n');
    } catch (e) {
      _logger.err(
          '\nBeim Einfügen der Localization Keys in Info.plist ist etwas schiefgelaufen...:\n\n$e');
      await _cleanUp(tmpDir: tmpDir, projectDir: projectDirectory);
      generateDone('Abbruch...');
      return ExitCode.cantCreate.code;
    }

    await Flutter.pubGet(cwd: projectDirectory);

    final _projectShell =
        Shell(workingDirectory: projectDirectory, verbose: false);
    final _scriptsWiz = ScriptsWizard(
      projectShell: _projectShell,
      logger: (message) => _logger.alert(message),
      errorLogger: (message) => _logger.err(message),
    );

    try {
      await _scriptsWiz.run();
      _logger.alert('\nDie Life-Saver-Scripts sind erstellt!\n');
    } catch (e) {
      await _cleanUp(tmpDir: tmpDir, projectDir: projectDirectory);
      generateDone('Abbruch...');
      return ExitCode.cantCreate.code;
    }

    final _masonWiz = MasonWizard(
        projectShell: _projectShell,
        projectName: projectName,
        projectDir: projectDirectory,
        logger: (message) => _logger.alert(message));

    try {
      await _masonWiz.run();
    } catch (e) {
      _logger
          .err('\nBeim Aufsetzen von mason ist etwas schiefgelaufen...:\n\n$e');
      await _cleanUp(tmpDir: tmpDir, projectDir: projectDirectory);
      generateDone('Abbruch...');
      return ExitCode.cantCreate.code;
    }

    await _cleanUp(tmpDir: tmpDir);

    generateDone('$projectName ist aufgesetzt. Jetzt schnapp sie dir, Tiger!');

    return ExitCode.success.code;
  }

  Future<void> _cleanUp({
    required String tmpDir,
    String? projectDir,
  }) async {
    await Directory(tmpDir).delete(recursive: true);
    if (projectDir != null) {
      await Directory(projectDir).delete(recursive: true);
    }
  }

  /// Gets the project name.
  ///
  /// Uses the current directory path name
  /// if the `--project-name` option is not explicitly specified.
  String get _projectName {
    final projectName = _argResults['project-name'] as String? ??
        path.basename(path.normalize(_outputDirectory.absolute.path));
    _validateProjectName(projectName);
    return projectName;
  }

  void _validateProjectName(String name) {
    final isValidProjectName = _isValidPackageName(name);
    if (!isValidProjectName) {
      throw UsageException(
        '"$name" is not a valid package name.\n\n'
        'See https://dart.dev/tools/pub/pubspec#name for more information.',
        usage,
      );
    }
  }

  bool _isValidPackageName(String name) {
    final match = _identifierRegExp.matchAsPrefix(name);
    return match != null && match.end == name.length;
  }

  Directory get _outputDirectory {
    final rest = _argResults.rest;
    _validateOutputDirectoryArg(rest);
    return Directory(rest.first);
  }

  void _validateOutputDirectoryArg(List<String> args) {
    if (args.isEmpty) {
      throw UsageException(
        'No option specified for the output directory.',
        usage,
      );
    }

    if (args.length > 1) {
      throw UsageException('Multiple output directories specified.', usage);
    }
  }
}
