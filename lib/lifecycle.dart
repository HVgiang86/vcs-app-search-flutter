import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';

class LifecycleWatcher extends StatefulWidget {
  const LifecycleWatcher({super.key});

  @override
  State<LifecycleWatcher> createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher>
    with WidgetsBindingObserver {
  AppLifecycleState? _appLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? color;

    if (_appLifecycleState == null) {
      color = Colors.red;
    } else {
      if (_appLifecycleState == AppLifecycleState.resumed) {
        color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            .withOpacity(1.0);
      }
    }
    return ScrollLoopAutoScroll(
      child: Text(
        'Viettel Cyber Security. Very long text that bleeds out of the rendering space',
        style:  TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      scrollDirection: Axis.horizontal,
    );
  }
}
