import 'package:android_long_task/android_long_task.dart';
import 'package:flutter/material.dart';
import 'package:test_env/device_info_page.dart';
import 'package:test_env/lifecycle.dart';
import 'package:test_env/test_long_task_page.dart';

import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';

import 'app_search_page.dart';
import 'app_service_config.dart';
import 'service_call_flutter.dart';

void main() {
  runApp(const MainPage());
}

Future<T?> pushPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context)
      .push<T>(MaterialPageRoute(builder: (context) => page));
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),

      ),
      body: const Center(child: LifecycleWatcher()),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        semanticLabel: 'My Drawer menu',
        child: ListView(
          children: [
            DrawerHeader(
                child: Container(
              margin: const EdgeInsets.only(left: 8, right: 0, top: 0, bottom: 0),
              child: ListView(
                children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      child: ClipOval(
                        child: Container(
                          color: Colors.black12,
                          child: Image.asset(
                            'assets/cat_icon.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.fill,
                          ),
                        ),
                      )),
                  const SizedBox(height: 10),
                  const Text(
                    'Hoang Giang VCS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text('Ước mơ biến mọi thứ thành mèo')
                ],
              ),
            )),
            Container(
              margin: const EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  const Icon(Icons.info),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DeviceInfomationPage()));
                      },
                      child: const Text(
                        'Show device information',
                        style: TextStyle(fontSize: 16),
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppCheckWidget()));
                      },
                      child: const Text(
                        'Search for application',
                        style: TextStyle(fontSize: 16),
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  const Icon(Icons.bug_report),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyServicePage()));
                      },
                      child: const Text(
                        'Test Service page',
                        style: TextStyle(fontSize: 16),
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  const Icon(Icons.android),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherPage()));
                      },
                      child: const Text(
                        'Test Native Method Call\n[Weather App]',
                        style: TextStyle(fontSize: 16),
                      ))
                ],
              ),
            )
          ],
        ));
  }
}
