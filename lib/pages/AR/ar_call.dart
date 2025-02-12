

import 'package:flutter/material.dart';
import 'package:ar_location_view/ar_location_view.dart';
import '../../models/annotation.dart';
import '../../widgets/annotation_view.dart';
import '../../utils/fake_annotation_generator.dart';
import 'package:geolocator/geolocator.dart';


// ignore: camel_case_types
class Ar_call extends StatefulWidget {
  const Ar_call({super.key});

  @override
  State<Ar_call> createState() => _MyAppState();
}

class _MyAppState extends State<Ar_call> {
  List<Annotation> annotations = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ArLocationWidget(
          annotations: annotations,
          showDebugInfoSensor: false,
          annotationWidth: 180,
          annotationHeight: 60,
          radarPosition: RadarPosition.bottomCenter,
          annotationViewBuilder: (context, annotation) {
            return AnnotationView(
              key: ValueKey(annotation.uid),
              annotation: annotation as Annotation,
            );
          },
          radarWidth: 160,
          scaleWithDistance: false,
          onLocationChange: (Position position) {
            Future.delayed(const Duration(seconds: 5), () {
              setState(() {
                annotations = fakeAnnotation(position: position, numberMaxPoi: 10);
              });
            });
          },
        ),
      ),
    );
  }
}
