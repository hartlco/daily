// Downloading Images with NetworkImage
// https://www.raywenderlich.com/116-getting-started-with-flutter

import 'dart:convert' as JSON;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart';

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
  var selectedDate = DateTime.now();
  var base64Image = "";
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
                  child: Text(selectedDate.toString()),
                  onPressed: _showDatePicker,
                ),
                RaisedButton(
                  child: const Text("Image"),
                  onPressed: _getImage,
                ),
                RaisedButton(
                  child: const Text("Send"),
                  onPressed: _sendData,
                ),
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

    print(selectedDate.toUtc().toIso8601String());

    var dictionary = {
      "content": contentController.text,
      "location": locationController.text,
      // Horrible hack to get timezone into the string quickly
      "creation_date_string": "${selectedDate.toIso8601String()}-01:00",
      "base_64_image": base64Image
    };
    var json = JSON.jsonEncode(dictionary);

    var response = await http.post(postURL,
        body: json, headers: {"Content-Type": "application/json"});
    print(response.body);
  }

  _showDatePicker() {
    Future<DateTime> date = showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );

    date.then((newDate) {
      setState(() {
        selectedDate = newDate;
      });
    });
  }

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      var originalImage = decodeImage(image.readAsBytesSync());
      var resizedImage = copyResize(originalImage, 1200);
      base64Image = JSON.base64Encode(encodeJpg(resizedImage, quality: 85));
    });
  }
}
