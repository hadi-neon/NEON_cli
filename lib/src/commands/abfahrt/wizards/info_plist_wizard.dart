import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

class InfoPlistWizard {
  final String templateDir;
  final String projectDir;

  //TODO CFBundleSignature is ???

  static const _countryCodes = ['en', 'de'];

  static const _splittingKey = '<dict>';

  InfoPlistWizard({
    required this.templateDir,
    required this.projectDir,
  });

  Future<void> run() async {
    final infoPlist = File(
      path.join(projectDir, 'ios', 'Runner', 'Info.plist'),
    );

    String newPlist = '';

    final plistString = infoPlist.readAsStringSync();

    final start = plistString.indexOf(_splittingKey);

    final tmp1 = plistString.substring(0, start + _splittingKey.length);
    String localizationKeys =
        '\n\t<key>CFBundleLocalizations</key>\n\t<array>\n';
    for (var code in _countryCodes) {
      localizationKeys += '\t\t<string>$code</string>\n';
    }
    localizationKeys += '\t</array>';
    final tmp2 =
        plistString.substring(start + _splittingKey.length, plistString.length);
    newPlist = tmp1 + localizationKeys + tmp2;

    await infoPlist.writeAsString(newPlist);
  }
}
