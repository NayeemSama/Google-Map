import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  Position? current_position = null;
  final List<Marker> _markers = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      current_position = await _determinePosition();
    });
    print('object');
    print(current_position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: GestureDetector(
              onDoubleTap: () async {
                var ob = await _determinePosition();
                print(ob);
              },
              child: const Text('Google Map'))),
      body: GoogleMap(
        markers: Set<Marker>.of(_markers),
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        onTap: _handleTap,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.radio_button_checked),
        onPressed: () async {
          current_position = await _determinePosition();
          LatLng userPosition =
              LatLng(current_position!.latitude, current_position!.longitude);
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: userPosition, zoom: 20),
            ),
          );

          _markers.add(
              Marker(
                  markerId: MarkerId('SomeId'),
                  position: LatLng(current_position!.latitude, current_position!.longitude),
                  infoWindow: InfoWindow(
                      title: 'Marker'
                  )
              )
          );
          setState(() {});
        },
      ),
    );
  }

  _handleTap(LatLng point) {
    String lat = point.latitude.toString();
    String long = point.longitude.toString();
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: '$lat, $long',
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ));
    });
  }

  Future<Position> _determinePosition() async {
    print('runned');
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
