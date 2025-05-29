import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/data.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/constants/constant.dart';

String getRootDir() {
  return Platform.isAndroid
      ? '/storage/emulated/0/ExternalApp'
      : Platform.isLinux
          ? '${Platform.environment['HOME']}/ExternalApp'
          : Platform.isWindows
              ? 'C:\\ExternalApp'
              : Platform.isMacOS
                  ? '/ExternalApp'
                  : './';
}

final String appPath = join(getRootDir(), appName);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> requestManageExternalStoragePermission() async {
  if (Platform.isAndroid) {
    if (await Permission.manageExternalStorage.isGranted) {
      return;
    } else {
      final result = await Permission.manageExternalStorage.request();
      if (!result.isGranted) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Permission Required"),
              content: const Text(
                  "This app requires access to manage external storage. Please enable it in system settings."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text("Exit"),
                ),
              ],
            );
          },
        );
      }
    }
  } else if (Platform.isIOS) {
    if (!await Permission.photos.isGranted) {
      await Permission.photos.request();
    }
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
  }
}

void initializeDatabaseFactory() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

const uuid = Uuid();
var rnd = Random();

String generateNewUuid() {
  return uuid.v7(
      config: V7Options(DateTime.now().millisecondsSinceEpoch,
          List<int>.generate(10, (_) => rnd.nextInt(256))));
}

bool isDesktop() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

bool isNative() {
  return Platform.isAndroid || Platform.isIOS;
}

void pushPopIn(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}
