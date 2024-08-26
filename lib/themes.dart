// This file contains the theme, logo, and other important values/widgets used throughout the app

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

// This is a predefined class with color values used throughout the app
class ConstColors {
  static const background = Color.fromRGBO(238, 238, 238, 1);
  static const red = Color.fromRGBO(183, 28, 28, 1);
  static const yellow = Color.fromRGBO(251, 192, 45, 1);
  static const green = Color.fromRGBO(46, 125, 50, 1);
  static const primary = Color.fromARGB(255, 8, 70, 125);
  static const shadeLight = Color.fromARGB(255, 116, 189, 234);
  static const shade = Color.fromARGB(255, 87, 158, 201);
  static const shadeDark = Color.fromARGB(255, 74, 123, 154);
  static const grey = Color.fromARGB(255, 221, 221, 221);
}

// This theme variable is used to keep design consistent throughout the application
final theme = ThemeData(
  // These are the colors used
  colorScheme: ColorScheme.fromSeed(seedColor: ConstColors.primary),
  useMaterial3: true,
  fontFamily: GoogleFonts.montserrat().fontFamily,

  // These are themes for various widgets in the app
  navigationBarTheme: NavigationBarThemeData(
    indicatorColor: ConstColors.shade,
    // This background color is different from the constant grey
    backgroundColor: Colors.grey[300],
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      minimumSize: const Size.fromHeight(42.5),
      backgroundColor: ConstColors.primary,
      foregroundColor: Colors.white,
    ),
  ),
  snackBarTheme: const SnackBarThemeData(backgroundColor: ConstColors.primary),
  scaffoldBackgroundColor: ConstColors.background,
  iconButtonTheme: const IconButtonThemeData(
    style: ButtonStyle(iconColor: WidgetStatePropertyAll(ConstColors.primary)),
  ),

  // These are the set text styles
  textTheme: TextTheme(
    // Used in logo, quiz titles, and error page
    headlineMedium: TextStyle(
        fontFamily: GoogleFonts.courierPrime().fontFamily, fontSize: 25),
    // Used for summary info labels
    headlineSmall: TextStyle(
        fontFamily: GoogleFonts.courierPrime().fontFamily, fontSize: 18),
    // Used throughout auth, quiz, and profile pages
    bodyLarge: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 16),
    bodyMedium: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 14.5),
    // Used for error text on error page
    bodySmall: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 13),
    // Used for page headers and summary info
    displayLarge: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 29),
    displayMedium:
        TextStyle(fontFamily: GoogleFonts.baloo2().fontFamily, fontSize: 25),
    // Used on auth pages and question text
    displaySmall: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 19),
    // Used throughout for small text and labels
    labelSmall: TextStyle(
        fontFamily: GoogleFonts.courierPrime().fontFamily, fontSize: 13),
  ),
);

// This is the main logo used in the app
Widget logo(CrossAxisAlignment align) {
  return Column(
    crossAxisAlignment: align,
    children: [
      RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: GoogleFonts.courierPrime().fontFamily,
            fontSize: 25,
            color: Colors.black,
          ),
          children: <TextSpan>[
            const TextSpan(text: '5 Minute '),
            TextSpan(
              text: 'संस्कृतम् ।',
              style: TextStyle(
                fontFamily: GoogleFonts.baloo2().fontFamily,
                fontSize: 25,
                color: ConstColors.primary,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          'by संस्कृतभरति USA ©',
          style: theme.textTheme.labelSmall!.copyWith(height: 0.5),
        ),
      ),
    ],
  );
}

// This is a condensed version of the logo used for smaller screen sizes
const condensedLogo = Image(
  image: AssetImage('assets/logo.png'),
  height: 35,
);

// This is the animated logo that is displayed during loading
Widget animatedLogo(BuildContext context, bool animate) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The logo can be animated or static
          (animate)
              ? AnimatedTextKit(
                  isRepeatingAnimation: false,
                  repeatForever: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      '5 Minute',
                      textStyle: Theme.of(context).textTheme.headlineMedium,
                      cursor: '।',
                      speed: const Duration(milliseconds: 200),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(6, 5, 0, 0),
                  child: Text(
                    '5 Minute ',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
          (animate)
              ? AnimatedTextKit(
                  pause: const Duration(milliseconds: 3000),
                  isRepeatingAnimation: false,
                  repeatForever: false,
                  animatedTexts: [
                    TyperAnimatedText(''),
                    TypewriterAnimatedText(
                      'संस्कृतम् ।',
                      textStyle:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                color: ConstColors.primary,
                              ),
                      cursor: '।',
                      speed: const Duration(milliseconds: 200),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                  child: Text(
                    'संस्कृतम् । ',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: ConstColors.primary,
                        ),
                  ),
                ),
          const SizedBox(height: 10),
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: ConstColors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}

// This is the standard shadow used throughout the app
final shadow = BoxShadow(
  color: Colors.grey.withOpacity(0.5),
  spreadRadius: 2,
  blurRadius: 5,
  offset: const Offset(0, 3),
);

// This is a custom box widget used throughout the app
class InkWellBox extends StatelessWidget {
  const InkWellBox({
    super.key,
    this.maxWidth,
    this.maxHeight,
    required this.child,
    required this.color,
    this.onTap,
  });

  final double? maxWidth;
  final double? maxHeight;
  final Widget child;
  final Color color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: ConstColors.shadeDark.withOpacity(0.2),
      splashColor: ConstColors.shadeDark.withOpacity(0.5),
      borderRadius: BorderRadius.circular(10),
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
          child: child,
        ),
      ),
    );
  }
}

// This is a custom box widget used throughout the app
class FloatingBox extends StatelessWidget {
  const FloatingBox({super.key, required this.child, this.padding = 20.0});
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [shadow],
      ),
      child: child,
    );
  }
}

// This is a method for showing a snack bar without a local BuildContext
showTextSnackBar(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
    content: Text(message),
  ));
}

// This custom widget displays text as a bullet point with proper formatting
class BulletPoint extends StatelessWidget {
  const BulletPoint({super.key, required this.text, required this.textStyle});

  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(' • ', style: textStyle),
          Expanded(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}

// This custom widget displays a text paragraph with proper formatting and spacing
class Paragraph extends StatelessWidget {
  const Paragraph({
    super.key,
    required this.content,
    required this.bulletContent,
    required this.postContent,
    this.title = "",
  });

  final String content;
  final List<String> bulletContent;
  final String postContent;
  final String title;

  @override
  Widget build(BuildContext context) {
    // Text style and spacing changes based on screen size
    bool smallScreen = isSmallScreen(context);

    TextStyle? titleStyle = (smallScreen)
        ? Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1)
        : Theme.of(context).textTheme.displaySmall;

    TextStyle? contentStyle = (smallScreen)
        ? Theme.of(context).textTheme.bodyMedium
        : Theme.of(context).textTheme.bodyLarge;

    double spacing = (smallScreen) ? 2.5 : 5;

    // A paragraph contains an optional title, initial text, bullet points, and further text
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: titleStyle!.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(),
        ],
        SizedBox(height: spacing),
        if (content.isNotEmpty)
          Text(
            content,
            style: contentStyle,
          ),
        ...bulletContent.map(
          (text) => BulletPoint(
            text: text,
            textStyle: contentStyle,
          ),
        ),
        SizedBox(height: spacing),
        if (postContent.isNotEmpty)
          Text(
            postContent,
            style: contentStyle,
          ),
      ],
    );
  }
}

// This method checks whether text is in Sanskrit, or Devanagari script
// If it is, the font size is slightly larger
bool isSanskrit(String text) {
  var sanskrit = RegExp(r'[\u0900-\u097F]');
  return sanskrit.hasMatch(text);
}

// This method checks whether the current screen is small
bool isSmallScreen(BuildContext context) {
  return MediaQuery.of(context).size.width <= 500;
}
