import 'package:asi/models/user.dart';
import 'package:asi/screens/login_screen.dart';
import 'package:asi/screens/main_screen.dart';
import 'package:asi/services/activity_service.dart';
import 'package:asi/services/user_service.dart';
import 'package:asi/themes/theme.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: MainTheme.primaryColor,
        systemNavigationBarColor: MainTheme.primaryColor,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    Future.delayed(Duration(seconds: 3), () async {
      _defaultChangePage();
    });
  }

  Future<void> initPlatformState() async {
    try {
      var status = await BackgroundFetch.configure(
          BackgroundFetchConfig(
            minimumFetchInterval: 15,
            forceAlarmManager: false,
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY,
          ),
          _onBackgroundFetch,
          _onBackgroundFetchTimeout);
      print('[BackgroundFetch] configure success: $status');
    } on Exception catch (e) {
      print("[BackgroundFetch] configure ERROR: $e");
    }

    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    ActivityService.syncActivities();

    if (taskId == "flutter_background_fetch") {
      // Schedule a one-shot task when fetch event received (for testing).
      /*
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.transistorsoft.customtask",
          delay: 5000,
          periodic: false,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresNetworkConnectivity: true,
          requiresCharging: true
      ));
       */
    }
    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  /// This event fires shortly before your task is about to timeout.  You must finish any outstanding work and call BackgroundFetch.finish(taskId).
  void _onBackgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _defaultChangePage() async {
    Future.delayed(Duration(seconds: 3), () async {
      bool isLoggedIn = await UserService.isLoggedIn();
      User? user = UserService.getLocalUser();
      if (isLoggedIn && user != null) {
        Get.offAll(() => MainScreen(user: user));
      } else {
        Get.offAll(() => LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                height: Get.mediaQuery.size.height * 0.25 - 40,
                child: Image.asset(
                  "assets/images/isotipo.png",
                  height: Get.mediaQuery.size.height * 0.15,
                  width: Get.mediaQuery.size.height * 0.15,
                ),
              ),
            ),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (!snapshot.hasError &&
                  snapshot.hasData &&
                  snapshot.data != null) {
                PackageInfo packageInfo = snapshot.data!;
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Versión: ${packageInfo.version}",
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.8),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
