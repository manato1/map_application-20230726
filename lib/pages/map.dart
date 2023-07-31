import 'dart:async';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show Random, asin, cos, sqrt;

import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_methods.dart';

class Secrets {
  // Google Maps APIキーをここに追加
  static const API_KEY = 'AIzaSyBw_oOMe69Q4EX4L_v3LWECO9PBx4SktRo';
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
// マップビューの初期位置
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

  // マップの表示制御用
  late GoogleMapController mapController;

  // 現在位置の記憶用
  late Position _currentPosition;

  // 場所の記憶用
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();
  String _currentAddress = '';
  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  // マーカーリスト
  Set<Marker> markers = {};

  // PolylinePoints用オブジェクト
  late PolylinePoints polylinePoints;

  // 参加する座標のリスト
  List<LatLng> polylineCoordinates = [];

  // 2点間を結ぶポリラインを格納した地図
  Map<PolylineId, Polyline> polylines = {};

  // 現在位置の取得方法
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // 位置を変数に格納する
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        // カメラを現在位置に移動させる場合
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  List<String>? catList;

  @override
  void initState() {
    super.initState();
    Future(() async {
      var prefs = await SharedPreferences.getInstance();
      catList = prefs.getStringList("catIdList");
    });
    _getCurrentLocation();
  }

  // アドレスの取得方法
  _getAddress() async {
    try {
      // 座標を使用して場所を取得する
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      print("_currentAddress");
      print(p);

      // 最も確率の高い結果を取得
      Placemark place = p[0];
      setState(() {
        // アドレスの構造化
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print(_currentAddress);

        // TextFieldのテキストを更新
        startAddressController.text = _currentAddress;
        // ユーザーの現在地を出発地とする設定
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print("_currentAddress");

      print(e);
    }
  }

  // 2地点間の距離の算出方法
  Future<bool> _RouteDistance() async {
    try {
      // 住所からプレースマークを取得する
      List<Location>? startPlacemark = await locationFromAddress(_startAddress);
      List<Location>? destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      // 開始位置がユーザーの現在位置の場合、アドレスではなく、取得した現在位置の座標を使用する方が精度が良いため。
      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // 開始位置用マーカー設置
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // 目的位置用マーカー設置
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // マーカーをリストに追加する
      markers.add(startMarker);
      markers.add(destinationMarker);

      print(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      print(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      // フレームに対する相対位置を確認するための計算を行い、それに応じてカメラをパン＆ズームする
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // マップのカメラビュー内に2つのロケーションを収容する
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      // 2つのマーカーの間にラインを表示する
      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      // 距離計算用の変数
      double totalDistance = 0.0;
      // 小さなセグメント間の距離を加算して総距離を計算する
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }
      // 表示用の変数に計算結果を格納
      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // 2つの座標間の距離の計算式
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // 2地点間の経路を示すポリラインを作成する
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps APIキー
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  // UI表示用
  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  LatLng? _tappedLatLng; // タップした位置の緯度経度情報
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _text = '';
  String _categoryId = "";

  void storageMarker(category, title, text, latitude, longitude) async {
    var prefs = await SharedPreferences.getInstance();
    final List<String>? idList = prefs.getStringList("idList");
    final String id = CommonMethods().createRandamString();

    //まだ一つも登録していなければ
    try {
      if (idList == null) {
        prefs.setStringList("idList", [id]);
        prefs.setStringList(id, [category, title, text, latitude, longitude]);
      } else {
        //idリストにid追加
        idList.add(id);
        prefs.setStringList("idList", idList);
        prefs.setStringList(id, [category, title, text, latitude, longitude]);
      }
    } catch (e) {
      CommonMethods().showSnackBar(context, "マーカーを追加できませんでした。");
    }
  }

  void _showBottomSheet(BuildContext context, marker) async {
    bool _added = false;
    final result = await showModalBottomSheet(
      isScrollControlled: true, // キーボードの上にBottomSheetを表示するために追加
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Padding(
            padding:
                MediaQuery.of(context).viewInsets, // キーボードの高さを考慮してPaddingを設定
            child: Container(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 40),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop('モーダルを閉じました'); // モーダルを閉じる
                        },
                        child: Text('モーダルを閉じる'),
                      ),
                      Text(
                        'タップした位置のマーカー情報',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text('緯度: ${_tappedLatLng!.latitude}'),
                      Text('経度: ${_tappedLatLng!.longitude}'),
                      SizedBox(height: 16.0),
                      catList != null
                          ? TextButton(
                              onPressed: () {
                                _chooseCategory(context);
                                },
                              child: Text("カテゴリー"))
                          : SizedBox.shrink(),
                      SizedBox(height: 16.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'タイトルを入力してください';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                print(value);
                                _title = value; // 入力された値を保存
                              },
                              decoration: InputDecoration(
                                labelText: 'タイトル*',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 20.0),
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
                            SizedBox(height: 20.0),
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
                                    storageMarker(
                                        _categoryId,
                                        _title,
                                        _text,
                                        _tappedLatLng!.latitude,
                                        _tappedLatLng!.longitude);
                                    _added = true;
                                    Navigator.of(context)
                                        .pop('モーダルを閉じました'); // モーダルを閉じる
                                  } catch (e) {
                                    print("エラー");
                                  }
                                }
                              },
                              child: Text('追加'),
                            ),
                          ],
                        ),
                      )
                    ])));
      },
    );
    // 保存されずにモーダルが閉じられたらマーカー消す
    if (_added == false && result != null) {
      setState(() {
        markers.remove(marker);
      });
    }
  }

  Future _chooseCategory(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    List<List<String>?> categoryList = [];
    for (var i = 0; i < catList!.length; i++) {
      final String catId = catList![i];
      final String? catName = prefs.getString(catId);
      categoryList.add([catId,catName!]);
    }

    final List<Widget> catWidget = categoryList.map(
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
    ).toList();

    // (1) ダイアログの表示
    var answer = await showDialog(
        context: context,
        // (2) SimpleDialogの作成
        builder: (context) => SimpleDialog(
              children: catWidget,
            ));
  }

  @override
  Widget build(BuildContext context) {
    // 画面の幅と高さを決定する
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
                markers: Set<Marker>.from(markers),
                initialCameraPosition: _initialLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                onTap: (LatLng latLng) {
                  _tappedLatLng = latLng;
                  // 目的位置用マーカー設置
                  Marker marker = Marker(
                    markerId: MarkerId(latLng.latitude.toString() +
                        latLng.longitude.toString()),
                    position: LatLng(latLng.latitude, latLng.longitude),
                    infoWindow: InfoWindow(
                      title: 'Destination $latLng.latitude',
                      snippet: _destinationAddress,
                    ),
                    icon: BitmapDescriptor.defaultMarker,
                  );
                  setState(() {
                    markers.add(marker);
                  });
                  _showBottomSheet(context, marker);
                }),
            // ズームイン・ズームアウトのボタンを配置
            SafeArea(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 100.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      // ズームインボタン
                      ClipOval(
                        child: Material(
                          color: Colors.blue.shade100, // ボタンを押す前のカラー
                          child: InkWell(
                            splashColor: Colors.blue, // ボタンを押した後のカラー
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.add),
                            ),
                            onTap: () {
                              mapController.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      //　ズームアウトボタン
                      ClipOval(
                        child: Material(
                          color: Colors.blue.shade100, // ボタンを押す前のカラー
                          child: InkWell(
                            splashColor: Colors.blue, // ボタンを押した後のカラー
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.remove),
                            ),
                            onTap: () {
                              mapController.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  // 現在地表示ボタン
                  child: ClipOval(
                    child: Material(
                      color: Colors.blue.shade100, // ボタンを押す前のカラー
                      child: InkWell(
                        splashColor: Colors.blue, // ボタンを押した後のカラー
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 開智位置と目的位置を入力するためのUI
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black38),
                    width: width * 0.85,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '場所検索',
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          _textField(
                              label: '開始位置',
                              hint: '開始位置を入力',
                              prefixIcon: Icon(Icons.directions_walk),
                              controller: startAddressController,
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          _textField(
                              label: '目的位置',
                              hint: '目的位置を入力',
                              prefixIcon: Icon(Icons.directions_walk),
                              controller: destinationAddressController,
                              focusNode: desrinationAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _destinationAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'DISTANCE: $_placeDistance km',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: (_startAddress != '' &&
                                    _destinationAddress != '')
                                ? () async {
                                    startAddressFocusNode.unfocus();
                                    desrinationAddressFocusNode.unfocus();
                                    setState(() {
                                      if (markers.isNotEmpty) markers.clear();
                                      if (polylines.isNotEmpty)
                                        polylines.clear();
                                      if (polylineCoordinates.isNotEmpty)
                                        polylineCoordinates.clear();
                                      _placeDistance = null;
                                    });

                                    _RouteDistance();
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'ルート検索'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
