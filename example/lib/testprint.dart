import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  ///SIZE
  /// 0- normal size text
  /// 1- only bold text
  /// 2- bold with medium text
  ///3- bold with large text

  ///ALIGN
  /// 0- ESC_ALIGN_LEFT
  /// 1- ESC_ALIGN_CENTER
  /// 2- ESC_ALIGN_RIGHT
  sample(String pathImage) async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printImage(pathImage, 1, 0);
        bluetooth.printNewLine();

        bluetooth.printCustom("Cek", 3, 1);
        bluetooth.printCustom("Lorem guy cekkk", 1, 1);
        bluetooth.printCustom("cejkjjjjj", 1, 1);
        bluetooth.printNewLine();

        bluetooth.printLeftRight("1 Aug 1970", "12:00", 0, 0);
        bluetooth.printLeftRight('No. Resep', "2121#3q2", 0, 0);
        bluetooth.printLeftRight('Kasir', "Cahyo wibowo", 0, 0);
        bluetooth.drawLineStripe(0, 0);

        bluetooth.paperCut();
      }
    });
  }
}
