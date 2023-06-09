import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tango/constants.dart';
import 'package:tango/screens/cityPicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../providers/cityProvider.dart';
//
// class HomeScreen extends StatefulWidget {
//   HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       animationDuration: Duration(milliseconds: 100),
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           toolbarHeight: 0,
//           //backgroundColor: Colors.purpleAccent,
//           bottom: const TabBar(
//             tabs: [
//               Tab(
//                 icon: Icon(Icons.group),
//                 text: 'Groups',
//               ),
//               Tab(
//                 icon: Icon(Icons.event),
//                 text: 'Events',
//               ),
//               // Tab(icon: Icon(Icons.logout),
//               //   text: 'Logout',),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [GroupsScreen(), Text('Events')],
//         ),
//       ),
//     );
//   }
// }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? countryValue;
  String? stateValue;
  String? cityValue;

  @override
  Widget build(BuildContext context) {
    CollectionReference msg = FirebaseFirestore.instance.collection('messages');

    return Consumer<CityProvider>(
        builder: ((context, city, child) => Scaffold(
              // appBar: AppBar(
              //   automaticallyImplyLeading: false,
              //   backgroundColor: Colors.pinkAccent,
              //   centerTitle: true,
              //   title: Text("Tango"),
              // ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.pinkAccent,
                child: Icon(Icons.location_city),
                onPressed: () async {
                  selectCity(city, context);
                },
              ),
              body: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                   // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Icon(Icons.location_on,
                    color: Colors.red,
                    size: 20,), Text(city.city), SizedBox(
                      width: 20,
                    )],
                  ),
                  Expanded(
                    child: FutureBuilder<DocumentSnapshot>(
                      future: msg.doc(city.city).get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text("Something went wrong");
                        }

                        if (snapshot.hasData && !snapshot.data!.exists) {
                          return Center(
                              child: Text("No Group Exist in ${city.city}"));
                        }

                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, dynamic> data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          //  for (var i in data['group'])
                          return grpList( data['group'], context, city) ;
                            //groupLists(data['group'], context, city);
                          //Text("Full Name: ${data['City']} ${data['group']}");
                        }

                        return Text("loading");
                      },
                    ),
                  ),
                ],
              ),
            )));
  }

  selectCity(CityProvider cp, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      barrierColor: Colors.blue.withOpacity(0.2),
      backgroundColor: Colors.white,
      elevation: 1000,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SelectState(
                //   dropdownColor: Colors.lightBlue,
                onCountryChanged: (value) {
                  setState(() {
                    countryValue = value;
                    cp.selectCountry(value);
                  });
                },
                onStateChanged: (value) {
                  setState(() {
                    stateValue = value;
                    cp.selectState(value);
                  });
                },
                onCityChanged: (value) {
                  setState(() {
                    cityValue = value;
                    cp.selectCity(value);
                  });
                },
              ),
              InkWell(
                  onTap: () {
                    print('country selected is $countryValue');
                    print('country selected is $stateValue');
                    print('country selected is $cityValue');
                  },
                  child: Text(' Check'))
            ],
          ),
        );
      },
    );
  }
  Widget grpList(  List<dynamic> groups, BuildContext context, CityProvider city) {
    double _w = MediaQuery.of(context).size.width;
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.all(_w / 30),
        physics:
        BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: groups.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            delay: Duration(milliseconds: 100),
            child: SlideAnimation(
              duration: Duration(milliseconds: 2500),
              curve: Curves.fastLinearToSlowEaseIn,
              verticalOffset: -250,
              child: ScaleAnimation(
                duration: Duration(milliseconds: 1500),
                curve: Curves.fastLinearToSlowEaseIn,
                child: InkWell(
                    onTap: (){
                      city.selectGroup(groups[index]);
                      Navigator.pushNamed(context, 'chatscreen');
                    },
                  child: Container(
                    margin: EdgeInsets.only(bottom: _w / 20),
                    height: _w / 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Icon(Icons.group),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "${groups[index]}",
                          style: TextStyle(
                              color: Colors.pinkAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                  ),


                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget groupLists(List groups, BuildContext context, CityProvider city) {
    return ListView(

      children: [
        for (var i in groups)
          InkWell(
            onTap: () {
              city.selectGroup(i);
              Navigator.pushNamed(context, 'chatscreen');
            },
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5, bottom: 1, top: 4),
              padding: const EdgeInsets.only(left: 8.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.pinkAccent],
                    // [
                    //   Color.fromARGB(255, 176, 106, 231),
                    //   Color.fromARGB(255, 166, 112, 231),
                    //   Color.fromARGB(255, 131, 123, 231),
                    //   Color.fromARGB(255, 104, 132, 231),
                    // ],
                    transform: GradientRotation(90),
                  ),
                  //color:  Color.fromARGB(255, 208, 208, 208),
                  borderRadius: BorderRadius.circular(5.0)),
              height: MediaQuery.of(context).size.height * 0.12,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.group),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    "$i",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }
}
