import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ));

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String string = "TextRecognition";
  File _userImageFile;
  List<ImageLabel> _imageLabels = [];
  List<Barcode> _barCode = [];
  var result = "";

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  //image_label_recognition
  processImageLabels() async {
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(_userImageFile);
    ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    _imageLabels = await labeler.processImage(myImage);
    result = "";
    for (ImageLabel imageLabel in _imageLabels) {
      setState(() {
        result = result +
            imageLabel.text +
            ":" +
            imageLabel.confidence.toString() +
            "\n";
      });
    }
  }

//recognise_Text
  recogniseText() async {
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(_userImageFile);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(myImage);
    result = "";
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        setState(() {
          result = result + ' ' + line.text + '\n';
        });
      }
    }
  }

//barCode_Scanner
  barCodeScanner() async {
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(_userImageFile);
    BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    _barCode = await barcodeDetector.detectInImage(myImage);
    result = "";
    for (Barcode barcode in _barCode) {
      setState(() {
        result = barcode.displayValue;
      });
    }
  }

//drawer_Item
  Widget drawerItem(String title, IconData iconData, String _string) {
    return InkWell(
      onTap: () {
        setState(() {
          string = _string;
        });
        Navigator.of(context).pop();
      },
      child: Column(
        children: [
          ListTile(
            leading: Icon(iconData),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Image.network(
                    "https://1.bp.blogspot.com/-B3K1G5D9sPQ/WvDZJGvkqVI/AAAAAAAAFSc/zx6VYIc0IXQmB8oR4c0i7SKjSNL-2xiTQCLcBGAs/s1600/ml-kit-logo.png"),
              ),
              Divider(),
              drawerItem("Text recognition", Icons.title, "TextRecognition"),
              drawerItem("Image labeling", Icons.terrain, "ImageLabeling"),
              drawerItem("Barcode scanning", Icons.workspaces_outline,
                  "BarcodeScanning"),
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          title: Text(string),
          backgroundColor: Colors.blue[300],
          actions: [
            IconButton(
              onPressed: () {
                if (string == "TextRecognition") recogniseText();
                if (string == "BarcodeScanning") barCodeScanner();
                if (string == "ImageLabeling") processImageLabels();
              },
              icon: Icon(Icons.check),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                UserImagePicker(_pickedImage),
                Padding(
                    padding: const EdgeInsets.all(16.0), child: Text(result)),
              ],
            ),
          ),
        ));
  }
}

class UserImagePicker extends StatefulWidget {
  UserImagePicker(
    this.imagePickFn,
  );

  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;
  ImagePicker picker = ImagePicker();

  void _pickImage(ImageSource imageSource) async {
    final pickedImageFile = await picker.getImage(
      source: imageSource,
    );

    setState(() {
      _pickedImage = File(pickedImageFile.path);
    });
    widget.imagePickFn(File(pickedImageFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.orangeAccent.withOpacity(0.3),
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: _pickedImage != null
                  ? Image(
                      image: FileImage(_pickedImage),
                    )
                  : Center(
                      child: Text("Please Add Image"),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        FlatButton.icon(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text(
                      "Complete your action using..",
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                        ),
                      ),
                    ],
                    content: Container(
                      height: 120,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.camera),
                            title: Text(
                              "Camera",
                            ),
                            onTap: () {
                              _pickImage(ImageSource.camera);
                              Navigator.of(context).pop();
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.black,
                          ),
                          ListTile(
                            leading: Icon(Icons.image),
                            title: Text(
                              "Gallery",
                            ),
                            onTap: () {
                              _pickImage(ImageSource.gallery);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
          icon: Icon(Icons.add),
          label: Text(
            'Add Image',
          ),
        )
      ],
    );
  }
}
