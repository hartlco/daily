// Downloading Images with NetworkImage
// https://www.raywenderlich.com/116-getting-started-with-flutter

import 'dart:convert' as JSON;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'strings.dart';
import 'member.dart';

void main() => runApp(DailyApp());

class DailyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      home: GHFlutter(),
    );
  }
}

class GHFlutter extends StatefulWidget {
  @override
  createState() => GHFlutterState();
}

class GHFlutterState extends State<GHFlutter> {
  var _members = <Member>[];
  final contentController = TextEditingController();
  final locationController = TextEditingController();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Strings.appTitle),
      ),
      body: SafeArea(
        child: Padding(
            child: ListView(
              children: <Widget>[
                TextField(
                  maxLines: 1,
                  decoration: InputDecoration(hintText: "Location"),
                  controller: locationController,
                ),
                TextField(
                  keyboardType: TextInputType.multiline,
                  controller: contentController,
                  maxLines: null,
                  decoration: InputDecoration(hintText: "Content"),
                ),
                RaisedButton(
                  child: const Text("Send"),
                  onPressed: _sendData,
                )
              ],
            ),
            padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom)),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  _sendData() async {
    var postURL = Uri.http("localhost:8000", "/");

    var dictionary = {
      "content": contentController.text,
      "location": locationController.text
    };
    var json = JSON.jsonEncode(dictionary);

    var response = await http.post(postURL,
        body: json, headers: {"Content-Type": "application/json"});
    print(response.body);
  }
}
