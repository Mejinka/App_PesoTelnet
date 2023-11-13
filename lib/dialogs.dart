//import 'package:flutter/material.dart';

////class FrontPesagensState extends State<FrontPesagens> {
//  void _showErrorDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: const Text('Erro'),
//          content: const Text('O campo Produto não pode estar vazio.'),
//          actions: <Widget>[
//            TextButton(
//              child: const Text('OK'),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }
//
//  void _showSuccessDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: const Text('Sucesso'),
//          content: const Text('Produto salvo com sucesso!'),
//          actions: <Widget>[
//            TextButton(
//              child: const Text('OK'),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }
//
//  void _showOverloadDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: const Text('Overload'),
//          content:
//              const Text('Não é possível salvar o peso em estado de overload.'),
//          actions: <Widget>[
//            TextButton(
//              child: const Text('OK'),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }
//
//  void _showUnderloadDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: const Text('Underload'),
//          content: const Text(
//              'Não é possível salvar o peso em estado de underload.'),
//          actions: <Widget>[
//            TextButton(
//              child: const Text('OK'),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }
//
//  void _showZeroDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: const Text('Zero'),
//          content: const Text('Deseja salvar com o peso em Zero?'),
//          actions: <Widget>[
//            TextButton(
//              child: const Text('OK'),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }
//
//  @override
//  void dispose() {
//    _updateTimer?.cancel();
//    pesoController.dispose();
//    super.dispose();
//  }
//
//  void _showSettingsDialog(context) async {
//    final localContext = context;
//
//    await telnet.loadConfig();
//
//    showDialog(
//      context: localContext,
//      builder: (BuildContext context) {
//        final currentConfig = telnet.getConfig();
//        hostController.text = currentConfig['host'];
//        portController.text = currentConfig['port'].toString();
//
//        return AlertDialog(
//          title: const Text('Settings'),
//          content: StatefulBuilder(
//            builder: (BuildContext context, StateSetter setState) {
//              return SingleChildScrollView(
//                child: Column(
//                  mainAxisSize: MainAxisSize.min,
//                  children: [
//                    TextField(
//                      controller: hostController,
//                      decoration: InputDecoration(
//                        enabledBorder: const OutlineInputBorder(
//                          borderSide: BorderSide(color: Colors.black26),
//                        ),
//                        focusedBorder: const OutlineInputBorder(
//                          borderSide: BorderSide(color: Colors.black26),
//                        ),
//                        errorBorder: const OutlineInputBorder(
//                          borderSide: BorderSide(color: Colors.blue),
//                        ),
//                        labelText: "Ip",
//                        errorText: hostError,
//                      ),
//                      keyboardType: TextInputType.number,
//                      onChanged: (value) {
//                        if (!value.split('.').every(
//                            (segment) => int.tryParse(segment) != null)) {
//                          hostError = "IP inválido";
//                        } else {
//                          hostError = null;
//                        }
//                        setState(() {});
//                      },
//                    ),
//                    const SizedBox(height: 10),
//                    TextField(
//                      controller: portController,
//                      decoration: InputDecoration(
//                        enabledBorder: const OutlineInputBorder(
//                          borderSide: BorderSide(color: Colors.black26),
//                        ),
//                        focusedBorder: const OutlineInputBorder(
//                          borderSide: BorderSide(color: Colors.black26),
//                        ),
//                        labelText: "Port",
//                        errorText: portError,
//                      ),
//                      keyboardType: TextInputType.number,
//                      onChanged: (value) {
//                        if (int.tryParse(value) == null) {
//                          portError = "Porta inválida";
//                        } else {
//                          portError = null;
//                        }
//                        setState(() {});
//                      },
//                    ),
//                  ],
//                ),
//              );
//            },
//          ),
//          actions: [
//            TextButton(
//              child: const Text('Cancel'),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//            TextButton(
//              child: const Text('Save'),
//              onPressed: () async {
//                if (hostError == null && portError == null) {
//                  telnet.setConfig(
//                      hostController.text, int.parse(portController.text));
//                  Navigator.of(context).pop();
//                  ScaffoldMessenger.of(context).showSnackBar(
//                    const SnackBar(
//                      content: Text('Configurações salvas!'),
//                      duration: Duration(seconds: 2),
//                    ),
//                  );
//                } else {
//                  ScaffoldMessenger.of(context).showSnackBar(
//                    const SnackBar(
//                      content:
//                          Text('Não foi possível salvar! Verifique os campos.'),
//                      duration: Duration(seconds: 2),
//                    ),
//                  );
//                }
//                await telnet.saveConfig();
//
//                setState(() {});
//              },
//            )
//          ],
//        );
//      },
//    );
//  }
//}
////