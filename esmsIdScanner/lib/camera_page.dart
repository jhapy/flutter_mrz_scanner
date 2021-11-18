import 'package:flutter/material.dart';
import 'package:flutter_mrz_scanner/flutter_mrz_scanner.dart';
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool isParsed = false;
  MRZController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: MRZScanner(
        withOverlay: true,
        onControllerCreated: onControllerCreated,
      ),
    );
  }

  @override
  void dispose() {
    controller?.stopPreview();
    super.dispose();
  }

  void onControllerCreated(MRZController controller) {
    this.controller = controller;
    controller.onParsed = (result) async {
      if (isParsed) {
        return;
      }
      isParsed = true;

      await showDialog<void>(
          context: context,
          builder: (context) =>
              AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Document type: ${result.documentType}'),
                      Text('Country: ${result.countryCode}'),
                      Text('Surnames: ${result.surnames}'),
                      Text('Given names: ${result.givenNames}'),
                      Text('Document number: ${result.documentNumber}'),
                      Text(
                          'Nationality code: ${result.nationalityCountryCode}'),
                      Text('Birthdate: ${result.birthDate}'),
                      Text('Sex: ${result.sex}'),
                      Text('Expriy date: ${result.expiryDate}'),
                      Text('Personal number: ${result.personalNumber}'),
                      Text('Personal number 2: ${result.personalNumber2}'),
                      ElevatedButton(
                        child: const Text('ok'),
                        onPressed: () {
                          isParsed = false;
                          http.post(Uri.parse(
                              "http://192.168.212.62:8088/esms/api/mobile"),
                              body: {
                                'document_number': '${result.documentNumber}'
                              });
                          return Navigator.pop(context, true);
                        },
                      ),
                    ],
                  )));
    };
    controller.onError = (error) => print(error);

    controller.startPreview();
  }
}