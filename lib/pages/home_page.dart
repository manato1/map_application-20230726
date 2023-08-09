import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_application_20230726/common/common_methods.dart';
import 'package:map_application_20230726/pages/map.dart';
import 'package:map_application_20230726/pages/marker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_widgets.dart';
import 'category_page.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> catList = []; //カテゴリーのIDのリスト
  List<List<String>> categoryList = []; //[id,cat_name]のリスト

  getCat() async {
    var prefs = await SharedPreferences.getInstance();
    catList = prefs.getStringList("catIdList") ?? [];
    print("cat id$catList");
    if (catList.isNotEmpty) {
      List<List<String>> list = [];
      for (var i = 0; i < catList!.length; i++) {
        final String catId = catList![i];
        final String catName = prefs.getString(catId) ?? "";
        list.add([catId, catName]);
      }
      setState(() {
        categoryList = list;
      });
      print("cat list$categoryList");
    }
  }

  int countDivisionsByTwo(int number) {
    int count = 0;
    while (number % 2 == 0) {
      number = number ~/ 2;
      count++;
    }
    return count;
  }

  getItemCount(List list) {
    int count;
    if (list.length % 2 == 1) {
      count = list.length ~/ 2 + 1;
    } else {
      count = list.length ~/ 2;
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    getCat();
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      "images/undraw_Destination_re_sr74.png",
                      width: 200,
                      // fit: BoxFit.cover,
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
                          iconData: Icons.map,
                          label: 'マップ',
                          color: Colors.red,
                          widget: MapPage(value:[],value2: "",)),
                      HomeButton1(
                          iconData: Icons.location_on,
                          label: 'マーカー',
                          color: Colors.blue,
                          widget: MarkerPage(value: "",)),
                      Container(
                        width: double.infinity,
                        height: 70,
                        margin: EdgeInsets.fromLTRB(40.0, 10, 40, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orange, // background
                          ),
                          onPressed: () async {
                            // ボタンが押された時の処理
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    // （2） 実際に表示するページ(ウィジェット)を指定する
                                    builder: (context) => CategoryPage()));
                            getCat();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.format_list_bulleted,
                                  color: Colors.white, size: 30),
                              SizedBox(width: 8),
                              Text(
                                "カテゴリー",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  // TextButton(
                  //     onPressed: () async {
                  //       var prefs = await SharedPreferences.getInstance();
                  //       final bool ok = await prefs.clear();
                  //     },
                  //     child: Text("remove deta")),
                  categoryList.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.fromLTRB(10,0,10,0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: (categoryList.length / 2).ceil(),
                            // リストに表示するアイテムの数を指定
                            itemBuilder: (BuildContext context, int index) {
                              int firstIndex = index * 2;
                              int secondIndex = firstIndex + 1;
                              if (firstIndex < categoryList.length) {
                                return Wrap(
                                  // spacing: 8.0, // 横方向の要素間のスペース
                                  // runSpacing: 8.0, // 縦方向の要素間のスペース
                                  children: [
                                    HomeButton2(
                                      label:
                                          '${categoryList[firstIndex][1]}',
                                      id: categoryList[firstIndex][0],
                                    ),
                                    if (secondIndex < categoryList.length)
                                      HomeButton2(
                                          label:
                                              '${categoryList[secondIndex][1]}',
                                          id: categoryList[secondIndex][0]),
                                  ],
                                );
                              }
                            }),
                      )
                      : SizedBox.shrink(),
                  SizedBox(height: 70,),
                  TextButton(
                      onPressed: () {
                        CommonMethods().launchURL('https://manama-joho.com/map-application/privacy-policy/');
                      },
                      child: Text('プライバシーポリシー'))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
