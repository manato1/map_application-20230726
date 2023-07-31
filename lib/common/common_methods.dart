import 'dart:math';
import 'package:flutter/material.dart';

class CommonMethods{
  void showSnackBar(BuildContext context,text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  createRandamString(){
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length,(_) => chars.codeUnitAt(
            rnd.nextInt(chars.length))));

    //5文字のランダムテキスト
    final String randamString = getRandomString(5);
    return randamString;
  }
}