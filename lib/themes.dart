import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  colorScheme:
      ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 11, 83, 148)),
  useMaterial3: true,
  primaryColorLight: const Color.fromARGB(255, 111, 168, 220),
  fontFamily: GoogleFonts.montserrat().fontFamily,
  navigationBarTheme: NavigationBarThemeData(
      labelTextStyle:
          MaterialStateProperty.all<TextStyle?>(GoogleFonts.courierPrime())),
);

final logo = RichText(
  text: TextSpan(
    style: TextStyle(
        fontFamily: GoogleFonts.courierPrime().fontFamily, fontSize: 25),
    children: <TextSpan>[
      const TextSpan(text: '5 Minute '),
      TextSpan(
        text: 'संस्कृतम् ।',
        style: TextStyle(
            fontFamily: GoogleFonts.baloo2().fontFamily, fontSize: 25),
      ),
    ],
  ),
);
