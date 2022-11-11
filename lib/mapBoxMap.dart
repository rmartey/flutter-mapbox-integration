import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;

class MyMap extends StatefulWidget {
  final LatLng? source;
  final LatLng? destination;

  const MyMap({
    super.key,
    this.source,
    this.destination,
  });

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late MapboxMapController controller;
  CameraPosition? cameraPosition;

  final String accessToken =
      "pk.eyJ1IjoiY2FzYW50c29sdXRpb25zIiwiYSI6ImNsNWlnYmRrNTA1czUzZ251a3J6dGd2aHUifQ.VIkHIczOv-4H_Sz2YWpMPA";

  @override
  initState() {
    // super.initState();
    navigateToPosition();
  }

  // checking location permisions and getting current location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("The location service is disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permision is denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permission is denied forever, can't request for permission");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
// end of location service

// load marker image
  Future<Uint8List> _loadMarkerImage() async {
    var byteData = await rootBundle.load("assets/marker.png");
    return byteData.buffer.asUint8List();
  }

  _onMapCreate(MapboxMapController controller) async {
    this.controller = controller;
    var markerImage = await _loadMarkerImage();

    Position location = await _determinePosition();

    controller.addImage("marker", markerImage);

    await controller.addSymbol(
      SymbolOptions(
        iconSize: 0.2,
        iconImage: "marker",
        geometry: LatLng(widget.source!.latitude, widget.source!.longitude),
      ),
    );

    await controller.addSymbol(
      SymbolOptions(
        iconSize: 0.2,
        iconImage: "marker",
        geometry: LatLng(
            (widget.destination!.latitude), (widget.destination!.longitude)),
      ),
    );
  }

  void navigateToPosition() async {
    // Position location = await _determinePosition();

    setState(() {
      cameraPosition = CameraPosition(
          target: LatLng(widget.source!.latitude, widget.source!.longitude),
          zoom: 16);
    });

    // print("this code runs ");

    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));
  }

// get the rout data
  Future getCyclingRoutes(LatLng source, LatLng destination) async {
    String baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';
    String navType = 'cycling';
    String url =
        '$baseUrl/$navType/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?alternatives=true&continue_straight=true&geometries=geojson&language=en&overview=full&steps=true&access_token=$accessToken';

    try {
      final responseData =
          await http.get(Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

      print("this is the response: ${responseData.body}");

      return responseData.body;
    } catch (err) {
      print(err);
    }
  }
  // end

  // get the directions data
  Future<Map> getDirections(
      LatLng sourceLocation, LatLng destinationLocation) async {
    final response =
        await getCyclingRoutes(sourceLocation, destinationLocation);

    // print('This is the response from the http request: ${(response)}');

    Map responseJson = json.decode(response);

    Map geometry = responseJson['routes'][0]['geometry'];
    num duration = responseJson['routes'][0]['duration'];
    num distance = responseJson['routes'][0]['distance'];

    Map modifiedResponse = {
      "geometry": geometry,
      "duration": duration,
      "distance": distance
    };

    // print('This is the modified data ${modifiedResponse}');

    return modifiedResponse;
    // return {};
  }
  // end

  // adding the polyline
  _addPolyline() async {
    // Position location = await _determinePosition();

    final responseData = await getDirections(
        LatLng(widget.source!.latitude, widget.source!.longitude),
        LatLng((widget.destination!.latitude), widget.destination!.longitude));

    final _fills = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": 0,
          "properties": <String, dynamic>{},
          "geometry": responseData['geometry']
        }
      ]
    };

    // print(
    //     "this is the geometry from the response data ${responseData['geomtry']}");

    await controller.addSource("fills", GeojsonSourceProperties(data: _fills));
    await controller.addLineLayer(
        'fills',
        "lines",
        LineLayerProperties(
          lineColor: Colors.green.toHexStringRGB(),
          lineCap: "round",
          lineJoin: "round",
          lineWidth: 5,
        ));
  }

  _onStyleLoaded() {
    _addPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Directions"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        child: (cameraPosition != null)
            ? MapboxMap(
                accessToken: accessToken,
                initialCameraPosition: cameraPosition!,
                zoomGesturesEnabled: true,
                onMapCreated: _onMapCreate,
                doubleClickZoomEnabled: true,
                myLocationEnabled: true,
                trackCameraPosition: true,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingCompass,
                onStyleLoadedCallback: _onStyleLoaded,
              )
            : Container(),
      ),
    );
  }
}
