import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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
    APIHandler.fetchAlbum().then((value) {
      CurrentWeather newData = value;
      if (data == null || newData.isDifferenceWithLastUpdate(data!)) {
        setState(() {
          data = newData;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build called');
    return Center(
        child: SingleChildScrollView(child: Text(data.toString())));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
      double tempC = 0;
      int windDegree = 0;
      String windDir = "undefined";
      int cloud = 0;
      double uv = 0;

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
  final double tempC;
  final int windDegree;
  final String windDir;
  final int cloud;
  final double uv;

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
