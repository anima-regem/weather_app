import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/weather_screen.dart';

void main(){
  runApp(const MyApp());
}


class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData.dark(
        useMaterial3: true,
      // ).copyWith(
      //   textTheme: GoogleFonts.poppinsTextTheme(
      //     Theme.of(context).textTheme

      ),
      debugShowCheckedModeBanner: false,
      home: const WeatherScreen(),
    );
  }
}
