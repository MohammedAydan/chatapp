import 'package:flutter/material.dart';

Widget getUserAvatar(String email) {
  // Get the first letter from email (uppercase)
  String firstLetter = email.isNotEmpty ? email[0].toUpperCase() : '?';

  // Generate a color based on email string
  int hashCode = email.hashCode;
  final color = Colors.primaries[hashCode.abs() % Colors.primaries.length];

  return CircleAvatar(
    backgroundColor: color,
    child: Text(
      firstLetter,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  );
}
