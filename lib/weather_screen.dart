import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/weather_info_item.dart';
import 'package:weather_app/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  String city = "";

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final res = await http.get(Uri.parse(
        "http://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$openWeatherAPIKey"));
    final data = jsonDecode(res.body);

    if (data['cod'] != "200") {
      throw "An unexpected error occurred";
    } else {
      return data;
    }
  }

  void getStoredLocation() async {
    final prefs = await SharedPreferences.getInstance();
    city = prefs.getString("city") ?? "Palakkad";
    setState(() {
      weather = getCurrentWeather(city);
    });
  }

  void saveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("city", city);
  }

  double convertToC(num kelvinTemp) {
    return (kelvinTemp - 273.15).roundToDouble();
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather(city);
    getStoredLocation();
  }

  @override
  void dispose() {
    saveLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather App - ${toBeginningOfSentenceCase(city)}",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather(city);
                });
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  enabled: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    hintText: "Enter City",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    )),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      city = value.trim();
                      weather = getCurrentWeather(city);
                      saveLocation();
                    });
                  },
                ),
              ),
            ),
            FutureBuilder(
                future: weather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error Occurred"),
                    );
                  }
                  final currentWeatherData = snapshot.data!['list'][0];
                  final weather = currentWeatherData['main']['temp'];
                  final currentType = currentWeatherData['weather'][0]['main'];
                  final currentHumidity =
                      currentWeatherData['main']['humidity'];
                  final currentWindSpeed = currentWeatherData['wind']['speed'];
                  final currentPressure =
                      currentWeatherData['main']['pressure'];

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: double.infinity,
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Text(
                                              "${convertToC(weather)}°C",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 32),
                                            ),
                                            const SizedBox(height: 16),
                                            Icon(
                                              currentType == 'Clouds' ||
                                                      currentType == 'Rain'
                                                  ? Icons.cloud
                                                  : Icons.sunny,
                                              size: 64,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              currentType,
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              )),
                          const SizedBox(height: 20),
                          const Text(
                            "Hourly Forecast",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            height: 125,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final time = DateTime.parse(
                                      snapshot.data!['list'][index]['dt_txt']);
                                  return WeatherCard(
                                    time:
                                        DateFormat.j().format(time).toString(),
                                    value:
                                        "${convertToC(snapshot.data!['list'][index]['main']['temp'])} °C",
                                    icon: snapshot.data!['list'][index]
                                                    ['weather'][0]['main'] ==
                                                'Rain' ||
                                            snapshot.data!['list'][index]
                                                    ['weather'][0]['main'] ==
                                                'Clouds'
                                        ? Icons.cloud
                                        : Icons.sunny,
                                  );
                                },
                                itemCount: snapshot.data!['list'].length),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Additional Information",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AdditionalInfoItem(
                                  icon: Icons.water_drop,
                                  text: "Humidity",
                                  value: "$currentHumidity%",
                                ),
                                AdditionalInfoItem(
                                  icon: Icons.air,
                                  text: "Wind Speed",
                                  value: "$currentWindSpeed km/h",
                                ),
                                AdditionalInfoItem(
                                  icon: Icons.beach_access,
                                  text: "Pressure",
                                  value: "$currentPressure hPa",
                                ),
                              ])
                        ]),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
