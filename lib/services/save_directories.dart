// import 'dart:io';

// import 'package:nepanikar/utils/crashlytics_utils.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class SaveDirectories {
//   SaveDirectories();

//   Future<void> init() async {
//     supportDir = await getApplicationSupportDirectory();

//     // Creates a directory for db, if it doesn't exist.
//     await Directory(dbDirPath).create(recursive: true);
//   }

//   late final Directory supportDir;

//   String get dbDirPath => join(supportDir.path, 'db');

//   String get oldAppDataConfigFilePath =>
//       join(supportDir.path, '.config', 'DontPanicDevs', 'DontPanic.conf');

//   String get oldAppDataConfigFileBackupPath => join(supportDir.path, 'DontPanicOldConfig');

//   Future<void> clearSaveDirectories() async {
//     try {
//       await supportDir.delete(recursive: true);
//     } catch (e, s) {
//       await logExceptionToCrashlytics(e, s, logMessage: 'Error deleting save directories.');
//     }
//   }
// }
