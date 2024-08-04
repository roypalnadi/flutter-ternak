import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:ternak/animal_detail.dart';

const bgColor = Color(0xfffafafa);

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isScanCompleted = false;
  MobileScannerController controller = MobileScannerController();

  void closeScreen() {
    isScanCompleted = false;
  }

  @override
  void dispose() {
    // Mematikan kamera dengan memanggil metode dispose
    controller.dispose();
    super.dispose();
  }

  void _getHewan(BarcodeCapture barcodes) async {
    if (!isScanCompleted) {
      String code = '';
      for (var element in barcodes.barcodes) {
        code = element.rawValue ?? '-----';
      }
      isScanCompleted = true;

      controller.stop();

      var value = await FirebaseFirestore.instance
          .collection("hewan")
          .doc(code)
          .snapshots()
          .first;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AnimalDetail(
              doc: value,
            );
          },
        ),
      ).then((value) => setState(() {
            closeScreen();
            controller.start();
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Place QR Code in the area",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Scanning will be started automatically",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              flex: 4,
              child: Stack(
                children: <Widget>[
                  MobileScanner(
                    controller: controller,
                    onDetect: (barcodes) {
                      if (!isScanCompleted) {
                        _getHewan(barcodes);
                      }
                    },
                  ),
                  QRScannerOverlay(
                    overlayColor: bgColor,
                    borderColor: Colors.blue,
                    scanAreaSize: const Size.square(280),
                  )
                ],
              )),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                "SCANNER",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
