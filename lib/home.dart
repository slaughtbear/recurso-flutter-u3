import 'package:flutter/material.dart';
import 'package:remedioquis/gAltura.dart';
import 'package:remedioquis/gTemp.dart';
import 'package:remedioquis/textos.dart';
import 'gPresion.dart';
import 'dart:convert';
import 'dart:async'; // Importa el paquete dart:async
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue/flutter_blue.dart'; // Paquete para trabajar con bluetooth BLE

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterBlue _flutterBlue = FlutterBlue.instance; // Instancia de FlutterBlue para interactuar con dispositivos Bluetooth
  BluetoothDevice? _device; // Variable que almacena la referencia al dispositivo Bluetooth conectado
  bool _btConnected = false; // Indicador de estado para saber si el dispositivo Bluetooth está conectado
  double? temp = 0, pres = 0, alt = 0;

  // Variables temporales para almacenar los datos recibidos y actualiazar la interfaz cada 30 segundos
  double? _tempReceived;
  double? _presReceived;
  double? _altReceived;

  Timer? _updateTimer; // Variable para actualizar la interfaz cada 30 segundos

  // FUNCIÓN PARA CONECTARSE AL ESP32
  void connectToDevice() async {
    try { // Se escanean los dispositivos BLE cercanos...
      _flutterBlue.startScan(timeout: Duration(seconds: 4)); // El escaneo se detiene después de 4 segundos si no se encuentra nada

      _flutterBlue.scanResults.listen((results) { // Si se detecta un dispositivo entonces...
        for (ScanResult r in results) { // Se itera sobre todos los dispositivos encontrados durante el escaneo
          if (r.device.name == 'ESP32_IVN') { // Se verifica si el nombre del dispositivo coincide con el del ESP32
            _device = r.device; // Si se encuentra el dispositivo se guarda en en _device
            _flutterBlue.stopScan(); // Después de encontrar el dispositivo se detiene el escaneo
            _connectToDevice(); // Llama a esta función para iniciar la conexión con el dispositivo encontrado
            break;
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _connectToDevice() async {
    try {
      if (_device != null) { // Verificación para asegurarse de que el dispositivo no es null antes de intentar la conexión
        await _device!.connect(); // Inicia la conexión con el dispositivo almacenado en _device
        _btConnected = true; // Si la conexión es exitosa se cambia el indicador de estado a true
        _getData(); // Llama la función para obtener datos una vez que hay conexión activa
      }
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

  Future<void> requestPermissions() async {
    if (await Permission.bluetoothConnect.isDenied) {
      var status = await Permission.bluetoothConnect.request();
      if (!status.isGranted) {
        // Mostrar un mensaje o manejar el error
        print('Permiso de Bluetooth Connect denegado');
        return;
      }
    }
    if (await Permission.bluetoothScan.isDenied) {
      var status = await Permission.bluetoothScan.request();
      if (!status.isGranted) {
        print('Permiso de Bluetooth Scan denegado');
        return;
      }
    }
    if (await Permission.bluetooth.isDenied) {
      var status = await Permission.bluetooth.request();
      if (!status.isGranted) {
        print('Permiso de Bluetooth denegado');
        return;
      }
    }
    if (await Permission.location.isDenied) {
      var status = await Permission.location.request();
      if (!status.isGranted) {
        print('Permiso de Ubicación denegado');
        return;
      }
    }
  }

  // FUNCIÓN PARA ENVIAR DATOS
  void sendData(String msg) async {
    if (_device != null && _btConnected) {
      // Descubrir servicios y características antes de escribir
      var services = await _device!.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == '00002a6e-0000-1000-8000-00805f9b34fb') {
            // Aquí se realiza la escritura en la característica específica
            await characteristic.write(ascii.encode("$msg\n"));
            break;
          }
        }
      }
    }
  }

  void _getData() {
    if (_device != null) { // Verificación para asegurarse de que el dispositivo no es null antes de intentar obtener datos
      _device!.discoverServices().then((services) { // Busca y devuelve una lista de servicios disponibles en el dispositivo
        services.forEach((service) { // Se itera en cada servicio disponible
          if (service.uuid.toString() == '0000181a-0000-1000-8000-00805f9b34fb') { // Se verifica si el UUID del servicio actual es el definido en mi ESP32
            service.characteristics.forEach((characteristic) async { // Se itera sobre cada característica disponible
              if (characteristic.uuid.toString() == '00002a6e-0000-1000-8000-00805f9b34fb') { // Se verifica si el UUID de las características actual es el definido en mi ESP32
                try {
                  await characteristic.setNotifyValue(true); // Habilitar notificaciones
                  characteristic.value.listen((value) { // Si la característica cambia entonces...
                    String receivedData = String.fromCharCodes(value);
                    //print('Datos recibidos: $receivedData');

                    // Solo divide los datos si contienen al menos dos "//"
                    List<String> datos = receivedData.split('//');
                    if (datos.length == 3) {
                      // Procesamiento de los datos recibidos a decimales
                      double? tempBlue = double.tryParse(datos[0]);
                      double? presBlue = double.tryParse(datos[1]);
                      double? altBlue = double.tryParse(datos[2]);

                      // Si la conversión fue exitosa entonces...
                      if (presBlue != null) {
                        _presReceived = presBlue; // Asigna los datos recibidos a las variables temporales
                      }
                      if (tempBlue != null) {
                        _tempReceived = tempBlue; // Asigna los datos recibidos a las variables temporales
                      }
                      if (altBlue != null) {
                        _altReceived = altBlue; // Asigna los datos recibidos a las variables temporales
                        //print('Altitud procesada: $altBlue');
                      }

                      // Se actualiza la interfaz para reflejar los nuevos valores
                      setState(() {});
                    } else {
                      print('Datos incompletos recibidos: $receivedData');
                    }
                  });
                } catch (e) {
                  print('Error al habilitar notificaciones: $e');
                }
              }
            });
          }
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      connectToDevice(); // Solo intentamos conectar si los permisos han sido otorgados.
      _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        setState(() {
          if (_tempReceived != null) temp = _tempReceived;
          if (_presReceived != null) pres = _presReceived;
          if (_altReceived != null) alt = _altReceived;
        });
      });
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel(); // Se cancela el temporizador al destruir el widget para liberar recursos
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
              // Enviar el comando para solicitar datos al ESP32
              sendData("obtener"); // Asegúrate de que este mensaje coincide con lo que el ESP32 espera para enviar los datos.

              // Actualizar la interfaz con los datos recién recibidos
              setState(() {
                if (_tempReceived != null) temp = _tempReceived;
                if (_presReceived != null) pres = _presReceived;
                if (_altReceived != null) alt = _altReceived;
              });
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