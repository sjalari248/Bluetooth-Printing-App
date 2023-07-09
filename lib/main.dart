import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Thermal Printing'),
      ),
      body: Container(
        // Add your widget tree or UI components here
      ),
    );
  }

}


class BarcodeGeneratorScreen extends StatefulWidget {
  @override
  _BarcodeGeneratorScreenState createState() => _BarcodeGeneratorScreenState();
}

class _BarcodeGeneratorScreenState extends State<BarcodeGeneratorScreen> {
  TextEditingController _inputController = TextEditingController();
  Image? _barcodeImage;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _generateBarcode() async {
    String inputData = _inputController.text;

    // TODO: Generate barcode using a barcode generation package
    BarcodeWidget barcodeWidget = BarcodeWidget(
      barcode: Barcode.code128(),
      data: inputData,
    );
    Image barcodeImage = await barcodeWidget.toImage(width: 200, height: 100);

    setState(() {
      _barcodeImage = barcodeImage;
    });
  }


  void _navigateToBluetoothDeviceSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BluetoothDeviceSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Enter your data',
              ),
            ),
            ElevatedButton(
              onPressed: _generateBarcode,
              child: Text('Generate Barcode'),
            ),
            if (_barcodeImage != null) ...[
              SizedBox(height: 16.0),
              _barcodeImage!,
            ],
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _navigateToBluetoothDeviceSelection,
              child: Text('Print Barcode'),
            ),
          ],
        ),
      ),
    );
  }
}

class BluetoothDeviceSelectionScreen extends StatefulWidget {
  @override
  _BluetoothDeviceSelectionScreenState createState() =>
      _BluetoothDeviceSelectionScreenState();
}

class _BluetoothDeviceSelectionScreenState
    extends State<BluetoothDeviceSelectionScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> _devices = [];

  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  void _startScan() {
    _scanSubscription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name.isNotEmpty) {
        _addDeviceToList(scanResult.device);
      }
    });
  }

  void _addDeviceToList(BluetoothDevice device) {
    if (!_devices.contains(device)) {
      setState(() {
        _devices.add(device);
      });
    }
  }

// ...

  void _connectAndPrint(BluetoothDevice device) {
    // TODO: Connect to the device and send barcode image for printing
    // Use flutter_blue package for connecting and communication

    // Example code for connecting to the selected device
    device.connect().then((_) {
      // Print the barcode image
      // Replace 'bluetoothCharacteristic' with the appropriate characteristic
      // that the printer uses for receiving print data.
      // Replace 'barcodeImageBytes' with the actual bytes of the barcode image.

      device.writeCharacteristic(
        bluetoothCharacteristic, // Replace with the correct characteristic
        barcodeImageBytes, // Replace with the actual barcode image bytes
      );

      // Disconnect from the device after printing
      device.disconnect();
    });
  }

// ...


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Device Selection'),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = _devices[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id.toString()),
            onTap: () {
              if (device.name == '3-inch Bluetooth Heat Printer') {
                _connectAndPrint(device);
              } else {
                // Handle non-compatible devices or show an error message
              }
            },
          );
        },
      ),
    );
  }
}
