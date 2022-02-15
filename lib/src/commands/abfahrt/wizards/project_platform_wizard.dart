import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

const projectPlatform = '12.0';

class ProjectPlatformWizard {
  final String projectDirectory;

  const ProjectPlatformWizard({required this.projectDirectory});

  Future<void> run() async {
    final podfile = File(path.join(
        projectDirectory, 'ios', 'Runner.xcodeproj', 'project.pbxproj'));

    final regex = RegExp(r"IPHONEOS_DEPLOYMENT_TARGET = (\d|\d\d).\d;");

    return podfile.readAsString().then((string) {
      final newString = string.replaceAll(
          regex, 'IPHONEOS_DEPLOYMENT_TARGET = $projectPlatform;');
      podfile.writeAsString(newString);
    });
  }
}
