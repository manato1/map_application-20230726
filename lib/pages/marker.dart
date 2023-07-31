import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_application_20230726/pages/map.dart';

import '../common/common_widgets.dart';
import 'category_page.dart';

class MarkerPage extends StatefulWidget {
  const MarkerPage({super.key});

  @override
  State<MarkerPage> createState() => _MarkerPageState();
}

class _MarkerPageState extends State<MarkerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("マーカー"),
      ),
      body: Container(),
    );
  }}