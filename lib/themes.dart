// This class contains the theme, logo, and other important values/widgets used throughout the app

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// This theme variable is used to keep design consistent throughout the application
final theme = ThemeData(
  colorScheme:
      ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 11, 83, 148)),
  useMaterial3: true,
  primaryColorLight: const Color.fromARGB(255, 111, 168, 220),
  fontFamily: GoogleFonts.montserrat().fontFamily,
  navigationBarTheme: NavigationBarThemeData(
    labelTextStyle: MaterialStateProperty.all<TextStyle?>(
      GoogleFonts.courierPrime(),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      minimumSize: const Size.fromHeight(40),
      backgroundColor: const Color.fromARGB(255, 11, 83, 148),
      foregroundColor: Colors.white,
      //textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textTheme: TextTheme(
      headlineLarge: TextStyle(
          fontFamily: GoogleFonts.courierPrime().fontFamily, fontSize: 27.5),
      headlineMedium: TextStyle(
          fontFamily: GoogleFonts.courierPrime().fontFamily, fontSize: 25),
      headlineSmall: TextStyle(
          fontFamily: GoogleFonts.courierPrime().fontFamily, fontSize: 18),
      bodyLarge: TextStyle(
          fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 16),
      bodyMedium: TextStyle(
          fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 14.5),
      bodySmall: TextStyle(
          fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 12),
      displayLarge: TextStyle(
          fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 29),
      displayMedium:
          TextStyle(fontFamily: GoogleFonts.baloo2().fontFamily, fontSize: 25),
      displaySmall: TextStyle(
          fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 19)),
);

// This is the main logo that I'm using for my app.
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

final shadow = BoxShadow(
  color: Colors.grey.withOpacity(0.5),
  spreadRadius: 2,
  blurRadius: 5,
  offset: const Offset(0, 3),
);

class InkWellBox extends StatelessWidget {
  const InkWellBox(
      {super.key,
      required this.maxWidth,
      required this.maxHeight,
      required this.child,
      required this.color,
      this.onTap});

  final double maxWidth;
  final double maxHeight;
  final Widget child;
  final Color color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.blueGrey.withOpacity(0.2),
      splashColor: Colors.blueGrey.withOpacity(0.5),
      child: Ink(
        decoration: BoxDecoration(
          boxShadow: [shadow],
          borderRadius: BorderRadius.circular(10),
          color: color,
        ),
        child: Container(
          constraints:
              BoxConstraints.tightFor(width: maxWidth, height: maxHeight),
          padding: const EdgeInsets.all(15.0),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
