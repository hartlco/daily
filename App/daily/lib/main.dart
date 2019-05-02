// Downloading Images with NetworkImage
// https://www.raywenderlich.com/116-getting-started-with-flutter

import 'dart:convert' as JSON;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'strings.dart';
import 'package:image_picker/image_picker.dart' as ImagePicker;
import 'package:flutter_native_image/flutter_native_image.dart';

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
  var selectedImage;
  var isLoading = false;
  var error = false;
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
                selectedImage != null ? Image.file(selectedImage) : Center(child: Text("No Image selected")),
                isLoading ? 
                  Center(
                    child: CircularProgressIndicator(),
                  ) :
                  RaisedButton(
                    child: const Text("Send"),
                    onPressed: _sendData,
                  ),
                error ? Center(child: Text("Error")) : Center(child: Text("All good"))
              ],
            ),
            padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom)),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _newEntry, child: Icon(Icons.add),),
      resizeToAvoidBottomInset: false,
    );
  }

  _sendData() async {
    setState((){
      isLoading = true;
    });

    var postURL = Uri.http("192.168.10.26:9123", "/");

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
    
    setState((){
      error = response.statusCode != 200;
      isLoading = false;
    });
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
    var image = await ImagePicker.ImagePicker.pickImage(source: ImagePicker.ImageSource.gallery);
    ImageProperties properties = await FlutterNativeImage.getImageProperties(image.path);
    var compressedFile = await FlutterNativeImage.compressImage(image.path, quality: 80, 
    targetWidth: 1200, targetHeight: (properties.height * 1200 / properties.width).round());

    setState(() {
      selectedImage = image;
      base64Image = JSON.base64Encode(compressedFile.readAsBytesSync());
    });
  }

  _newEntry() {
    setState(() {
      selectedDate = DateTime.now();
      base64Image = "";
      selectedImage = null;
      isLoading = false;
      error = false;
    });
  }
}
