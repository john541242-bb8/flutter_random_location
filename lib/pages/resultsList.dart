import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_custom_marker/google_maps_custom_marker.dart';
import 'package:flutter_random_location/ignore/key.dart' as key;
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'lobby.dart';
import 'package:flutter_random_location/widget/randomPlace.dart';

class Resultslist extends StatefulWidget {
  const Resultslist({super.key});

  @override
  State<Resultslist> createState() => _ResultslistState();
}

class _ResultslistState extends State<Resultslist> {
  //放在位置列表裡的widget
  Widget placeWidget({
    required String name,
    required var rate,
    int? startPrice,
    int? endPrice,
    required double pLat,
    required double pLng,
    required String mapUrl,
  }) {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                height: 60,
                width: 1000,
                child: FittedBox(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: "GlowSCLight",
                      fontSize: 27,
                    ),
                  ),
                ),
              ),
              onTap: () async {
                launchUrl(
                  Uri.parse(mapUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rate_rounded, size: 20),
                    Text("$rate", style: TextStyle(fontSize: 15)),
                  ],
                ),
                //選擇要不要顯示價格
                if (startPrice != null && endPrice != null) ...[
                  Row(
                    children: [
                      Icon(Icons.monetization_on_outlined),
                      Text("價位：$startPrice~$endPrice元"),
                    ],
                  ),
                ],
                Row(
                  children: [
                    Icon(Icons.arrow_forward),
                    Text(
                      "距離${calculateDistance(pLat, pLng).round()}公尺",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Divider(),
        ),
      ],
    );
  }

  Widget noResultWidget() {
    return Column(
      children: [
        SizedBox(height: 20),
        Center(child: FaIcon(FontAwesomeIcons.faceFrown, size: 60)),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Divider(),
        ),
        Text(
          "附近沒有這類型的位置",
          style: TextStyle(fontFamily: "GlowSCLight", fontSize: 25),
        ),
      ],
    );
  }

  //放在轉牌裡的widget
  Widget placeScrollView({required String placeName}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              placeName,
              style: TextStyle(
                fontFamily: "GlowSCLight",
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // final geolocator = Geolocator();
  Position? userPosition; //用戶位置
  LatLng? userLatLng; //google map用
  List<Place> placeList = [];
  List<searchMod> smods = [];
  // List<String> smodsToTexts = [];
  bool searchDone = false;
  Future<void> nearbySearch() async {
    bool isReady = false;
    Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) {
      if (status == ServiceStatus.enabled) {
        isReady = true;
      } else {
        isReady = false;
      }
    });
    //取得用戶位置
    if (isReady) {
      userPosition = await Geolocator.getCurrentPosition();
      userLatLng = LatLng(
        userPosition!.latitude,
        userPosition!.longitude,
      );
      print(await Geolocator.getCurrentPosition());
    } else {
      await Geolocator.requestPermission();
      userPosition = await Geolocator.getCurrentPosition();
      userLatLng = LatLng(
        userPosition!.latitude,
        userPosition!.longitude,
      );
      print(await Geolocator.getCurrentPosition());
    }

    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:searchNearby',
    );

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': key.PlaceKey,
      'X-Goog-FieldMask':
          'places.displayName,places.location,places.rating,places.priceRange,places.googleMapsUri,places.currentOpeningHours',
    };
    final body = jsonEncode({
      "locationRestriction": {
        "circle": {
          "center": {
            "latitude": userPosition!.latitude,
            "longitude": userPosition!.longitude,
          },
          "radius": 450,
        },
      },
      "includedTypes": smods.map((e) {
        return "$e".replaceAll("searchMod.", "");
      }).toList(),
    });
    Response searchResult = await post(
      url,
      headers: headers,
      body: body,
    );
    //檢查我的頁面是否已經被滑掉了
    if (mounted) {
      Map<String, dynamic> resultsMap = jsonDecode(searchResult.body);
      dev.log(jsonEncode(resultsMap));

      if (resultsMap["places"] == null) {
        setState(() {
          searchDone = true;
        });
        return;
      }

      List<dynamic> reusltsList = resultsMap["places"];

      reusltsList.forEach((e) {
        print(e["rating"].runtimeType);
      });

      reusltsList.forEach((e) {
        if (e["currentOpeningHours"]["openNow"]) {
          setState(() {
            bool haveRating = true;
            bool havePrice = true;
            if (e["rating"] == null) haveRating = false;
            if (e["priceRange"] == null) havePrice = false;
            placeList.add(
              Place(
                name: e["displayName"]["text"],
                location: Location(
                  latitude: e["location"]["latitude"],
                  longitude: e["location"]["longitude"],
                ),
                rate: haveRating == true ? e["rating"] : "尚無評分",
                startPrice: havePrice == true
                    ? int.tryParse(
                        e["priceRange"]["startPrice"]["units"],
                      )
                    : null,
                endPrice: havePrice == true
                    ? int.tryParse(
                        e["priceRange"]["endPrice"]["units"],
                      )
                    : null,
                googlemapUrl: e["googleMapsUri"],
              ),
            );
          });
        }
      });
      setState(() {
        searchDone = true;
      });
    }
  }

  //大大ai提供的計算兩地的距離根據經緯度
  double calculateDistance(double plat, double plng) {
    const earthRadius = 6371000; // 地球半徑（公尺）

    double dLat = _toRadians(plat - userPosition!.latitude);
    double dLng = _toRadians(plng - userPosition!.longitude);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userPosition!.latitude)) *
            cos(_toRadians(plat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  //計算弧度
  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Set<Marker> markersList = {};
  //製作地點marker
  Future<void> createCustomMarker() async {
    if (markersList.isNotEmpty) {
      setState(() {
        markersList = {};
      });
    }
    for (var e in placeList) {
      if (!mounted) break;
      Marker m = await GoogleMapsCustomMarker.createCustomMarker(
        marker: Marker(
          markerId: MarkerId("test"),
          position: LatLng(e.location.latitude, e.location.longitude),
        ),
        shape: MarkerShape.bubble,
        title: e.name,
        // foregroundColor: Colors.blue,
        backgroundColor: Colors.orange,
      );
      setState(() {
        markersList.add(m);
      });
    }
    if (mounted) {
      //用戶所在地marker
      setState(() {
        markersList.add(
          Marker(
            markerId: MarkerId("userPos"),
            position: userLatLng!,
            infoWindow: InfoWindow(title: "你目前的位置"),
          ),
        );
      });
    }
  }

  ScrollController testControll = ScrollController();
  bool nearbySearched = false; //避免重複NearbySearching
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!nearbySearched) {
      nearbySearched = true;
      smods =
          (ModalRoute.of(context)!.settings.arguments
              as Map)["searchMods"];
      // smods.forEach((e) {
      //   searchTypeText += '"$e", '.replaceAll("searchMod.", "");
      // });
      // print("目前的標籤是$searchTypeText");
      await nearbySearch();
      createCustomMarker();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget reultWidget() {
      if (searchDone) {
        if (placeList.isNotEmpty) {
          // return Column(
          //   children: placeList.map((e) {
          //     return Slidable(
          //       startActionPane: ActionPane(
          //         motion: ScrollMotion(),
          //         children: [
          //           SlidableAction(
          //             onPressed: (context) {},
          //             icon: Icons.padding,
          //           ),
          //         ],
          //       ),
          //       child: placeWidget(
          // name: e.name,
          // rate: e.rate,
          // pLat: e.location.latitude,
          // pLng: e.location.longitude,
          // startPrice: e.startPrice,
          // endPrice: e.endPrice,
          // mapUrl: e.googlemapUrl,
          //       ),
          //     );
          //   }).toList(),
          // );
          return ListView.builder(
            itemBuilder: (context, index) {
              return Dismissible(
                key: UniqueKey(),

                onDismissed: (direction) {
                  setState(() {
                    placeList.removeAt(index);
                  });
                  createCustomMarker();
                },
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: placeWidget(
                  name: placeList[index].name,
                  rate: placeList[index].rate,
                  pLat: placeList[index].location.latitude,
                  pLng: placeList[index].location.longitude,
                  startPrice: placeList[index].startPrice,
                  endPrice: placeList[index].endPrice,
                  mapUrl: placeList[index].googlemapUrl,
                ),
              );
            },
            itemCount: placeList.length,
          );
        } else {
          return noResultWidget();
        }
      } else {
        return Center(
          child: Text(
            "正在尋找中......",
            style: TextStyle(fontFamily: "GlowSCLight", fontSize: 25),
          ),
        );
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: Text(
            "關於${(ModalRoute.of(context)!.settings.arguments as Map)["searchTitle"]}的搜尋結果",
            style: TextStyle(fontFamily: "GlowSCLight"),
          ),
          bottom: TabBar(
            // overlayColor: materialst,
            indicatorColor: Colors.grey[600],
            // labelColor: Colors.white,
            // dividerColor: Colors.grey[500],
            tabs: [
              Tab(icon: Icon(Icons.place, color: Colors.black)),
              Tab(
                icon: Icon(FontAwesomeIcons.map, color: Colors.black),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: reultWidget(),
            ),
            if (userLatLng != null) ...[
              GoogleMap(
                padding: EdgeInsets.symmetric(vertical: 100),
                initialCameraPosition: CameraPosition(
                  target: userLatLng!,
                  zoom: 13,
                ),
                // markers: {
                //   // Marker(
                //   //   markerId: MarkerId("MyHouse"),
                //   //   icon: BitmapDescriptor.defaultMarkerWithHue(70),
                //   //   position: userLatLng!,
                //   //   infoWindow: InfoWindow(
                //   //     title: '我家', // The main name/title
                //   //     snippet: 'www', // Additional details
                //   //   ),
                //   // ),
                //   customMarker(),
                // },
                markers: markersList.map((e) {
                  return e;
                }).toSet(),
              ),
            ] else ...[
              Text("加載中"),
            ],
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (placeList.isNotEmpty) {
              //顯示轉盤
              showDialog(
                context: context,
                builder: (context) {
                  return RandomPlace(places: placeList);
                },
              );
            }
          },
          child: Icon(FontAwesomeIcons.shuffle),
        ),
      ),
    );
  }
}

class Place {
  String name;
  Location location;
  var rate;
  int? startPrice;
  int? endPrice;
  String googlemapUrl;

  Place({
    required this.name,
    required this.location,
    required this.rate,
    this.startPrice,
    this.endPrice,
    required this.googlemapUrl,
  });
}

class Location {
  double latitude;
  double longitude;
  Location({required this.latitude, required this.longitude});
}
