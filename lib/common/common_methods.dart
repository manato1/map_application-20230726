import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void storageMarker(BuildContext context,String category, String title, String text,String address, double latitude, double longitude) async {
    var prefs = await SharedPreferences.getInstance();
    final List<String>? idList = prefs.getStringList("markerIdList");
    final String id = CommonMethods().createRandamString();

    //まだ一つも登録していなければ
    try {
      if (idList == null) {
        prefs.setStringList("markerIdList", [id]);
        prefs.setStringList(id, [category, title, text, address, latitude.toString(), longitude.toString()]);
      } else {
        //idリストにid追加
        idList.add(id);
        prefs.setStringList("markerIdList", idList);
        prefs.setStringList(id, [category, title, text, address, latitude.toString(), longitude.toString()]);
      }
      CommonMethods().showSnackBar(context, "マーカーを追加しました。");
    } catch (e) {
      CommonMethods().showSnackBar(context, "マーカーを追加できませんでした。");
    }
  }
}