// ignore_for_file: avoid_print, unused_import, unnecessary_import

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_weigh_project2/global.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

Future<bool> requestStoragePermission() async {
  var status = await Permission.manageExternalStorage.status;
  if (!status.isGranted) {
    status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      print('Permissão concedida');
      return true;
    } else {
      print('Permissão não concedida');
      return false;
    }
  } else {
    print('Permissão já concedida anteriormente');
    return true;
  }
}

final pw.Document doc = pw.Document();

class Tables extends StatefulWidget {
  const Tables({super.key});

  @override
  TablesState createState() => TablesState();
}

class TablesState extends State<Tables> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.list, size: 35),
            onSelected: (value) async {
              print("Opção selecionada: $value");
              if (value == 'tables') {
                print("Gerando PDF");
                final doc = await buildPdf(resultadosGlobais);
                final bytes = await doc.save();

                Printing.sharePdf(
                    bytes: bytes, filename: 'Tabelas_Pesagem.pdf');
              }
              if (value == 'Export') {
                print("Exportando CSV");
                final csvString = convertToCsv(resultadosGlobais);
                await saveCsv(csvString);
              }
              if (value == 'Limpar') {
                print("Limpar Tabela");
                _showZeroDialog();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'tables',
                child: ListTile(
                  leading: Icon(Icons.print),
                  title: Text('Print'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Export',
                child: ListTile(
                  leading: Icon(Icons.import_export),
                  title: Text('Exportar'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Limpar',
                child: ListTile(
                  leading: Icon(Icons.restore_from_trash),
                  title: Text('Limpar'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 25),
        ],
        title: const Text("Tabelas"),
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
        constraints: const BoxConstraints(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Table(
                  border: TableBorder.all(
                    color: Colors.transparent,
                  ),
                  columnWidths: const {
                    0: FractionColumnWidth(0.3),
                    1: FractionColumnWidth(0.3),
                    2: FractionColumnWidth(0.4),
                  },
                  children: [
                    _buildTableRow(
                      "Data",
                      "Descrição",
                      "Peso",
                      isHeader: true,
                    ),
                    ...resultadosGlobais
                        .map((res) => _buildTableRow(res[0], res[1], res[2]))
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showZeroDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpar'),
          content: const Text('Deseja realmente limpar todas as pesagens?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () async {
                setState(() {
                  resultadosGlobais.clear();
                  Navigator.of(context).pop();
                });
              },
            )
          ],
        );
      },
    );
  }

  TableRow _buildTableRow(String cell1, String cell2, String cell3,
      {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: isHeader ? Colors.grey.shade800 : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textAlign: TextAlign.center,
            cell1,
            style: TextStyle(
              color: isHeader ? Colors.white : Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textAlign: TextAlign.center,
            cell2,
            style: TextStyle(
              color: isHeader ? Colors.white : Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textAlign: TextAlign.center,
            cell3,
            style: TextStyle(
              color: isHeader ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

Future<pw.Document> buildPdf(List<List<String>> data) async {
  final pw.Document doc = pw.Document();

  final ByteData headerImageData =
      await rootBundle.load('assets/images/cabecalho.png');
  final Uint8List headerImageBytes = headerImageData.buffer.asUint8List();
  final pw.MemoryImage headerImage = pw.MemoryImage(headerImageBytes);

  final tableHeaders = ['Data', 'Descrição', 'Peso'];

  doc.addPage(
    pw.MultiPage(
      header: (pw.Context context) {
        bool isFirstPage = context.pageNumber == 1;

        return pw.Column(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: -40, left: -10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(headerImage, width: 200, height: 50),
                ],
              ),
            ),
            if (!isFirstPage) pw.SizedBox(height: 20),
          ],
        );
      },
      //footer: (pw.Context context) => pw.Row(
      //  mainAxisAlignment: pw.MainAxisAlignment.center,
      //  children: [
      //    pw.Image(footerImage2, width: 400, height: 300),
      //  ],
      //),
      build: (pw.Context context) => <pw.Widget>[
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            'Lista de Pesagens',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.normal),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black),
          ),
          child: pw.Table(
            border: pw.TableBorder.all(
              color: const PdfColor.fromInt(0x00000000),
            ),
            children: [
              pw.TableRow(
                children: List<pw.Widget>.generate(
                  tableHeaders.length,
                  (col) => pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey800,
                    ),
                    padding: const pw.EdgeInsets.all(8.0),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      tableHeaders[col],
                      style: const pw.TextStyle(color: PdfColors.white),
                    ),
                  ),
                ),
              ),
              ...List<pw.TableRow>.generate(
                data.length,
                (row) => pw.TableRow(
                  children: List<pw.Widget>.generate(
                    data[row].length,
                    (col) => pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      alignment: pw.Alignment.center,
                      child: pw.Text(data[row][col]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    ),
  );

  return doc;
}

String convertToCsv(List<List<String>> data) {
  List<String> csvData = [];

  csvData.add('Data,Descrição,Peso');

  for (var row in data) {
    csvData.add(row.join(','));
  }

  return csvData.join('\n');
}

Future<void> saveCsv(String csvString) async {
  try {
    bool permissionGranted = await requestStoragePermission();
    if (!permissionGranted) {
      print("Permissão não concedida");
      return;
    }

    const path = "/storage/emulated/0/Download";
    String formatDate(DateTime date) {
      return DateFormat('yyyy-MM-dd_HH-mm-ss').format(date);
    }

    final fileName = 'Tabelas_Pesagem_${formatDate(DateTime.now())}.csv';

    final file = File('$path/$fileName');

    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    await file.writeAsString(csvString);
    print("CSV salvo em: $path/$fileName");

    OpenFile.open('$path/$fileName');
  } catch (e) {
    print("Erro ao salvar CSV: $e");
  }
}
