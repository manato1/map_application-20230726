import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_methods.dart';
import '../common/common_widgets.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<String> catList = []; //カテゴリーのIDのリスト
  List<List<String>> categoryList = []; //[id,cat_name]のリスト
  final _formKey = GlobalKey<FormState>();
  String _category = "";

  getCat() async {
    var prefs = await SharedPreferences.getInstance();
    catList = prefs.getStringList("catIdList") ?? [];
    print("cat id$catList");
    List<List<String>> list = [];

    if (catList.isNotEmpty) {
      for (var i = 0; i < catList!.length; i++) {
        final String catId = catList![i];
        final String catName = prefs.getString(catId) ?? "";
        list.add([catId, catName]);
      }

      print("cat list$categoryList");
    }
    setState(() {
      categoryList = list;
    });
  }

  Future _deleteCat(BuildContext context, categoryId) async {
    // (2) showDialogでダイアログを表示する
    var ret = await showDialog(
        context: context,
        // (3) AlertDialogを作成する
        builder: (context) => AlertDialog(
              title: Text("カテゴリーの削除"),
              content: Text("このカテゴリーに紐づくマーカーはすべて削除されます。よろしいですか。"),
              // (4) ボタンを設定
              actions: [
                TextButton(
                    onPressed: () async {
                      //削除処理
                      var prefs = await SharedPreferences.getInstance();
                      catList.remove(categoryId);
                      prefs.setStringList("catIdList", catList);
                      final ret = await prefs.remove(categoryId);

                      //catIdがさくじょIDのmarkerを削除
                      List<String>? markerIdList;
                      List<List<String>> markerList = [];
                      markerIdList = prefs.getStringList("markerIdList");
                      if (markerIdList != null) {
                        for (var i = 0; i < markerIdList.length; i++) {
                          final List<String>? marker =
                              prefs.getStringList(markerIdList[i]);
                          if (marker != null) {
                            if (marker[0] == categoryId) {
                              //カテゴリー一致すれば削除
                              await prefs.remove(markerIdList[i]);
                              ////カテゴリー一致でマーカーIDのリストからID削除
                              markerIdList.remove(markerIdList[i]);
                            }
                          }
                        }
                        prefs.setStringList("markerIdList", markerIdList);
                      }

                      getCat();
                      Navigator.pop(context, true);
                    },
                    child: Text("はい")),
              ],
            ));
  }

  Future _addCat(BuildContext context) async {
    // (2) showDialogでダイアログを表示する
    var ret = await showDialog(
      context: context,

      // (3) AlertDialogを作成する
      builder: (context) => AlertDialog(
        title: Text("カテゴリー追加"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'カテゴリーを入力してください';
                    }else if(value.length > 15){
                      return '15文字以下にしてください';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print(value);
                    _category = value; // 入力された値を保存
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        //["id","id","id"]
                        //id["cat"]
                        //データ保存
                        var prefs = await SharedPreferences.getInstance();
                        final catId = CommonMethods().createRandamString();
                        //まだカテゴリーが一つもないとき
                        if (catList == []) {
                          // catList = [catId];
                          prefs.setStringList("catIdList", [catId]);
                          prefs.setString(catId, _category);
                        } else {
                          catList.add(catId);
                          prefs.setStringList("catIdList", catList!);
                          prefs.setString(catId, _category);
                        }
                        getCat();
                        Navigator.pop(context); // フォームを閉じる
                        CommonMethods().showSnackBar(context, "カテゴリーを追加しました。");
                      } catch (e) {
                        print("エラー");
                      }
                    }
                  },
                  child: Text('追加'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("カテゴリー"),backgroundColor: Colors.orange,
      ),
      body: catList.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: categoryList.length, // リストに表示するアイテムの数を指定
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    title: Text(categoryList[index][1]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // 削除確認
                        _deleteCat(context, categoryList[index][0]);
                      },
                    ));
              })
          : Center(child: Text("カテゴリーはありません")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCat(context);
        },
        child: Icon(Icons.add), // プラスアイコンを設定
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // ボタンを右下に配置
    );
  }
}
