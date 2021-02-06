import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';

class ScanPage extends StatefulWidget {
  ScanPage({Key key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String _data = '';

  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  bool _scanning = false;

  FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();
  @override
  void initState() {
    super.initState();

    _bluetooth.devices.listen((device) {
      /* Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "You have ${device.name} devices",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.amber[900],
      ));*/

      setState(() {
        _data += device.name + '\n (${device.address}) \n' + '- \n';
        // devicesList.add(device);
      });
    });
    _bluetooth.scanStopped.listen((device) {
      setState(() {
        _scanning = false;
        _data += 'scan stopped\n';
      });
    });
  }

  Future<BluetoothDevice> startStop() async {
    if (_scanning) {
      await _bluetooth.stopScan();
      debugPrint("scanning stoped");
      print("device length: in if ${devicesList.length}");

      setState(() {
        /* var subscription = _bluetooth.devices.listen((results) {
          devicesList.add(results);
        });*/
        _data = '';
      });
    } else {
      await _bluetooth.startScan(pairedDevices: false);
      debugPrint("scanning started");
      // print("device length in else: ${devicesList.length}");
      _bluetooth.devices.listen((device) {
        setState(() {
          _data += device.name + '\n (${device.address}) \n' + '- \n';
          devicesList.add(device);
        });
      });
      /*
      setState(() {
        _scanning = true;
      });*/
    }

    setState(() {
      _scanning = !_scanning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flexible(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: //Text(_data)
                  Column(
                children: [
                  Text(devicesList.length.toString()),

                  // Text(_data),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: RaisedButton(
                    child: Text(_scanning ? 'Stop scan' : 'Start scan'),
                    onPressed: () async {
                      try {
                        if (_scanning) {
                          await _bluetooth.stopScan();
                          debugPrint("scanning stoped");
                          print(devicesList.length);
                          setState(() {
                            _data = '';
                          });
                        } else {
                          await _bluetooth.startScan(pairedDevices: false);
                          debugPrint("scanning started");
                          print(devicesList.length);
                          /* setState(() {
                            
                            _scanning = true;
                          });*/
                          /* _bluetooth.devices.listen((device) {
                            setState(() {
                              devicesList.add(device);
                            });
                          });*/

                          /* setState(() {
                            _scanning = !_scanning;
                          });*/
                        }
                      } on PlatformException catch (e) {
                        debugPrint(e.toString());
                      }
                    }),
                /* onPressed: () {
                      startStop();
                    }),*/
              ),
            )
          ],
        ),
      ),
    );
  }
}
