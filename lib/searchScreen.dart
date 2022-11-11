import 'package:flutter/material.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapboxtrial/mapBoxMap.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _sourceTextController = TextEditingController();
  final _destinationTextController = TextEditingController();

  late LatLng sourceLocation;
  late LatLng destinationLocation;
  final accessToken =
      "pk.eyJ1IjoiY2FzYW50c29sdXRpb25zIiwiYSI6ImNsNWlnYmRrNTA1czUzZ251a3J6dGd2aHUifQ.VIkHIczOv-4H_Sz2YWpMPA";

  LatLng getLatLng(coordinate) {
    var latitude = coordinate[0];
    var longitude = coordinate[1];
    return LatLng(latitude, longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Location Search",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(
                hintText: "Enter your Location",
                textController: _sourceTextController,
                enabled: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapBoxAutoCompleteWidget(
                        apiKey: accessToken,
                        hint: "Select location",
                        onSelect: (place) {
                          print(
                              'This is the coordinates of the place ${place.center}');
                          _sourceTextController.text = place.placeName!;
                          sourceLocation = getLatLng(place.center!);
                        },
                        limit: 10,
                        country: "GH",
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(
                hintText: "Enter your Destination",
                textController: _destinationTextController,
                enabled: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapBoxAutoCompleteWidget(
                        apiKey: accessToken,
                        hint: "Select location",
                        onSelect: (place) {
                          print(
                              'This is the coordinates of the place ${place.center}');
                          _destinationTextController.text = place.placeName!;
                          destinationLocation = getLatLng(place.center!);

                          print(
                              "This is the source location ${sourceLocation} and the destination location ${destinationLocation}");
                        },
                        limit: 10,
                        country: "GH",
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 20, 8.0, 8.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyMap(
                        source: sourceLocation,
                        destination: destinationLocation,
                      ),
                    ),
                  );
                },
                child: const Text("Navigate"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
