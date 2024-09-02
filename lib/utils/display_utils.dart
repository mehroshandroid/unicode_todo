import 'package:flutter/material.dart';

void clearStackNavigate(BuildContext context, Widget destination) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => destination,
    ),
  );
}