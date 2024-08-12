import 'package:flutter/material.dart';
import 'package:remedioquis/gAltura.dart';
import 'package:remedioquis/gTemp.dart';
import 'package:remedioquis/textos.dart';
import 'gPresion.dart';
import 'dart:convert';
import 'dart:async'; // Importa el paquete dart:async
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  bool BTConnected = false;
  double? temp = 0, pres = 0, alt = 0;

  Timer? _timer; // Declara el Timer

  void connectToDevice() async {
    try {
      connection = await BluetoothConnection.toAddress("08:F9:E0:BD:EE:6E");
      BTConnected = true;
      getData();
    } catch (e) {
      print(e);
    }
  }

  void permissions() async {
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetooth.request();
    await Permission.location.request();
  }

  void turnOnBluetooth() async {
    await _bluetooth.requestEnable();
  }

  void sendData(String msg) {
    if (connection != null) {
      if (connection!.isConnected) {
        connection?.output.add(ascii.encode("$msg\n"));
      }
    }
  }

  void getData() {
    connection!.input!.listen((event) {
      List<String> datos = String.fromCharCodes(event).split('//');
      double? tempBlue = double.tryParse(datos[0]);
      double? presBlue = double.tryParse(datos[1]);
      double? altBlue = double.tryParse(datos[2]);
      if (presBlue != null) {
        pres = presBlue;
      }
      if (tempBlue != null) {
        temp = tempBlue;
      }
      if (altBlue != null) {
        alt = altBlue;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    permissions();
    turnOnBluetooth();
    connectToDevice();

    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        getData();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              sendData("obtener");
            },
            icon: const Icon(
              Icons.restore,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gtemp(
              temp: temp,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GPresion(
                  pres: pres,
                ),
                GAltura(
                  alt: alt,
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Textos(temp: temp),
    );
  }
}