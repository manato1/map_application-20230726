import 'package:flutter/material.dart';
import 'package:map_application_20230726/pages/home_page.dart';
import 'package:map_application_20230726/pages/marker.dart';

import '../pages/map.dart';

class HomeButton1 extends StatelessWidget {
  const HomeButton1({
    super.key,
    required this.iconData,
    required this.label,
    required this.color,
    required this.widget,
  });

  final IconData iconData;
  final String label;
  final Color color;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      margin: EdgeInsets.fromLTRB(40.0, 10, 40, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: color, // background
        ),
        onPressed: () {
          // ボタンが押された時の処理
          Navigator.push(
              context,
              MaterialPageRoute(
                  // （2） 実際に表示するページ(ウィジェット)を指定する
                  builder: (context) => widget));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(iconData, color: Colors.white, size: 30),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeButton2 extends StatelessWidget {
  const HomeButton2({
    super.key,
    required this.label,
    required this.id,

  });

  final String label;
  final String id;


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottonWidth = screenWidth / 2 - 60;
    return Container(
      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
      // padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ElevatedButton(
        onPressed: () {
          // ボタンが押されたときの処理
          Navigator.push(
              context,
              MaterialPageRoute(
                // （2） 実際に表示するページ(ウィジェット)を指定する
                  builder: (context) => MarkerPage(value: id)));
        },
        style: ElevatedButton.styleFrom(
          fixedSize: Size(bottonWidth, 50.0), // ボタンのサイズを指定
        ),
        child: TruncatedText(
          label,
          maxChars: 10, // 30文字を超えた場合には「...」を表示
        ),
    ));
    //   Container(
    //   margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
    //   padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
    //   decoration: BoxDecoration(
    //     color: Colors.blueAccent,
    //     borderRadius: BorderRadius.circular(10.0),
    //   ),
    //   child: TextButton(
    //     child: Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
    //     onPressed: () {
    //
    //        Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             // （2） 実際に表示するページ(ウィジェット)を指定する
    //               builder: (context) => MarkerPage(value: id)));
    //
    //     },
    //   ),
    // );
  }
}
class TruncatedText extends StatelessWidget {
  final String text;
  final int maxChars;

  TruncatedText(this.text, {required this.maxChars});

  @override
  Widget build(BuildContext context) {
    if (text.length <= maxChars) {
      return Text(text);
    } else {
      final truncatedText = text.substring(0, maxChars) + '...';
      return Text(truncatedText);
    }
  }
}