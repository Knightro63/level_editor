import 'package:flutter/material.dart';
import 'globals.dart';

//CSS
const Color lightBlue = Color(0xFF06A7E2);
const Color lightBlueBG = Color(0xFF4ac8f6);
const Color darkBlue = Color(0xFF024273);
const Color darkGreen = Color(0xff39ac50);
const Color lightGreen = Color(0xff53d16c);
const Color lightGrey = Color(0xffeeeeee);
const Color darkGrey = Color(0xff989898);
const Color purple = Color(0xff865ab3);
const Color yellow = Color(0xffea991f);

const Color chartNameGrey = Color(0xff8e8e8e);
const Color chartGrey = Color(0xff414141);
const Color chartRed = Color(0xffe64e46);
const Color chartGreen = Color(0xff3ea553);
const Color chartRedT = Color(0x88e64e46);
const Color chartGreenT = Color(0x883ea553);

const Color blur = Color(0x99414141);

const Color darkGreenT = Color(0x7739ac50);
const Color lightGreenT = Color(0x9953d16c);
const Color lightBlueT = Color(0x9906A7E2);

TextStyle icon_stlye = TextStyle(fontSize: 8, fontFamily: 'MuseoSans Bold');

class CSS{
  static ThemeData darkTheme = new ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkBlue,
    accentColor: lightBlue,
    cardColor: Colors.grey[850],
    canvasColor: Colors.grey[900],
    splashColor: Colors.grey[900],
    hoverColor: Colors.grey[700],
    shadowColor: Colors.black,//Colors.grey[750],
    indicatorColor: Colors.grey[850],
    secondaryHeaderColor: lightBlue,
    selectedRowColor: Colors.grey[800],
    scrollbarTheme: ScrollbarThemeData(isAlwaysShown: true, showTrackOnHover: true),
    primaryTextTheme: TextTheme(
      headline1: TextStyle(
        color: lightBlue,
        fontFamily: 'Klavika Bold',
        fontSize: 36
      ),
      headline2: TextStyle(
        color: lightBlue,
        fontFamily: 'Klavika Bold',
        fontSize: 30
      ),
      headline3: TextStyle(
        color: lightBlue,
        fontFamily: 'Klavika Bold',
        fontSize: 24
      ),
      headline4: TextStyle(
        color: lightBlue,
        fontFamily: 'Klavika Bold',
        fontSize: 18
      ),

      bodyText1: TextStyle(
        color: lightGrey,
        fontFamily: 'Klavika Bold',
        fontSize: 24
      ),
      bodyText2: TextStyle(
        color: lightGrey,
        fontFamily: 'Klavika',
        fontSize: 18
      ),
      subtitle1: TextStyle(
        height: 1.5,
        color: lightGrey,
        fontFamily: 'MuesoSans Bold',
        fontSize: 12
      ),
      subtitle2: TextStyle(
        color: lightGrey,
        fontFamily: 'MuesoSans Bold',
        fontSize: 10
      ),
    )
  );
  static ThemeData lightTheme = new ThemeData(
    brightness: Brightness.light,
    primaryColor: lightBlue,
    accentColor: lightBlue,
    cardColor: Color(0xfffdfdfd),
    canvasColor: Color(0xffdddddd),
    splashColor: Color(0xfff3f3f3),
    hoverColor: Colors.grey[350],
    shadowColor: Colors.grey[500],
    indicatorColor: Colors.white,
    selectedRowColor: darkGrey,
    primaryTextTheme: TextTheme(
      headline1: TextStyle(
        color: darkBlue,
        fontFamily: 'Klavika Bold',
        fontSize: 36
      ),
      headline2: TextStyle(
        color: darkBlue,
        fontFamily: 'Klavika Bold',
        fontSize: 30
      ),
      headline3: TextStyle(
        color: darkBlue,
        fontFamily: 'Klavika Bold',
        fontSize: 24
      ),
      headline4: TextStyle(
        color: darkBlue,
        fontFamily: 'Klavika Bold',
        fontSize: 24
      ),
      bodyText1: TextStyle(
        color: darkGrey,
        fontFamily: 'Klavika',
        fontSize: 24
      ),
      bodyText2: TextStyle(
        color: darkGrey,
        fontFamily: 'Klavika',
        fontSize: 18
      ),
      subtitle1: TextStyle(
        color: Colors.grey[900],
        fontFamily: 'MuesoSans Bold',
        fontSize: 12
      ),
      subtitle2: TextStyle(
        color: darkGrey,
        fontFamily: 'MuesoSans Bold',
        fontSize: 10
      ),
    )
  );

  static Color darken(Color color, [double amount = .1]) {
    if(amount > 1)
      amount = 1;
    else if(amount < 0)
      amount = 0;

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    if(amount > 1)
      amount = 1;
    else if(amount < 0)
      amount = 0;

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  static double responsive({double width = 0}){
    width = (width != 0)?width:deviceWidth;
    if(deviceWidth < 650)
      return deviceWidth-20;
    else if(deviceWidth < 1000)
      return deviceWidth/2-20;
    else
      return deviceWidth/3-20;
  }
  static double responsive2(){
    if(deviceWidth < 1070-67)
      return deviceWidth-20;
    else
      return deviceWidth/2-20;
  }
  static double responsiveHeight(){
    if(deviceWidth < 470)
      return 500;
    else if(deviceWidth < 530)
      return deviceWidth/1.25;
    else if(deviceWidth < 1200)
      return (500-20)/1.25;
    else
      return 750/1.25;
  }
}

//List<String> 