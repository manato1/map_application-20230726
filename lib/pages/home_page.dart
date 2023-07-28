import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_application_20230726/pages/map.dart';

import '../widgets/common_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    // ロケーションのパーミッションを確認
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // ユーザーがパーミッションを拒否した場合の処理
      print('ロケーションのパーミッションが拒否されました');
    } else if (permission == LocationPermission.deniedForever) {
      // ユーザーがパーミッションを永久に拒否した場合の処理
      print('ロケーションのパーミッションが永久に拒否されました');
    } else {
      // パーミッションが許可された場合の処理
      print('ロケーションのパーミッションが許可されました');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('ff'),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              // title: Text("title",style: TextStyle(color: Colors.black),),
              background: Container(
                // margin: EdgeInsets.only(right: 80),
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10), // 余白を追加
                child: Row(
                  children: [
                    Image.asset(
                      "images/undraw_Destination_re_sr74.png",
                      // fit: BoxFit.cover,
                    ),
                    Text(
                      "title",
                      style: TextStyle(color: Colors.black, fontSize: 26),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 160),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    height: 7,
                    width: 40,
                    margin: EdgeInsets.only(bottom: 60),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      HomeButton1(
                          iconData: Icons.map, label: 'マップ', color: Colors.red,widget: MapPage()),
                      HomeButton1(
                          iconData: Icons.location_on,
                          label: 'マーカー',
                          color: Colors.blue,widget: MapPage()),
                      HomeButton1(
                          iconData: Icons.format_list_bulleted,
                          label: 'カテゴリー',
                          color: Colors.orange,widget: MapPage()),
                      // _buildButton1(Icons.accessible, 'ボタン4', Colors.green),
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          HomeButton2(label: 'ボタン1'),
                          HomeButton2(label: 'ボタン1'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          HomeButton2(label: 'ボタン1'), // _catButton(
                          //     'ボタン1'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton1(IconData iconData, String label, Color color) {
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

  Widget _catButton(String label) {
    return Container(
      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(40, 10, 40, 13),
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
