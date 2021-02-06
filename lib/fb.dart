import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Flutterb extends StatefulWidget {
  Flutterb({Key key}) : super(key: key);

  @override
  _FlutterbState createState() => _FlutterbState();
}

class _FlutterbState extends State<Flutterb> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  BluetoothDevice device;

  bool scanning = false;
  var scanSubscription;

  void scanForDevices() async {
    scanSubscription =
        flutterBlue.scanResults.listen((List<ScanResult> scanResults) async {
      /* if (scanResult.device.name == "your_device_name") {
        print("found device");
        //Assigning bluetooth device
        device = scanResult.device;
        //After that we stop the scanning for device
        stopScanning();
      }*/
      for (ScanResult result in scanResults) {
        _addDeviceTolist(result.device);
      }
    });
  }

  void stopScanning() {
    flutterBlue.stopScan();
    scanSubscription.cancel();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        /*onPressed: isButtonDisabled
                  ? () {
                      startStop();
                    }
                  : null,*/
        onPressed: () {
          scanForDevices();
        },
        child: Text(
          scanning ? "Stop Scanning" : "Start Scanning",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        textColor: Colors.white,
        color: Colors.amber[900],
      ),
    );
  }
}
