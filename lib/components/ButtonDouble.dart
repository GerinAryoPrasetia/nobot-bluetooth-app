import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ButtonDoubleComponent extends StatefulWidget {
  final String? buttonName;
  final String? comandOn;
  final String? comandOff;
  final String? command;
  final BluetoothConnection? connection;
  final int clientID;
  const ButtonDoubleComponent(
      {Key? key,
      this.buttonName,
      this.comandOn,
      this.comandOff,
      this.connection,
      this.command,
      required this.clientID})
      : super(key: key);
  _ButtonState createState() => _ButtonState();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ButtonState extends State<ButtonDoubleComponent> {
  bool buttonClicado = false;
  final TextEditingController textEditingController = TextEditingController();
  List<_Message> messages = <_Message>[];

  _changeButtonColor() {
    setState(() {
      buttonClicado = !buttonClicado;
    });
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _sendMessage(widget.command);
        _changeButtonColor();
      },
      onTapUp: (TapUpDetails details) {
        _sendMessage("Lepas");
        _changeButtonColor();
      },
      child: (SizedBox(
        height: 60,
        width: 90,
        child: TextButton(
          onPressed: null,
          child: Text(
            widget.buttonName!,
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.all(16.0),
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
      )),
    );
  }

  _sendMessage(text) async {
    text = text.trim();
    textEditingController.clear();
    print(text);
    if (text.length > 0) {
      try {
        widget.connection!.output
            .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await widget.connection!.output.allSent;

        setState(() {
          messages.add(_Message(widget.clientID, text));
        });
      } catch (e) {
        setState(() {});
      }
    }
  }

  _sendMessageInt(int number) async {
    final buffer = Uint8List.fromList([number]);
    if (widget.connection != null) {
      try {
        widget.connection!.output.add(buffer);
        await widget.connection!.output.allSent;
        setState(() {
          messages.add(_Message(widget.clientID, number.toString()));
        });
      } catch (e) {
        setState(() {});
      }
    }
  }
}
