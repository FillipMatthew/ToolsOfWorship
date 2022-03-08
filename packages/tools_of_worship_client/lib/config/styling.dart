import 'package:flutter/material.dart';

// Theme colours
// #28363D
const Color backgroundColour = Color(0xFF28363D);
// #2F575D
const Color backgroundVariantColour = Color(0xFF2F575D);
// #658B6F
const Color primaryContainerColour = Color(0xFF658B6F);
// #6D9197
const Color primaryColour = Color(0xFF6D9197);
// #99AEAD
const Color secondaryContainerColour = Color(0xFF99AEAD);
// #C4CDC1
const Color secondaryColour = Color(0xFF99AEAD);
// #DEE1DD

const ColorScheme defaultColourScheme = ColorScheme(
    primary: primaryColour,
    primaryContainer: primaryContainerColour,
    secondary: secondaryColour,
    secondaryContainer: secondaryContainerColour,
    surface: backgroundVariantColour,
    background: backgroundColour,
    error: Colors.black,
    onPrimary: backgroundColour,
    onSecondary: primaryContainerColour,
    onSurface: secondaryContainerColour,
    onBackground: primaryColour,
    onError: Colors.red,
    brightness: Brightness.dark);

const double defaultPadding = 8.0;
