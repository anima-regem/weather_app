import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final IconData icon;
  final String time, value;
  const WeatherCard({
    super.key,
    required this.icon,
    required this.time,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Text(
                time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Icon(icon, size: 32),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(fontSize: 14),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}