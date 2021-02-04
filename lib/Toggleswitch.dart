import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart' as fb;

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//import 'package:flutter_switch/flutter_switch.dart';

class Toggleswitch extends StatefulWidget {
  @override
  _ToggleswitchState createState() => _ToggleswitchState();
}

class _ToggleswitchState extends State<Toggleswitch> {
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  fb.FlutterBlue _bluetoothfb = fb.FlutterBlue.instance;
  fb.BluetoothDevice connectedDevice;
  List<fb.BluetoothService> bluetoothServices;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  String _address = "...";

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;
  // enable and disable scan device button
  bool isButtonDisabled = false;
  int _deviceState;
  // Define a new class member variable
// for storing the devices list

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  BluetoothDevice device;
  bool scanning = false;
  List<fb.ScanResult> dta = [];

  List<int> rssiList = [];

  startStop() {
    if (scanning) {
      _bluetoothfb.stopScan();

      /* _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("you have ${dta.length} devices"),
      ));*/
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "You have ${dta.length} devices",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.amber[900],
      ));
    } else {
      _bluetoothfb.startScan(timeout: Duration(seconds: 4));

      var subscription = _bluetoothfb.scanResults.listen((results) {
        for (fb.ScanResult r in results) {
          rssiList.add(r.rssi);
          print(
              'This is from startStop ${r.device.name} found! rssi: ${r.rssi} and device added : ${rssiList.length}');
        }
      });
    }
    setState(() {
      scanning = !scanning;
    });
  }

  // To track whether the device is still connected to Bluetooth
  //bool get isConnected => connection != null && connection.isConnected;

  //String get address => null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _deviceState = 0;
    // checkblueToothState();
    _bluetooth.state.then((state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_ON) {
          isButtonDisabled = true;
        } else {
          isButtonDisabled = false;
        }
      });
    });
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        if (_bluetoothState == BluetoothState.STATE_ON) {
          isButtonDisabled = true;
        } else {
          isButtonDisabled = false;
        }
      });
    });

    enableBluetooth();
  }

  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the Bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      return true;
    } else {}
    return false;
  }

  Future<void> disableBluetooth() async {
    _bluetoothState = await _bluetooth.state;
    if (_bluetoothState == BluetoothState.STATE_ON) {
      await _bluetooth.requestDisable();

      return true;
    } else {}
    return false;
  }

// to check blue tooth state
  checkblueToothState() {
    _bluetooth.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        if (_bluetoothState == BluetoothState.STATE_ON) {
          isButtonDisabled = true;
        } else {
          isButtonDisabled = false;
        }

        // For retrieving the paired devices list
        // getPairedDevices();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Enable Bluetooth',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 1,
                    child: Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            // Enable Bluetooth
                            await _bluetooth.requestEnable();
                            // await getPairedDevices();
                          } else {
                            // Disable Bluetooth
                            await _bluetooth.requestDisable();
                            // await getPairedDevices();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Text(_bluetoothState.toString()),
            //_scanDeviceButton(),
            RaisedButton(
              /*onPressed: isButtonDisabled
                  ? () {
                      startStop();
                    }
                  : null,*/
              onPressed: () {
                startStop();
              },
              child: Text(
                scanning ? "Stop Scanning" : "Start Scanning",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              textColor: Colors.white,
              color: Colors.amber[900],
            ),

            Flexible(
              child: StreamBuilder<List<fb.ScanResult>>(
                stream: fb.FlutterBlue.instance.scanResults,
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
            ),
          ],
        ),
      ),
    );
  }
}

/* MyWidget Function */

Widget myWidget(AsyncSnapshot<dynamic> snapshot, int index) {
  print("object");

  //print("Name: ${snapshot.data[index].device.name}");
  //return Text(snapshot.data[index].device.name.toString());
  if (snapshot.hasData) {
    print(snapshot.data);
    //print(snapshot.data[index].device.id);
    print(snapshot.data[index].rssi);
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
                ),
                Text(snapshot.data[index].device.name.toString() == ''
                    ? '(unknown device)'
                    : snapshot.data[index].device.name.toString()),
                Text(
                  snapshot.data[index].rssi.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                //service.uuid.toString()
                /* Text(
                  snapshot.data[index].serviceUuids.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),*/
              ],
            )),
      ),
    );
    // MyCard();
  } else {
    // return Text("No Device Found");
    print("No Device");
  }
}
