import 'package:flutter/material.dart';
class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final String text, value;
  const AdditionalInfoItem({
    super.key,
    required this.icon,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Icon(icon, size: 32),
          Text(text,
              style: TextStyle(
                fontSize: 16,
              )),
          Text(value),
        ]);
  }
}