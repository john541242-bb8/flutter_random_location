import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Lobby extends StatelessWidget {
  const Lobby({super.key});

  Widget SearchButton(
    BuildContext context, {
    required List<searchMod> mods,
    required String buttonText,
    required IconData icon,
  }) {
    return Column(
      children: [
        SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/resultList",
              arguments: {
                "searchMods": mods,
                "searchTitle": buttonText,
              },
            );
          },
          icon: FaIcon(icon, size: 20),
          label: Text(
            "尋找$buttonText?",
            style: TextStyle(
              fontSize: 20,
              fontFamily: "GlowSCLight",
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            shadowColor: Colors.white,
            minimumSize: Size(100, 50),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(Icons.search, size: 100),
                Positioned(
                  height: 70,
                  bottom: 25,
                  left: 20,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      scale: 0.1,
                      "https://i.pinimg.com/736x/ae/aa/b2/aeaab2657dfa7ec6ea4f2ff9be35c6a8.jpg",
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70.0),
              child: Divider(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    SearchButton(
                      context,
                      mods: [
                        searchMod.restaurant,
                        searchMod.food_court,
                      ],
                      buttonText: "餐廳",
                      icon: Icons.restaurant,
                    ),
                    SearchButton(
                      context,
                      mods: [
                        searchMod.cafe,
                        searchMod.dog_cafe,
                        searchMod.cat_cafe,
                        searchMod.coffee_shop,
                      ],
                      buttonText: "咖啡廳",
                      icon: Icons.coffee,
                    ),

                    SearchButton(
                      context,
                      mods: [searchMod.movie_theater],
                      buttonText: "電影院",
                      icon: Icons.theaters,
                    ),
                    SearchButton(
                      context,
                      mods: [searchMod.book_store],
                      buttonText: "書店",
                      icon: FontAwesomeIcons.bookOpen,
                    ),
                  ],
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SearchButton(
                      context,
                      mods: [searchMod.public_bathroom],
                      buttonText: "廁所",
                      icon: FontAwesomeIcons.restroom,
                    ),
                    SearchButton(
                      context,
                      mods: [searchMod.gas_station],
                      buttonText: "加油站",
                      icon: FontAwesomeIcons.gasPump,
                    ),
                    SearchButton(
                      context,
                      mods: [searchMod.park],
                      buttonText: "公園",
                      icon: FontAwesomeIcons.tree,
                    ),
                    SearchButton(
                      context,
                      mods: [searchMod.convenience_store],
                      buttonText: "便利商店",
                      icon: FontAwesomeIcons.store,
                    ),
                  ],
                ),
              ],
            ),
            SearchButton(
              context,
              mods: [
                searchMod.tourist_attraction,
                searchMod.cultural_center,
                // searchMod.event_venue,
                searchMod.museum,
                searchMod.roller_coaster,
              ],
              buttonText: "景點",
              icon: FontAwesomeIcons.suitcase,
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "此app會尋找附近450公尺內符合類型並且當下在營業的地點",
            style: TextStyle(fontSize: 10, fontFamily: "GlowSCLight"),
          ),
        ),
      ),
    );
  }
}

enum searchMod {
  restaurant,
  food_court, //美食廣場
  gas_station,
  public_bathroom,
  cafe,
  cat_cafe,
  dog_cafe,
  coffee_shop,
  movie_theater,
  park,
  convenience_store,
  book_store,
  tourist_attraction, //景點
  cultural_center, //文化中心
  event_venue, //活動中心
  roller_coaster, //雲霄飛車
  museum,
}
