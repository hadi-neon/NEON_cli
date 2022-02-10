import 'package:process_run/shell.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

class ScriptsWizard {
  final Shell _projectShell;
  final Function(String)? logger;

  ScriptsWizard({
    required projectShell,
    this.logger,
  }) : _projectShell = projectShell;
  Future<void> run() async {
    _addMinAndTargetSDKVersions();
    // TODO this only works on unix
    await _projectShell.run('chmod +x ./flutter_launcher_icons.sh');
    await _projectShell.run('chmod +x ./flutter_native_splash.sh');
    await _projectShell.run('chmod +x ./build_runner.sh');
    await _projectShell.run('chmod +x ./pods_machen_faxen.sh');

    logger?.call('\nLauncher Icons werden erstellt...');
    await _projectShell.run('./flutter_launcher_icons.sh');
    logger?.call('\nIch pinsel dir noch schnell den Splash Screen...');
    await _projectShell.run('./flutter_native_splash.sh');
    logger?.call(
        '\nUnd zum Schluss nochmal mit dem build_runner drüberbügeln...');
    await _projectShell.run('./build_runner.sh');
  }

  //This is needed for the flutter_launcher_icons.sh script to work
  void _addMinAndTargetSDKVersions() {
    logger?.call('\nbuild.gradle wird bearbeitet...');

    var buildGradle =
        File(path.join(_projectShell.path, 'android', 'app', 'build.gradle'));
    final newBuildGradle = 'minSdkVersion 21\ntargetSdkVersion 29\n';
    final gradleString = buildGradle.readAsStringSync();
    buildGradle.writeAsString(newBuildGradle + gradleString);

    logger?.call('\nbuild.gradle macht jetzt keine Faxen mehr!');
  }
}
