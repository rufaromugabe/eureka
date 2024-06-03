import 'dart:async';

import 'package:camera/camera.dart';
import 'package:eureka/assessmentscreen.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CameraPreview(_controller),
                ElevatedButton(
                    onPressed: () async {
                      try {
                        await _initializeControllerFuture;

                        image = await _controller.takePicture();
                        final bytes = await image!.readAsBytes();

                        if (image != null) {
                          setState(() {
                            imageFIle = Image.memory(bytes);
                          });

                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, imageFIle);
                        }
                      } catch (e) {
                        //to be done
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 40,
                    ))
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
