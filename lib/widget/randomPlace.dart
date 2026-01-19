import 'package:flutter/material.dart';
import 'package:flutter_random_location/pages/resultsList.dart'
    as dependence;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class RandomPlace extends StatefulWidget {
  const RandomPlace({super.key, required this.places});
  final List<dependence.Place> places;
  @override
  State<RandomPlace> createState() => _RandomPlaceState();
}

class _RandomPlaceState extends State<RandomPlace> {
  final Random random = Random();

  String placeUrl = "";
  String randomPlaceName = "";

  int repeatTimes = 20;
  int previousIndex = 0;
  late Timer randomChangeNumTimer;
  bool goDown = true;
  void startRandom() {
    repeatTimes = 20;
    randomChangeNumTimer = Timer.periodic(
      Duration(milliseconds: 100),
      (timer) {
        int i;
        do {
          i = random.nextInt(widget.places.length);
        } while (previousIndex == i);
        previousIndex = i;
        dependence.Place randomPlace = widget.places[i];
        setState(() {
          randomPlaceName = randomPlace.name;
          print(randomPlaceName);
        });
        repeatTimes--;

        if (repeatTimes == 0) {
          //結束!!
          goDown = false;
          placeUrl = randomPlace.googlemapUrl;
          timer.cancel();
          print("停止隨機!!");
        }
      },
    );
  }

  List<String> soundsGoods = [
    "這看起來是個明智的選擇！",
    "q(≧▽≦q)",
    "這家看起來不錯喔！",
    "嘗試新口味！！",
    "我強烈推薦這個選擇。",
    "這個選擇絕對不會讓你失望。",
    "相信我你絕對不會後悔的。",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startRandom();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    randomChangeNumTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        Center(
          child: TextButton(
            onPressed: () async {
              launchUrl(
                Uri.parse(placeUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: FittedBox(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: "GlowSCLight",
                  color: Colors.white,
                  fontSize: 50,
                ),
                child: Text(randomPlaceName),
              ),
            ),
          ),
        ),
        Align(
          alignment: AlignmentGeometry.bottomCenter,
          child: AnimatedSlide(
            offset: goDown ? Offset(0, 2) : Offset(0, -0.25),
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInQuint,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: FittedBox(
                    child: DefaultTextStyle(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.grey[100],
                      ),
                      child: Text(
                        !goDown
                            ? soundsGoods[random.nextInt(
                                soundsGoods.length,
                              )]
                            : "(っ °Д °;)っ",
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 50,
                  ),
                  child: Divider(),
                ),
                SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    goDown = true;
                    startRandom();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withValues(
                      alpha: 0.6,
                    ),
                    foregroundColor: Colors.grey[100],
                  ),
                  icon: Icon(FontAwesomeIcons.repeat, size: 40),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
