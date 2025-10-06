import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  Stream<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _checkServiceAndPermission();
  }

  Future<void> _checkServiceAndPermission() async {
    // Kiểm tra dịch vụ GPS có bật không
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dịch vụ GPS đang tắt")),
      );
      return;
    }

    // Xin quyền
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không có quyền truy cập vị trí")),
      );
      return;
    }

    // Lấy last known location
    Position? lastPos = await Geolocator.getLastKnownPosition();
    if (lastPos != null) {
      setState(() {
        _currentLatLng = LatLng(lastPos.latitude, lastPos.longitude);
      });
    }

    // Lấy vị trí hiện tại
    _getCurrentLocation();

    // Lắng nghe liên tục
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10, // update khi di chuyển ≥ 10m
      ),
    );

    _positionStream!.listen((Position pos) {
      setState(() {
        _currentLatLng = LatLng(pos.latitude, pos.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentLatLng!),
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLatLng!, 16),
    );
  }

  // Tính khoảng cách và góc
  void _calculateDemo() {
    if (_currentLatLng == null) return;

    // Ví dụ: điểm đến là khu E hutech
    double lat2 = 10.855043;
    double lon2 = 106.785373;

    double distance = Geolocator.distanceBetween(
      _currentLatLng!.latitude,
      _currentLatLng!.longitude,
      lat2,
      lon2,
    );

    double bearing = Geolocator.bearingBetween(
      _currentLatLng!.latitude,
      _currentLatLng!.longitude,
      lat2,
      lon2,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Cách Khu E: ${distance.toStringAsFixed(0)}m, Hướng: ${bearing.toStringAsFixed(1)}°")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vị trí của tôi")),
      body: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng!,
                zoom: 16,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId("me"),
                  position: _currentLatLng!,
                  infoWindow: const InfoWindow(title: "Vị trí hiện tại"),
                )
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculateDemo,
        icon: const Icon(Icons.straighten),
        label: const Text("Tính khoảng cách"),
      ),
    );
  }
}
