import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Blue'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool scanning = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  BluetoothDevice device;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> dta = [];
  List<int> rssi = [];

  startStop() {
    if (scanning) {
      flutterBlue.stopScan();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("you have ${dta.length} devices"),
      ));
    } else {
      flutterBlue.startScan(timeout: Duration(seconds: 4));
      var subscription = flutterBlue.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          print(
              'This is from startStop ${r.device.name} found! rssi: ${r.rssi}');
          rssi.add(r.rssi);
        }
      });
    }
    setState(() {
      scanning = !scanning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            child: Text(
              scanning ? "Stop Scanning" : "Start Scanning",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            onPressed: () {
              startStop();
            },
          )
        ],
      ),
      body: StreamBuilder<List<ScanResult>>(
        stream: FlutterBlue.instance.scanResults,
        initialData: [],
        builder: (c, snapshot) {
          dta = snapshot.data;
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              //return Text(snapshot.data[index].device.name);

              return myWidget(snapshot, index);
            },
          );
        },
      ),
    );
  }
}

Widget myWidget(AsyncSnapshot<dynamic> snapshot, int index) {
  print("object");
  print(snapshot.data[index].device.name);

  //print("Name: ${snapshot.data[index].device.name}");
  //return Text(snapshot.data[index].device.name.toString());

  if (snapshot.hasData) {
    print(snapshot.data);
    print(snapshot.data[index].device.id);

    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Container(
        child: Card(
            elevation: 5,
            child: Column(
              //mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* const ListTile(
                  leading: Icon(Icons.connect_without_contact),
                  title: Text('Device ID'),
                  subtitle: Text('SUBTITLE'),
                ),*/
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        snapshot.data[index].device.id.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                      ),
                      child: RaisedButton(
                        color: Colors.amber[900],
                        textColor: Colors.white,
                        child: const Text('CONNECT'),
                        onPressed: () {/* ... */},
                      ),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
    // MyCard();
  } else {
    return Text("No Device Found");
  }
}
