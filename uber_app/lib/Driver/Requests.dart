import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:uber_hacktag_group_booking/Driver/TrackRouteDriver.dart';

import '../konstants/loaders.dart';

class Requests extends StatefulWidget {
  LocationData location;

  Requests({this.location});

  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> with SingleTickerProviderStateMixin {
  bool load = true;
  AnimationController _animationController;
  Animation _colorTween;
  Map<String, int> recyclerCounts;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> mofRequests;
  List<String> mofKeys;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mofRequests = List();
    mofKeys = List();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
    _colorTween = ColorTween(begin: Colors.red, end: Colors.black54).animate(_animationController);
    getData();
  }

  Future<void> getData() async {
    final database = FirebaseDatabase.instance;
    Map<dynamic, dynamic> tempMap = Map();
    double dist;
    databaseReference
        .child('requestPool')
        .get()
        .then((value) => {
              print("Requests" + value.value.toString()),
              tempMap.addAll(value.value),
              tempMap.keys.forEach((element) {
                mofKeys.add(element);
              }),

              tempMap.values.forEach((element) {
                print(element.toString());

                double destinationLongitude = element['destinationLongitude'];
                double destinationLatitude = element['destinationLatitude'];

                double distanceInMeters = Geolocator.distanceBetween(destinationLatitude,
                    destinationLongitude, widget.location.latitude, widget.location.longitude);
                element['distance'] = distanceInMeters;

                mofRequests.add(element as Map); // = value.value,
              }),
              // value.fo
            })
        .whenComplete(() => {
              mofRequests.forEach((element) {
                print("Requests Map: " + element.toString());
              }),
              setState(() {
                load = false;
              }),
            });
  }

  @override
  Widget build(BuildContext context) {
    return load
        ? spinkit
        : Scaffold(
            appBar: AppBar(
              title: Text('Requests'),
              centerTitle: true,
              backgroundColor: Colors.black87,
              leading: BackButton(),
            ),
            body: Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              child: ListView.separated(
                padding: EdgeInsets.all(10),
                separatorBuilder: (BuildContext context, int index) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 0.5,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Divider(),
                    ),
                  );
                },
                itemCount: mofRequests.length,
                itemBuilder: (BuildContext context, int index) {
                  Map request = mofRequests[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
                    child: Card(
                      color: Colors.grey.shade100,
                      // elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // margin: EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          // leading: CircleAvatar(
                          //   backgroundImage:
                          //   users[consumer['uid']]['profileUrl'] != null
                          //       ? NetworkImage(
                          //       users[consumer['uid']]['profileUrl'])
                          //       : AssetImage(
                          //     dummyPlaceHolder,
                          //   ),
                          //   radius: 25,
                          // ),
                          contentPadding: EdgeInsets.all(0),
                          title: Text(request['passengerName']),
                          subtitle: Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Phone: " + request['passengerPhone'].toString()),
                              AnimatedBuilder(
                                  animation: _colorTween,
                                  builder: (context, child) => Row(
                                        children: [
                                          Text("Distance: "),
                                          Text(
                                            (int.parse((request['distance'] != null
                                                            ? request['distance']
                                                            : "0000")
                                                        .toString()
                                                        .substring(0, 3))
                                                    .toString() +
                                                ' km'),
                                            style: TextStyle(
                                              color: _colorTween.value,
                                            ),
                                          )
                                        ],
                                      )),
                              Text("Location: " + request['destination'].toString().substring(15)),
                              // Text("Email: " +
                              //     request['passengerEmail'].toString()),
                              // Text(consumer['status']),
                            ],
                          )),
                          trailing: (request['status'] == "Finding")
                              ? Container(
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _acceptRequest(request, index);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(0),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          ), //
                                          // color: Colors.white,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size.zero,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(5),
                                          primary: Colors.green,
                                          onPrimary: Colors.black,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: Container(
                                          padding: EdgeInsets.all(0),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ), //
                                          // color: Colors.white,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size.zero,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(5),
                                          primary: Colors.red,
                                          onPrimary: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(10.0),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          side: BorderSide(
                                            color: Colors.grey,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all(Colors.grey.shade800),
                                    ),
                                    child: Text(
                                      'Map',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  TrackRouteDriver(request, mofKeys, index)))
                                    },
                                  ),
                                ),
                          // : Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       ElevatedButton(
                          //         onPressed: () {},
                          //         child: Container(
                          //           padding: EdgeInsets.all(0),
                          //           child: Icon(
                          //             Icons.close,
                          //             color: Colors.white,
                          //           ), //
                          //           // color: Colors.white,
                          //         ),
                          //         style: ElevatedButton.styleFrom(
                          //           minimumSize: Size.zero,
                          //           shape: CircleBorder(),
                          //           padding: EdgeInsets.all(5),
                          //           primary: Colors.red,
                          //           onPrimary: Colors.black,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          onTap: () {},
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }

  Future<void> _acceptRequest(Map<dynamic, dynamic> request, int index) async {
    Map<dynamic, dynamic> temprequest = request;

    String requestKey = mofKeys[index];
    // temprequest.remove('distance');
    // temprequest['distance']=50000;
    temprequest['status'] = 'Booking';
    temprequest['driverLatitude'] = widget.location.latitude;
    temprequest['driverLongitude'] = widget.location.longitude;
    var email = request['passengerEmail'];
    setState(() {
      load = true;
    });
    var res = await http.get(Uri.parse(
        "https://us-central1-uber-hacktag-group-booking.cloudfunctions.net/sendMail?dest=$email&uid=$requestKey"));
    print(res.body);
    databaseReference.child('requestPool').child(requestKey).set(temprequest).whenComplete(() => {
          setState(() {
            load = false;
            _showMessege("Accepted");
          }),
        });
  }

  // String message = "This is a test message!";

  Future<void> _sendEmail(String message, List<String> recipents) async {
    // _sendSMS(message, recipents);
    // String _result = await sendSMS(message: message, recipients: recipents)
    //     .catchError((onError) {
    //   print(onError);
    // });
    // print(_result);
  }

  _showMessege(String msg) {
    Fluttertoast.showToast(msg: msg);
  }
}
