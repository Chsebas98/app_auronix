// map_widget.dart

import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapWidget extends StatefulWidget {
  final double? destinationLat;
  final double? destinationLng;
  final List<LatLng> polylinePoints;
  final Function(LatLng)? onLocationReady;

  const MapWidget({
    super.key,
    this.destinationLat,
    this.destinationLng,
    this.polylinePoints = const [],
    this.onLocationReady,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.destinationLat != widget.destinationLat ||
        oldWidget.destinationLng != widget.destinationLng) {
      _updateMarkers();
    }

    if (oldWidget.polylinePoints.length != widget.polylinePoints.length) {
      _updatePolylines();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoadingLocation = true);

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('❌ Permiso de ubicación denegado');
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      debugPrint(
        '📍 Ubicación actual: ${position.latitude}, ${position.longitude}',
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );

      _updateMarkers();

      // ✅ Notificar que la ubicación está lista
      if (widget.onLocationReady != null) {
        widget.onLocationReady!(LatLng(position.latitude, position.longitude));
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo ubicación: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  void _updateMarkers() {
    _markers.clear();

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('origin'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          ),
          infoWindow: InfoWindow(title: 'Tu ubicación', snippet: 'Origen'),
        ),
      );
    }

    if (widget.destinationLat != null && widget.destinationLng != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: LatLng(widget.destinationLat!, widget.destinationLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Destino', snippet: 'A donde vas'),
        ),
      );

      if (_currentPosition != null) {
        _fitBounds();
      }
    }

    setState(() {});
  }

  void _updatePolylines() {
    _polylines.clear();

    if (widget.polylinePoints.isNotEmpty) {
      debugPrint(
        '🗺️ Agregando polyline con ${widget.polylinePoints.length} puntos',
      );

      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: widget.polylinePoints,
          color: Color(0xFFFDB827), // Amarillo Auronix
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          geodesic: true,
        ),
      );

      if (_mapController != null) {
        _fitBounds();
      }
    }

    setState(() {});
  }

  void _fitBounds() {
    if (_currentPosition == null ||
        widget.destinationLat == null ||
        widget.destinationLng == null) {
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        _currentPosition!.latitude < widget.destinationLat!
            ? _currentPosition!.latitude
            : widget.destinationLat!,
        _currentPosition!.longitude < widget.destinationLng!
            ? _currentPosition!.longitude
            : widget.destinationLng!,
      ),
      northeast: LatLng(
        _currentPosition!.latitude > widget.destinationLat!
            ? _currentPosition!.latitude
            : widget.destinationLat!,
        _currentPosition!.longitude > widget.destinationLng!
            ? _currentPosition!.longitude
            : widget.destinationLng!,
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return Container(
        color: AppColors.gray200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(AppColors.third),
              ),
              16.verticalSpace,
              Text(
                'Obteniendo tu ubicación...',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return Container(
        color: AppColors.gray200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 60.r, color: AppColors.tenth),
              16.verticalSpace,
              Text(
                'No se pudo obtener tu ubicación',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.verticalSpace,
              TextButton(
                onPressed: _getCurrentLocation,
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 15,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _updateMarkers();
        _updatePolylines();
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      mapType: MapType.normal,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
