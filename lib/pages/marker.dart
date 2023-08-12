import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_application_20230726/pages/add_marker.dart';
import 'package:map_application_20230726/pages/map.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_widgets.dart';
import 'category_page.dart';

class MarkerPage extends StatefulWidget {
  const MarkerPage({
    super.key,
    required this.value,
  });

  final String value;

  @override
  State<MarkerPage> createState() => _MarkerPageState();
}

class _MarkerPageState extends State<MarkerPage> {
  List<String>? markerIdList;
  List<List<String>> markerList = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? catId;

  //マーカーのリスト作成
  getMarkerList() async {
    //markerListの初期化
    markerList = [];
    SharedPreferences prefs = await _prefs;
    markerIdList = prefs.getStringList("markerIdList");
    print("idリスト $markerIdList");
    if (markerIdList != null) {
      for (var i = 0; i < markerIdList!.length; i++) {
        final List<String>? marker = prefs.getStringList(markerIdList![i]);
        if (marker != null) {
          //カテゴリー指定あり
          if (catId != "") {
            print("カテゴリー指定あり");
            if (marker[0] == catId) {
              //カテゴリー一致
              String? cat = "";
              //もしカテゴリー設定されていたらカテゴリー名取得
              if (marker[0] != "") {
                final catName = prefs.getString(marker[0]);
                if (catName != null) {
                  cat = catName;
                }
              }
              final id = markerIdList![i];
              final title = marker[1];
              final text = marker[2];
              final address = marker[3];
              final latitude = marker[4];
              final longitude = marker[5];
              markerList
                  .add([id, cat, title, text, address, latitude, longitude]);
            }
          } else {
            //カテゴリー指定なし
            String? cat = "";
            //もしカテゴリー設定されていたらカテゴリー名取得
            if (marker[0] != "") {
              final catName = prefs.getString(marker[0]);
              if (catName != null) {
                cat = catName;
              }
            }
            final id = markerIdList![i];
            final title = marker[1];
            final text = marker[2];
            final address = marker[3];
            final latitude = marker[4];
            final longitude = marker[5];
            markerList
                .add([id, cat, title, text, address, latitude, longitude]);
          }
        }
      }
      print("マーカーリスト $markerList");
      setState(() {});
    }
  }

  Future _deleteMarker(BuildContext context, markerId) async {
    // (2) showDialogでダイアログを表示する
    var ret = await showDialog(
        context: context,
        // (3) AlertDialogを作成する
        builder: (context) => AlertDialog(
              title: Text("マーカーを削除してもよろしいですか"),
              // (4) ボタンを設定
              actions: [
                TextButton(
                    onPressed: () async {
                      //削除処理
                      markerIdList!.remove(markerId);
                      SharedPreferences prefs = await _prefs;
                      prefs.setStringList("markerIdList", markerIdList!);
                      await prefs.remove(markerId);
                      Navigator.pop(context, true);
                      getMarkerList();
                    },
                    child: Text("はい")),
              ],
            ));
    // getMarkerList();
  }

  @override
  void initState() {
    super.initState();

    catId = widget.value;
    getMarkerList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("マーカー"),
      ),
      body: Container(
          child: markerIdList != null
              ? SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: markerList.length, // リストに表示するアイテムの数を指定
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                        child: ListTile(
                          tileColor: Colors.grey[300],
                          title: Text(markerList[index][1] != ""
                              ? "${markerList[index][2]} - ${markerList[index][1]}"
                              : markerList[index][2]),
                          subtitle: Text(markerList[index][4] != ""
                              ? "${markerList[index][4]}\n${markerList[index][3]}"
                              : markerList[index][3]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // 削除確認
                              _deleteMarker(context, markerList[index][0]);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    // （2） 実際に表示するページ(ウィジェット)を指定する
                                    builder: (context) => MapPage(
                                          value: [markerList[index][0]],
                                          value2: markerList[index][2],
                                        )));
                          },
                        ),
                      );
                    }),
              )
              : Center(child: Text("マーカーはありません"))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                // （2） 実際に表示するページ(ウィジェット)を指定する
                builder: (context) => AddMarkerPage(),
                fullscreenDialog: true,
              ));
          getMarkerList();
        },
        child: Icon(Icons.add), // プラスアイコンを設定
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // ボタンを右下に配置
    );
  }
}
