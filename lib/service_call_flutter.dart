import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Native Service Call

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Search for installed package'),
            leading: BackButton(onPressed: () => {Navigator.pop(context)}),
          ),
          body: const WeatherWidget()),
    );
  }
}

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  CurrentWeather? data;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => checkForUpdate());
  }

  void checkForUpdate() {
    APIHandler.fetchAlbum().then((value) async {
      CurrentWeather newData = value;
      var lastData;
      await NativeAPIHandler.read().then((value) => lastData = value).onError((error, stackTrace) {
        lastData = null;
        return CurrentWeather("", "", "", 0, 0, "", 0, 0);
      });

      if (lastData == null || newData.isDifferenceWithLastUpdate(lastData)) {
        debugPrint("update requested");
        await NativeAPIHandler.update(newData);
        setState(() {
          data = newData;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build called');
    return Center(child: SingleChildScrollView(child: Text(data.toString())));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

class NativeAPIHandler {
  static const methodChannel =
      MethodChannel('com.example.test_env/message_request');
  static const apiMethod = "apiHandle";
  static const updateRequest = "com.example.test_env/update_sqlite";
  static const readRequest = "com.example.test_env/read_sqlite";
  static const messageParam = "messageParam";
  static const requestMethodKey = "request_method_key";
  static const requestBodyKey = "request_body_key";

  static Future<CurrentWeather> read() async {
    debugPrint("read request sent");
    String? result;

    var map = <String, dynamic>{};
    map[requestMethodKey] = readRequest;
    map[requestBodyKey] = "";
    String messageRequest = jsonEncode(map);
    await methodChannel
        .invokeMethod(apiMethod, {messageParam: messageRequest})
        .then((value) => result = value)
        .catchError((onError) {
          Future.error(onError);
        });
    debugPrint(result);

    if (result == null) {
      Future.error(Error());
    }

    Map<String, dynamic> str = jsonDecode(result!);

    String location = str["location"];
    String country = str["country"];
    String lastUpdate = str["last_update"];
    num tempC = str["temp_c"];
    num windDegree = str["wind_degree"];
    String windDir = str["wind_dir"];
    num cloud = str["cloud"];
    num uv = str["uv"];

    return CurrentWeather(
        location, country, lastUpdate, tempC, windDegree, windDir, cloud, uv);
  }

  static Future<Void?> update(CurrentWeather weather) async {
    var map = <String, dynamic>{};
    map["location"] = weather.location;
    map["country"] = weather.country;
    map["last_update"] = weather.lastUpdate;
    map["temp_c"] = weather.tempC;
    map["wind_degree"] = weather.windDegree;
    map["wind_dir"] = weather.windDir;
    map["cloud"] = weather.cloud;
    map["uv"] = weather.uv;

    var json = jsonEncode(map);

    var requestMap = <String, dynamic>{};
    requestMap[requestMethodKey] = updateRequest;
    requestMap[requestBodyKey] = json;

    String messageRequest;

    messageRequest = jsonEncode(requestMap);

    debugPrint("message Request: $messageRequest");

    debugPrint("update request sent");
    String? result;

    await methodChannel
        .invokeMethod(apiMethod, {messageParam: messageRequest})
        .then((value) => result = value)
        .catchError((onError) {
          debugPrint(onError.toString());
          Future.error(onError);
        });

    debugPrint(result);
    return null;
  }
}

class APIHandler {
  static const String apiKey = 'efd329152c084c89a2240700230108';
  static const baseUrl = 'http://api.weatherapi.com/v1/current.json';

  static Future<CurrentWeather> fetchAlbum() async {
    debugPrint("Fetching API");
    String apiUri = '$baseUrl?key=$apiKey&q=hanoi';
    final response = await http.get(Uri.parse(apiUri));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      debugPrint('response: ${response.body}');
      CurrentWeather? weather;
      String location = "undefined";
      String country = "undefined";
      String lastUpdate = "undefined";
      num tempC = 0;
      num windDegree = 0;
      String windDir = "undefined";
      num cloud = 0;
      num uv = 0;

      Map<String, dynamic> result = jsonDecode(response.body);
      result.forEach((key, value) {
        if (key == 'location') {
          location = value['name'];
          country = value['country'];
        } else if (key == 'current') {
          lastUpdate = value['last_updated'];
          tempC = value['temp_c'];
          windDegree = value['wind_degree'];
          windDir = value['wind_dir'];
          cloud = value['cloud'];
          uv = value['uv'];
        }
      });
      weather = CurrentWeather(
          location, country, lastUpdate, tempC, windDegree, windDir, cloud, uv);

      return weather;
    } else {
      debugPrint('code: ${response.statusCode}; body: ${response.body}');
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load weather');
    }
  }
}

class CurrentWeather {
  final String location;
  final String country;
  final String lastUpdate;
  final num tempC;
  final num windDegree;
  final String windDir;
  final num cloud;
  final num uv;

  CurrentWeather(this.location, this.country, this.lastUpdate, this.tempC,
      this.windDegree, this.windDir, this.cloud, this.uv);

  @override
  String toString() {
    return 'CurrentWeather:\nlocation: $location\ncountry: $country\nlastUpdate: $lastUpdate\ntempC: $tempC\nwindDegree: $windDegree\nwindDir: $windDir\ncloud: $cloud\nuv: $uv\n';
  }

  bool isDifferenceWithLastUpdate(CurrentWeather last) {
    return !(last.lastUpdate == lastUpdate);
  }
}
