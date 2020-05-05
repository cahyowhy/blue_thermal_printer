import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:sprintf/sprintf.dart';

class BlueThermalPrinter {
  static const int STATE_OFF = 10;
  static const int STATE_TURNING_ON = 11;
  static const int STATE_ON = 12;
  static const int STATE_TURNING_OFF = 13;
  static const int STATE_BLE_TURNING_ON = 14;
  static const int STATE_BLE_ON = 15;
  static const int STATE_BLE_TURNING_OFF = 16;
  static const int ERROR = -1;
  static const int CONNECTED = 1;
  static const int DISCONNECTED = 0;

  /// options for paper size 48, 58, 80
  /// you can change this sakkarepmu
  int paperSize = 48;

  int get fixedCharLength {
    return paperSize - 6;
  }

  setPaperSize({int size = 48}) {
    BlueThermalPrinter.instance.paperSize = size;
  }

  static String printCustomLeftRight(String left, String right) {
    int totalChar = BlueThermalPrinter.instance.fixedCharLength ~/ 2;
    int leftChar = totalChar;
    int rightChar = totalChar;

    String leftFormated = left;
    String rightFormated = right;

    if (left.length > totalChar) {
      if (left.length + right.length <= BlueThermalPrinter.instance.fixedCharLength) {
        leftChar = left.length;
        rightChar -= leftChar - totalChar;
      } else {
        leftFormated = left.substring(0, totalChar);
      }
    }

    if (right.length > totalChar) {
      if (right.length + left.length <= BlueThermalPrinter.instance.fixedCharLength) {
        rightChar = right.length;
        leftChar -= rightChar - totalChar;
      } else {
        rightFormated = right.substring(0, totalChar);
      }
    }

    return sprintf(
        "%-${leftChar}s%${rightChar}s", [leftFormated, rightFormated]);
  }

  static const String namespace = 'blue_thermal_printer';

  static const MethodChannel _channel =
      const MethodChannel('$namespace/methods');

  static const EventChannel _readChannel =
      const EventChannel('$namespace/read');

  static const EventChannel _stateChannel =
      const EventChannel('$namespace/state');

  final StreamController<MethodCall> _methodStreamController =
      new StreamController.broadcast();

  BlueThermalPrinter._() {
    _channel.setMethodCallHandler((MethodCall call) {
      _methodStreamController.add(call);
    });
  }

  static BlueThermalPrinter _instance = new BlueThermalPrinter._();

  static BlueThermalPrinter get instance => _instance;

  Stream<int> onStateChanged() =>
      _stateChannel.receiveBroadcastStream().map((buffer) => buffer);

  Stream<String> onRead() =>
      _readChannel.receiveBroadcastStream().map((buffer) => buffer.toString());

  Future<bool> get isAvailable async =>
      await _channel.invokeMethod('isAvailable');

  Future<bool> get isOn async => await _channel.invokeMethod('isOn');

  Future<bool> get isConnected async =>
      await _channel.invokeMethod('isConnected');

  Future<bool> get openSettings async =>
      await _channel.invokeMethod('openSettings');

  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List list = await _channel.invokeMethod('getBondedDevices');
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  Future<dynamic> connect(BluetoothDevice device) =>
      _channel.invokeMethod('connect', device.toMap());

  Future<dynamic> disconnect() => _channel.invokeMethod('disconnect');

  Future<dynamic> write(String message) =>
      _channel.invokeMethod('write', {'message': message});

  Future<dynamic> writeBytes(Uint8List message) =>
      _channel.invokeMethod('writeBytes', {'message': message});

  Future<dynamic> printCustom(String message, int size, int align) =>
      _channel.invokeMethod(
          'printCustom', {'message': message, 'size': size, 'align': align});

  Future<dynamic> printNewLine() => _channel.invokeMethod('printNewLine');

  Future<dynamic> paperCut() => _channel.invokeMethod('paperCut');

  Future<dynamic> drawLineStripe(int size, int align, {String char = "-"}) {
    String line = "";

    for (int i = 1; i <= fixedCharLength; i++) {
      line += char;
    }

    return printCustom(line, size, align);
  }

  Future<dynamic> printImage(String pathImage, int align, int yPadding) =>
      _channel.invokeMethod('printImage', {
        'pathImage': pathImage,
        'align': align,
        'paperSize': paperSize,
        'yPadding': yPadding
      });

  Future<dynamic> printImageCustom(String pathImage) =>
      _channel.invokeMethod('printImageCustom', {'pathImage': pathImage});

  Future<dynamic> printQRcode(
          String textToQR, int width, int height, int align, int paperSize) =>
      _channel.invokeMethod('printQRcode', {
        'textToQR': textToQR,
        'paperSize': paperSize,
        'width': width,
        'height': height,
        'align': align
      });

  Future<dynamic> printLeftRight(
      String string1, String string2, int size, int align) {
    return this
        .printCustom(printCustomLeftRight(string1, string2), size, align);
  }
}

class BluetoothDevice {
  final String name;
  final String address;
  final int type = 0;
  bool connected = false;

  BluetoothDevice(this.name, this.address);

  BluetoothDevice.fromMap(Map map)
      : name = map['name'],
        address = map['address'];

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'address': this.address,
        'type': this.type,
        'connected': this.connected,
      };

  operator ==(Object other) {
    return other is BluetoothDevice && other.address == this.address;
  }

  @override
  int get hashCode => address.hashCode;
}
