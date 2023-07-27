import 'dart:async';
import 'dart:io';

import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';

class AppCheckPage extends StatelessWidget {
  const AppCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCheckWidget();
  }
}

class AppCheckWidget extends StatefulWidget {
  const AppCheckWidget({Key? key}) : super(key: key);

  @override
  State<AppCheckWidget> createState() => _AppCheckWidgetState();
}

class _AppCheckWidgetState extends State<AppCheckWidget> {
  List<AppInfo>? installedApps;
  List<AppInfo>? displayList;
  bool firstCall = true;
  List<AppInfo> iOSApps = [
    AppInfo(appName: "Calendar", packageName: "calshow://"),
    AppInfo(appName: "Facebook", packageName: "fb://"),
    AppInfo(appName: "Whatsapp", packageName: "whatsapp://"),
  ];

  @override
  void initState() {
    getApps();
    searchApps("");
    super.initState();
  }

  Future<void> searchApps(String target) async {
    debugPrint('Search app called');
    if (firstCall) {
      setState(() {
        this.displayList = installedApps;
        firstCall = false;
      });
      return;
    }

    List<AppInfo>? displayList = List<AppInfo>.empty(growable: true);
    if (target.isEmpty || installedApps == null || installedApps!.isEmpty) {
      if (installedApps!.isNotEmpty) {
        displayList = installedApps;
      }
    } else {
      for (var element in installedApps!) {
        if (element.appName!.contains(target)) {
          displayList.add(element);
        }
      }
    }

    setState(() {
      this.displayList = displayList;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getApps() async {
    List<AppInfo>? installedApps;

    if (Platform.isAndroid) {
      const package = "com.google.android.apps.maps";
      installedApps = await AppCheck.getInstalledApps();
      debugPrint(installedApps.toString());

      await AppCheck.checkAvailability(package).then(
        (app) => debugPrint(app.toString()),
      );

      await AppCheck.isAppEnabled(package).then(
        (enabled) => enabled
            ? debugPrint('$package enabled')
            : debugPrint('$package disabled'),
      );

      installedApps?.sort(
        (a, b) => a.appName!.toLowerCase().compareTo(b.appName!.toLowerCase()),
      );
    } else if (Platform.isIOS) {
      // iOS doesn't allow to get installed apps.
      installedApps = iOSApps;

      await AppCheck.checkAvailability("calshow://").then(
        (app) => debugPrint(app.toString()),
      );
    }

    setState(() {
      this.installedApps = installedApps;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('call build widget');
    debugPrint('installedApp: ${installedApps?.length}');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Search for installed package'),
          leading: BackButton(onPressed: () => {Navigator.pop(context)}),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBar(
                hintText: 'Type package name',
                leading: const Icon(Icons.search),
                onChanged: (value) {
                  debugPrint('onChanged $value');
                  searchApps(value);
                },
              ),
            ),
            Expanded(
              child: Container(
                child: displayList != null && displayList!.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: displayList!.length,
                        itemBuilder: (context, index) {
                          final app = displayList![index];

                          return ListTile(
                            title: Text(app.appName ?? app.packageName),
                            subtitle: Text(
                              (app.isSystemApp ?? false)
                                  ? 'System App'
                                  : 'User App',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                AppCheck.launchApp(app.packageName).then((_) {
                                  debugPrint(
                                    "${app.appName ?? app.packageName} launched!",
                                  );
                                }).catchError((err) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      "${app.appName ?? app.packageName} not found!",
                                    ),
                                  ));
                                  debugPrint(err.toString());
                                });
                              },
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('No installed apps found!')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
