import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_application_20230726/common/common_methods.dart';
import 'package:map_application_20230726/pages/map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

import '../common/common_widgets.dart';
import 'category_page.dart';

class AddMarkerPage extends StatefulWidget {
  const AddMarkerPage({super.key});

  @override
  State<AddMarkerPage> createState() => _AddMarkerPageState();
}

class _AddMarkerPageState extends State<AddMarkerPage> {
  final _formKey = GlobalKey<FormState>();
  String _address = '';
  String _title = '';
  String _text = '';
  String _categoryId = "";
  double? latitude;
  double? longitude;

  List<String>? catList;

  getPlacemarkFromAddress(String adddress) async {
    List<Location>? placemark = await locationFromAddress(adddress);
    return placemark;
  }

  Future _chooseCategory(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    List<List<String>?> categoryList = [];
    for (var i = 0; i < catList!.length; i++) {
      final String catId = catList![i];
      final String? catName = prefs.getString(catId);
      categoryList.add([catId, catName!]);
    }

    final List<Widget> catWidget = categoryList
        .map(
          (category) => SimpleDialogOption(
            child: Container(
              child: ListTile(
                title: Text(category![1]),
                tileColor: Colors.grey[300],
              ),
            ),
            onPressed: () {
              _categoryId = category![0];
              Navigator.pop(context, "ダイアログ閉じました");
            },
          ),
        )
        .toList();

    // (1) ダイアログの表示
    var answer = await showDialog(
        context: context,
        // (2) SimpleDialogの作成
        builder: (context) => SimpleDialog(
              children: catWidget,
            ));
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      var prefs = await SharedPreferences.getInstance();
      catList = prefs.getStringList("catIdList");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("マーカー追加"),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(8, 60, 8, 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                catList != null
                    ? Container(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                  margin: EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                      child: TextButton(
                          onPressed: () {
                            _chooseCategory(context);
                          },
                          child: Text(
                            "カテゴリー",
                            style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.w600),
                          )),
                    )
                    : SizedBox.shrink(),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '住所を入力してください';
                    }
                    return null;
                  },
                  onChanged: (value) async {
                    //住所を数値に変換
                    //失敗したら追加不可能
                    List<Location> result =
                        await getPlacemarkFromAddress(value);
                    print(result.isNotEmpty);
                    if (result.isNotEmpty) {
                      _address = value;
                      latitude = result![0].latitude;
                      longitude = result![0].longitude;
                    } else {
                      //失敗したらnull入れる　nullかどうかで判定
                      latitude = null;
                      longitude = null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: '住所*',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タイトルを入力してください';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _title = value; // 入力された値を保存
                  },
                  decoration: InputDecoration(
                    labelText: 'タイトル*',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  onChanged: (value) {
                    _text = value; // 入力された値を保存
                  },
                  decoration: InputDecoration(
                    labelText: 'テキスト',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3 /*最大行数*/,
                ),
                SizedBox(height: 35.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // print([_categoryId,
                        //   _title,
                        //   _text,
                        //   _tappedLatLng!.latitude,
                        //   _tappedLatLng!.longitude]);
                        //データ保存
                        if (latitude != null && longitude != null) {
                          CommonMethods().storageMarker(context, _categoryId,
                              _title, _text, _address, latitude!, longitude!);
                        } else {
                          CommonMethods().showSnackBar(context, "アドレスが無効です。");
                          return;
                        }
                        _categoryId = "";
                        Navigator.pop(context);
                      } catch (e) {
                        print("エラー");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    // ボタンの背景色
                    onPrimary: Colors.white,
                    // ボタンのテキスト色
                    elevation: 8,
                    // 影の大きさ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // ボタンの角丸
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12), // ボタンの内側のパディング
                  ),
                  child: Text(
                    '追加',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
