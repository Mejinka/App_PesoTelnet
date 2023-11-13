// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TelnetClient {
  bool get isConnected => _isConnected;

  late Socket _socket;
  String _host;
  int _port;
  bool _isConnected = false;
  late StreamSubscription _socketSubscription;
  final _pendingCommands = <Completer<String>>[];

  TelnetClient([String? host, int? port])
      : _host = host ?? "",
        _port = port ?? 0;

  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    print("Saving configurations:");
    print("Host: $_host");
    print("Port: $_port");
    prefs.setString('telnet_host', _host);
    prefs.setInt('telnet_port', _port);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('telnet_host') ?? _host;
    _port = prefs.getInt('telnet_port') ?? _port;

    print("Loaded configurations:");
    print("Host: $_host");
    print("Port: $_port");
  }

  Map<String, dynamic> getConfig() {
    return {
      'host': _host,
      'port': _port,
    };
  }

  void setConfig(String newHost, int newPort) {
    _host = newHost;
    _port = newPort;
    if (_isConnected) {
      close();
      Future.delayed(const Duration(seconds: 2), () {
        connect();
      });
    }
  }

  Future<void> connect() async {
    int retryCount = 0;
    while (!_isConnected && retryCount < 5) {
      print("Trying to connect...");
      try {
        _socket = await Socket.connect(_host, _port);
        _isConnected = true;

        _socketSubscription = _socket.listen(
          (List<int> data) {
            var response = utf8.decode(data);
            if (_pendingCommands.isNotEmpty) {
              var completer = _pendingCommands.removeAt(0);
              completer.complete(response);
            }
          },
          onDone: () {
            _isConnected = false;
          },
          onError: (error) {
            if (_pendingCommands.isNotEmpty) {
              var completer = _pendingCommands.removeAt(0);
              completer.completeError(error);
            }
          },
        );
      } catch (e) {
        print("Error while connecting: $e");
        retryCount++;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<String> sendCommand(String command) async {
    if (!_isConnected) {
      throw Exception("You need to connect first.");
    }

    final completer = Completer<String>();
    _pendingCommands.add(completer);

    _socket.write('$command\r');

    return completer.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        if (!completer.isCompleted) {
          _pendingCommands.remove(completer);
          completer.completeError(
              TimeoutException('No response received for command: $command'));
        }

        return 'Command timed out';
      },
    );
  }

  void updateHost(String newHost) {
    _host = newHost;
  }

  void updatePort(int newPort) {
    _port = newPort;
  }

  void close() {
    _socket.close();
    _socketSubscription.cancel();
    _isConnected = false;
    print("Connection closed.");
  }

  void reset() {
    _isConnected = false;
    _socketSubscription.cancel();
    _pendingCommands.clear();
  }
}

void main() async {
  var telnet = TelnetClient();

  print(telnet.getConfig());

  await telnet.connect();
  var responsePeso = await telnet.sendCommand("XN");
  print("Peso response: $responsePeso");

  var responseZero = await telnet.sendCommand("AZ");
  print("Zero response: $responseZero");

  var responseTara = await telnet.sendCommand("XT");
  print("Tara response: $responseTara");

  telnet.setConfig("192.168.2.71", 6002);
  await telnet.saveConfig();
  telnet.close();
}
