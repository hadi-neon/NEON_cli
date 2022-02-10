import 'package:process_run/shell.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

class ScriptsWizard {
  final Shell _projectShell;
  final Function(String)? logger;
  final Function(String)? errorLogger;

  ScriptsWizard({
    required projectShell,
    this.logger,
    this.errorLogger,
  }) : _projectShell = projectShell;
  Future<void> run() async {
    _addMinAndTargetSDKVersions();
    // TODO this only works on unix
    await _projectShell.run('chmod +x ./flutter_launcher_icons.sh');
    await _projectShell.run('chmod +x ./flutter_native_splash.sh');
    await _projectShell.run('chmod +x ./build_runner.sh');
    await _projectShell.run('chmod +x ./pods_machen_faxen.sh');

    try {
      logger?.call('\nLauncher Icons werden erstellt...');
      await _projectShell.run('./flutter_launcher_icons.sh');
    } catch (e) {
      errorLogger?.call(
          '\nBeim Ausführen von flutter_launcher_icons.sh ist etwas schiefgelaufen...:\n\n$e');
    }

    try {
      logger?.call('\nIch pinsel dir noch schnell den Splash Screen...');
      await _projectShell.run('./flutter_native_splash.sh');
    } catch (e) {
      errorLogger?.call(
          '\nBeim Ausführen von flutter_native_splash.sh ist etwas schiefgelaufen...:\n\n$e');
    }

    try {
      logger?.call(
          '\nUnd zum Schluss nochmal mit dem build_runner drüberbügeln...');
      await _projectShell.run('./build_runner.sh');
    } catch (e) {
      errorLogger?.call(
          '\nBeim Ausführen von build_runner.sh ist etwas schiefgelaufen...:\n\n$e');
    }
  }

  //This is needed for the flutter_launcher_icons.sh script to work
  void _addMinAndTargetSDKVersions() {
    logger?.call('\nbuild.gradle wird bearbeitet...');

    var buildGradle =
        File(path.join(_projectShell.path, 'android', 'app', 'build.gradle'));
    final newBuildGradle = 'minSdkVersion 21\ntargetSdkVersion 29\n';
    try {
      final gradleString = buildGradle.readAsStringSync();
      buildGradle.writeAsString(newBuildGradle + gradleString);

      logger?.call('\nbuild.gradle macht jetzt keine Faxen mehr!');
    } catch (e) {
      errorLogger?.call(
          '\nBeim Einfügen von $newBuildGradle in build.gradle ist etwas schiefgelaufen...:\n\n$e');
    }
  }
}
