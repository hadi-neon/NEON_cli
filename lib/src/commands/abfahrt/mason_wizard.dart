import 'package:process_run/shell.dart';
import 'package:universal_io/io.dart';
import 'package:very_vollgas_cli/src/cli/cli.dart';
import 'package:path/path.dart' as path;

class MasonWizard {
  final Shell _shell;
  final String projectName;
  final String projectDir;
  final Function(String) logger;

  static const _exportPathCommand =
      'export PATH="\$PATH":"\$HOME/.pub-cache/bin"';

  MasonWizard({
    required projectShell,
    required this.projectName,
    required this.projectDir,
    required this.logger,
  }) : _shell = projectShell;

  Future<void> run() async {
    final masonInstalled = await Dart.masonInstalled();
    bool canSetup = masonInstalled;
    if (!masonInstalled) {
      canSetup = await _installMason();
    }
    if (canSetup) {
      await _setupMason();
    }
  }

  Future<bool> _installMason() async {
    final dartInstalled = await Dart.installed();
    if (dartInstalled) {
      await _shell.run('dart pub global activate mason_cli');
      logger(
          '\nMason ist im Moment nur für diese Session aktiv. Wenn du in Zukunft alle Bricks 🧱 nutzen willst (und das willst du), dann füge jetzt diese Zeile in deine ~/.zshrc bzw. ~/.bashrc ein\n\n\n$_exportPathCommand\n\n\nund erhalte sofort 5000 Papeo Party Coins!');
      return true;
    } else {
      logger(
          '\nDart ist nicht installiert, also kann ich dir mason nicht aufsetzen...\nInstalliere zuerst dart und befolge dann die Schritte, die im README von $projectName unter dem Punkt "Mason init für dummies" beschrieben sind.');
      return false;
    }
  }

  Future<void> _setupMason() async {
    final masonFile = File(path.join(projectDir, 'mason.yaml'));
    final masonString = masonFile.readAsStringSync();

    await masonFile.delete();

    await _shell.run('mason init');

    final newMasonYAML =
        await File(path.join(projectDir, 'mason.yaml')).create();

    await newMasonYAML.writeAsString(masonString);

    await _shell.run('mason get');

    await Directory(path.join(projectDir, 'bricks')).delete(recursive: true);

    logger('\nMason ist aufgesetzt!');
  }
}
