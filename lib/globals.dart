// used for technical error that user doesn't need to know so the security risk of the technical error message used by others will be minimized
import 'package:flutter/material.dart';

final String generalErrorMessage = "Oops, something went wrong, please try again";

final int limitDataPerLoad = 10;

// primary color
const Color primaryYellow = Color(0xFFF7CE3D);

// primary loading indicator
CircularProgressIndicator loadingProgressIndicator = CircularProgressIndicator(
  backgroundColor: Colors.white,
  valueColor: const AlwaysStoppedAnimation<Color>(
    primaryYellow,
  ),
);

String toTitleCase(String text) { 
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

final List<Color> avatarColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.brown,
  Colors.pink,
];

Color getBackgroundColor(String userName) {
  final index = userName.hashCode % avatarColors.length;
  return avatarColors[index];
}
