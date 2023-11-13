// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:easy_weigh_project2/dart.dart';
import 'package:easy_weigh_project2/table.dart';
import 'package:line_icons/line_icon.dart';
import 'dart:async';
import 'global.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
}

class FrontPesagens extends StatefulWidget {
  const FrontPesagens({super.key});

  @override
  FrontPesagensState createState() => FrontPesagensState();
}

class FrontPesagensState extends State<FrontPesagens> {
  Color textFieldColor = Colors.white;
  Color textFieldTextColor = Colors.grey.shade600;
  Color test = Colors.black;

  String est1 = "0000";
  String est2 = "0000";
  String est3 = "0000";
  String est4 = "0000";
  final updateInterval = const Duration(seconds: 1);
  Timer? _updateTimer;

  final TextEditingController pesoController = TextEditingController();
  final TextEditingController prodController = TextEditingController();
  final TelnetClient telnet = TelnetClient();
  List<String> resultados = [];

  @override
  void initState() {
    super.initState();
    _loadInitialConfig();
    _startPesoUpdate();
    requestStoragePermission();
  }

  void printEstados() {
    print(_getEstabilidade());
    print(_getOverload());
    print(_getZero());
    print(_getUnderload());
    print(_getPesoMinimo());
    print(_getTara());
  }

  String _getOverload() {
    if (est2[1] == '1') {
      return 'Overload';
    } else {
      return 'Não Overload';
    }
  }

  String _getEstabilidade() {
    if ((est2[2] == '1')) {
      return 'l> <l';
    } else {
      return '~';
    }
  }

  String _getZero() {
    return (est1[0] == '1') ? '>0<' : '';
  }

  String _getPesoMinimo() {
    return (est1[3] == '1' ? 'Min' : '');
  }

  String _getUnderload() {
    if (est4[0] == '1') {
      return 'Underload';
    } else {
      return 'Nao Underload';
    }
  }

  String _getTara() {
    return (est3[3] == '1' ? 'T' : '');
  }

  void checkOver() {
    if (est2[1] == '1') {
      pesoController.text = 'Overload!';
      setState(() {
        textFieldColor = Colors.white;
        textFieldTextColor = Colors.black;
      });
    } else if (est4[0] == '1') {
      pesoController.text = 'Underload!';
      setState(() {
        textFieldColor = Colors.white;
        textFieldTextColor = Colors.black;
      });
    } else {
      setState(() {
        textFieldColor = Colors.white;
        textFieldTextColor = Colors.grey.shade600;
      });
    }
  }

  void _startPesoUpdate() {
    _updateTimer = Timer.periodic(updateInterval, (timer) => peso());
  }

  void _loadInitialConfig() async {
    await telnet.loadConfig();
    final currentConfig = telnet.getConfig();
    telnet.setConfig(currentConfig['host'], currentConfig['port']);
    await telnet.connect();

    setState(() {});
  }

  String byteToBinaryString(int byte) {
    String char = String.fromCharCode(byte);

    if (customBinaryMapping.containsKey(char)) {
      return customBinaryMapping[char]!;
    }

    return byte.toRadixString(2).padLeft(8, '0');
  }

  Map<String, String> customBinaryMapping = {
    "0": "0000",
    "1": "0001",
    "2": "0010",
    "3": "0011",
    "4": "0100",
    "5": "0101",
    "6": "0110",
    "7": "0111",
    "8": "1000",
    "9": "1001",
    "A": "1010",
    "B": "1011",
    "C": "1100",
    "D": "1101",
    "E": "1110",
    "F": "1111",
  };

  Future<void> peso() async {
    try {
      if (!telnet.isConnected) {
        await telnet.connect();
      }
      String responsePeso = await telnet.sendCommand("Xn");

      if (responsePeso.length >= 18) {
        String resultado = responsePeso.substring(2, 13);
        setState(() {
          pesoController.text = resultado;
          est1 = byteToBinaryString(responsePeso.codeUnitAt(13));
          est2 = byteToBinaryString(responsePeso.codeUnitAt(14));
          est3 = byteToBinaryString(responsePeso.codeUnitAt(15));
          est4 = byteToBinaryString(responsePeso.codeUnitAt(16));
          print("1  ${byteToBinaryString(responsePeso.codeUnitAt(13))}");
          print("2  ${byteToBinaryString(responsePeso.codeUnitAt(14))}");
          print("3  ${byteToBinaryString(responsePeso.codeUnitAt(15))}");
          print("4  ${byteToBinaryString(responsePeso.codeUnitAt(16))}");

          printEstados();
          checkOver();
          resultados.add(resultado);
        });
        print(resultado);

        print("estado1" " $est1");
        print("estado2" " $est2");
        print("estado3" " $est3");
        print("estado4" " $est4");
      }
    } catch (e) {
      print("Erro ao buscar peso: $e");
      if (!telnet.isConnected) {
        await telnet.connect();
      }
    }
  }

  Future<void> zero() async {
    try {
      if (!telnet.isConnected) {
        await telnet.connect();
      }
      String responsePeso = await telnet.sendCommand("AZ");

      if (responsePeso.length >= 18) {
        String resultado = responsePeso.substring(3, 12);
        setState(() {
          pesoController.text = resultado;
        });
        print(pesoController.text);
        print("$resultado + 55");
      }
    } catch (e) {
      print("Erro ao buscar peso: $e");
      if (!telnet.isConnected) {
        await telnet.connect();
      }
    }
  }

  Future<void> printT() async {
    try {
      if (!telnet.isConnected) {
        await telnet.connect();
      }
      String responsePeso = await telnet.sendCommand("Xn");

      if (responsePeso.length >= 18) {
        String resultado = responsePeso.substring(2, 13);
        setState(() {
          pesoController.text = resultado;
          est1 = byteToBinaryString(responsePeso.codeUnitAt(13));
          est2 = byteToBinaryString(responsePeso.codeUnitAt(14));
          est3 = byteToBinaryString(responsePeso.codeUnitAt(15));
          est4 = byteToBinaryString(responsePeso.codeUnitAt(16));
          print("1  ${byteToBinaryString(responsePeso.codeUnitAt(13))}");
          print("2  ${byteToBinaryString(responsePeso.codeUnitAt(14))}");
          print("3  ${byteToBinaryString(responsePeso.codeUnitAt(15))}");
          print("4  ${byteToBinaryString(responsePeso.codeUnitAt(16))}");

          printEstados();
          checkOver();
          resultados.add(resultado);
        });
        print(resultado);
        if (est2[1] == '1') {
          print("Peso não adicionado devido a overload.");
          _showOverloadDialog();
        } else {
          setState(() {
            resultadosGlobais.add(
                [formatDate(DateTime.now()), prodController.text, resultado]);
          });
        }
        print("estado1" " $est1");
        print("estado2" " $est2");
        print("estado3" " $est3");
        print("estado4" " $est4");
      }
    } catch (e) {
      print("Erro ao buscar peso: $e");
      if (!telnet.isConnected) {
        await telnet.connect();
      }
    }
  }

  Future<void> tara() async {
    try {
      await telnet.connect();
      String responsePeso = await telnet.sendCommand("AT");
      setState(() {
        pesoController.text = responsePeso;
      });
      print(pesoController.text);
    } catch (e) {
      print("Erro ao buscar peso: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.list, size: 35),
            onSelected: (value) {
              if (value == 'settings') {
                _showSettingsDialog(context);
              }
              if (value == 'tables') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Tables()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configurações'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'tables',
                child: ListTile(
                  leading: Icon(Icons.tab),
                  title: Text('Tabelas'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 25),
        ],
        title: const Text("Cachapuz"),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 70.0,
        toolbarOpacity: 0.9,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(50),
              bottomLeft: Radius.circular(50)),
        ),
        elevation: 1.00,
        backgroundColor: Colors.red.shade800,
      ),
      body: Container(
        constraints: BoxConstraints(minHeight: screenheight),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 0.2 * screenheight,
                    ),
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.centerRight,
                          children: <Widget>[
                            SizedBox(
                              width: 0.7 * screenWidth,
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: pesoController,
                                enabled: false,
                                style: TextStyle(
                                    fontSize: 20.0, color: textFieldTextColor),
                                decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  fillColor: textFieldColor,
                                  filled: true,
                                  disabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  labelText: "Peso",
                                  labelStyle:
                                      TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(_getTara(),
                                      style: TextStyle(
                                          color: test, fontSize: 12.0)),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(_getZero(),
                                      style: TextStyle(
                                          color: test, fontSize: 12.0)),
                                  Text(_getPesoMinimo(),
                                      style: TextStyle(
                                          color: test, fontSize: 12.0)),
                                  Text(_getEstabilidade(),
                                      style: TextStyle(
                                          color: test, fontSize: 12.0)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: 0.7 * screenWidth,
                          child: TextField(
                            textAlign: TextAlign.center,
                            controller: prodController,
                            enabled: true,
                            style: TextStyle(
                                fontSize: 20.0, color: textFieldTextColor),
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9)),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9)),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelText: "Descrição",
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade600),
                              fillColor: textFieldColor,
                              filled: true,
                            ),
                            keyboardType: TextInputType.name,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 0.300 * screenheight,
                ),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 0.22 * screenWidth,
                          height: 0.09 * screenheight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                Colors.red.shade800,
                              ),
                            ),
                            onPressed: () {
                              zero();
                              print("Zero");
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                LineIcon.minusCircle(
                                  size: 28.0,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Zero',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 0.22 * screenWidth,
                          height: 0.09 * screenheight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                Colors.red.shade800,
                              ),
                            ),
                            onPressed: () {
                              if (prodController.text.trim().isEmpty) {
                                _showErrorDialog();
                              } else if (est2[1] == '1') {
                                print("Peso não adicionado devido a overload.");
                                _showOverloadDialog();
                              } else if (est4[0] == '1') {
                                print("Peso não adicionado devido a overload.");
                                _showUnderloadDialog();
                              } else if (est1[0] == '1') {
                                print("Peso não adicionado devido a overload.");
                                _showZeroDialog();
                              } else {
                                printT();
                                _showSuccessDialog();
                              }
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                LineIcon.print(
                                  size: 28.0,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Print',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 0.22 * screenWidth,
                          height: 0.09 * screenheight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                Colors.red.shade800,
                              ),
                            ),
                            onPressed: () {
                              tara();
                              print("Tara");
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                LineIcon.reply(
                                  size: 28.0,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Tara',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: const Text('O campo Descrição não pode estar vazio.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: const Text('Pesagem salva com sucesso!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showOverloadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Overload'),
          content:
              const Text('Não é possível salvar o peso em estado de overload.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  void _showUnderloadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Underload'),
          content: const Text(
              'Não é possível salvar o peso em estado de underload.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showZeroDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zero'),
          content: const Text('Deseja salvar com o peso em Zero?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Gravar'),
              onPressed: () async {
                await printT();
                _showSuccessDialog();
                await Future.delayed(const Duration(milliseconds: 1000));
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    pesoController.dispose();
    super.dispose();
  }

  void _showSettingsDialog(context) async {
    final localContext = context;

    await telnet.loadConfig();

    showDialog(
      context: localContext,
      builder: (BuildContext context) {
        final currentConfig = telnet.getConfig();
        hostController.text = currentConfig['host'];
        portController.text = currentConfig['port'].toString();

        return AlertDialog(
          title: const Text('Configurações'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: hostController,
                      inputFormatters: [hostControllerF],
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        labelText: "Ip",
                        errorText: hostError,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (!value.split('.').every(
                            (segment) => int.tryParse(segment) != null)) {
                          hostError = "IP inválido";
                        } else {
                          hostError = null;
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: portController,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        labelText: "Porta",
                        errorText: portError,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (int.tryParse(value) == null) {
                          portError = "Porta inválida";
                        } else {
                          portError = null;
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Gravar'),
              onPressed: () async {
                if (hostError == null && portError == null) {
                  telnet.setConfig(
                      hostController.text, int.parse(portController.text));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configurações salvas!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Não foi possível salvar! Verifique os campos.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                await telnet.saveConfig();

                setState(() {});
              },
            )
          ],
        );
      },
    );
  }
}

final hostController = TextEditingController();
final MaskTextInputFormatter hostControllerF = MaskTextInputFormatter(
    mask: '000.000.000.000', filter: {"0": RegExp(r'[0-9]')});
final portController = TextEditingController();
String? hostError;
String? portError;
