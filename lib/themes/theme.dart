import 'package:flutter/material.dart';

class MainTheme {
  static const int PRIMARY_COLOR_VALUE = 0xFFc39355;

  static Map<int, Color> get primarySwatch => {
        50: Color(0xFFfaf9e9),
        100: Color(0xFFf2eeca),
        200: Color(0xFFeae3a9),
        300: Color(0xFFe3d88c),
        400: Color(0xFFded17a),
        500: Color(0xFFdaca6b),
        600: Color(0xFFd4bb65),
        700: Color(0xFFcca75d),
        800: Color(PRIMARY_COLOR_VALUE),
        900: Color(0xFFb37548),
      };

  static MaterialColor get primaryMaterialColor => MaterialColor(
        PRIMARY_COLOR_VALUE,
        primarySwatch,
      );

  static Color get primaryColor => primaryMaterialColor.shade800;

  static const Color secondaryColor = Color(0xff31708F);
  static const Color errorColor = Color(0xfffb5657);
  static const Color disabledColor = Color(0xffc9c9c9);
  static const Color emergencyColor = Color(0xffe30412);

  static const Color darkGrey = Color(0xff363636);
  static const Color grey = Color(0xff7f7f7f);
  static const Color lightGrey = Color(0xfff1f1f1);

  static Color get backgroundColor => Colors.white;
  static Color get listTileColor => Color(0xfff5f6f7);

  static double elevation = 5;

  static ThemeData get theme => ThemeData(
        primarySwatch: primaryMaterialColor,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          primaryVariant: primaryColor,
          secondary: secondaryColor,
          secondaryVariant: secondaryColor,
          surface: backgroundColor,
        ),
        errorColor: errorColor,
        scaffoldBackgroundColor: backgroundColor,
        dividerColor: lightGrey,
        fontFamily: "Rubik",
        brightness: Brightness.light,
        primaryColorBrightness: Brightness.dark,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: primaryColor,
          contentTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        primaryIconTheme: IconThemeData(
          color: primaryColor,
        ),
        accentIconTheme: IconThemeData(
          color: primaryColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              const Set<MaterialState> interactiveStates = <MaterialState>{
                MaterialState.disabled,
              };
              if (states.any(interactiveStates.contains)) {
                return disabledColor;
              }
              return primaryColor;
            }),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            side: MaterialStateProperty.resolveWith((states) {
              const Set<MaterialState> interactiveStates = <MaterialState>{
                MaterialState.disabled,
              };
              if (states.any(interactiveStates.contains)) {
                return BorderSide(
                  color: disabledColor,
                  width: 2,
                );
              }
              return BorderSide(
                color: primaryColor,
                width: 2,
              );
            }),
            foregroundColor: MaterialStateProperty.resolveWith((states) {
              const Set<MaterialState> interactiveStates = <MaterialState>{
                MaterialState.disabled,
              };
              if (states.any(interactiveStates.contains)) {
                return disabledColor;
              }
              return primaryColor;
            }),
            minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: elevation,
          color: backgroundColor,
          textTheme: TextTheme(
            headline6: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkGrey,
            ),
          ),
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: primaryColor,
          ),
          actionsIconTheme: IconThemeData(
            color: primaryColor,
          ),
        ),
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
/*         pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
          },
        ), */

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          disabledElevation: elevation,
          elevation: elevation,
          focusElevation: elevation,
          highlightElevation: elevation,
          hoverElevation: elevation,
        ),
        textTheme: textTheme,
        dividerTheme: DividerThemeData(
          color: lightGrey,
          thickness: 1,
        ),
        buttonTheme: ButtonThemeData(
          height: 50,
          buttonColor: primaryColor,
          minWidth: double.infinity,
          disabledColor: disabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: disabledColor,
          labelColor: primaryColor,
          labelPadding: EdgeInsets.all(2),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 5.0,
              color: primaryColor,
            ),
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 16,
          ),
          labelStyle: TextStyle(
            fontSize: 16,
          ),
        ),
        inputDecorationTheme: inputTheme,
        cardTheme: CardTheme(
          elevation: elevation,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  static TextTheme get textTheme => TextTheme(
        headline1: TextStyle(
          fontSize: 32,
          color: darkGrey,
        ),
        headline2: TextStyle(
          fontSize: 24,
          color: darkGrey,
        ),
        headline3: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: darkGrey,
        ),
        headline4: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
        headline5: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: grey,
        ),
        headline6: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
        subtitle1: TextStyle(
          fontSize: 16,
        ),
        subtitle2: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkGrey,
        ),
        button: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyText1: TextStyle(
          color: darkGrey,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyText2: TextStyle(
          color: grey,
          fontSize: 14,
        ),
      );

  static InputDecorationTheme get inputTheme => InputDecorationTheme(
        errorMaxLines: 1,
        contentPadding: EdgeInsets.fromLTRB(20, 23, 20, 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: Color(0xffdfe1e5),
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        labelStyle: TextStyle(
          fontSize: 16,
          color: grey,
          fontWeight: FontWeight.normal,
        ),
        hintStyle: TextStyle(
          color: grey,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: primaryColor,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: grey,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: errorColor,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: errorColor,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        fillColor: Color(0xffefeff0),
      );
}
