import 'package:NEON_cli/src/commands/commands.dart';
import 'package:universal_io/io.dart';
import 'package:path/path.dart' as path;

//TODO: vllt doch mason? ist echt ugly was hier abgeht
class FileCopyWizard {
  final String templateDir;
  final String projectDir;
  final String projectName;

  final _sep = Platform.pathSeparator;

  // files and directories we do NOT want to touch
  final _doNotCopy = [
    'android',
    'ios',
    '.metadata',
    '.dart_tool',
    '.flutter-plugins',
    '.flutter-plugins-dependencies',
    '.packages',
    'pubspeck.lock',
    'pubspec.yaml',
    '.git',
  ];

  FileCopyWizard({
    required this.templateDir,
    required this.projectDir,
    required this.projectName,
  });

  Future<void> run() async {
    final projectDirectory = Directory(projectDir);
    _copyDirectory(Directory(templateDir), projectDirectory);
    _copyAndReplaceNameInPubspec();
  }

  void _copyDirectory(Directory source, Directory destination) {
    source.listSync(recursive: false).forEach((var entity) {
      if (entity is Directory) {
        if (_wantToCopyThis(entity.path)) {
          var newDirectory = Directory(
              path.join(destination.absolute.path, path.basename(entity.path)));
          newDirectory.createSync();

          _copyDirectory(entity.absolute, newDirectory);
        }
      } else if (entity is File) {
        if (_wantToCopyThis(entity.path)) {
          var newFile = entity.copySync(
              path.join(destination.path, path.basename(entity.path)));

          //replace import statements
          if (_isDartFile(entity.path)) {
            _replaceImportStatements(newFile);
          }
        }
      }
    });
  }

  void _copyAndReplaceNameInPubspec() {
    var appPubspec = File(path.join(projectDir, 'pubspec.yaml'));
    File(path.join(templateDir, 'pubspec.yaml'))
        .readAsString()
        .then((String sourcePub) {
      final start = sourcePub.indexOf(template_name);
      final tmp1 = sourcePub.substring(0, start);
      final tmp2 =
          sourcePub.substring(start + template_name.length, sourcePub.length);

      final newPub = tmp1 + projectName + tmp2;
      appPubspec.writeAsString(newPub);
    });
  }

  void _replaceImportStatements(File file) {
    file.readAsString().then((string) {
      final newString = string.replaceAll(template_name, projectName);
      file.writeAsString(newString);
    });
  }

  String _getName(String path) => path.split(_sep).last;

  bool _isDartFile(String path) => path.split('.').last == 'dart';

  bool _wantToCopyThis(String path) {
    final name = _getName(path);
    final res = !_doNotCopy.contains(name);
    return res;
  }
}
