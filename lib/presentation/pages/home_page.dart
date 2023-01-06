import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../../widgets/filter_selector.dart';
import 'display_picture.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isRecording = false;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final _filters = [
    Colors.transparent,
    Colors.red,
    Colors.green,
    Colors.blue,
  ];
  final _filterColor = ValueNotifier<Color>(Colors.transparent);
  void _onFilterChanged(Color value) {
    _filterColor.value = value;
  }

  _recordVideo() async {
    if (_isRecording) {
      await _controller.stopVideoRecording();
      setState(() => _isRecording = false);
    } else {
      await _controller.prepareForVideoRecording();
      await _controller.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.ultraHigh,
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
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  child: ValueListenableBuilder(
                    valueListenable: _filterColor,
                    builder: (context, color, child) {
                      return ColorFiltered(
                        colorFilter: ColorFilter.mode(color, BlendMode.color),
                        child: CameraPreview(
                          _controller,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 50,
                  child: buildFilterSelector(),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () async {
              try {
                await _initializeControllerFuture;

                final image = await _controller.takePicture();

                if (!mounted) return;

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      imagePath: image.path,
                      color: _filterColor.value,
                    ),
                  ),
                );
              } catch (e) {
                if (kDebugMode) {
                  print(e);
                }
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
          FloatingActionButton(
            heroTag: 'video',
            backgroundColor: Colors.red,
            child: Icon(_isRecording ? Icons.stop : Icons.circle),
            onPressed: () => _recordVideo(),
          ),
        ],
      ),
    );
  }

  Widget buildFilterSelector() {
    return FilterSelector(
      onFilterChanged: _onFilterChanged,
      filters: _filters,
    );
  }
}
