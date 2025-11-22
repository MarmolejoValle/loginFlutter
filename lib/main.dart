import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
void main() {
  runApp(const MyApp());
}
/// Raíz de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SimpleMapPage(),
    );
  }
}
/// Pantalla principal con el mapa
class SimpleMapPage extends StatefulWidget {
  const SimpleMapPage({super.key});
  @override
  State<SimpleMapPage> createState() => _SimpleMapPageState();
}
class _SimpleMapPageState extends State<SimpleMapPage> {
  // Controlador del mapa (para mover la cámara, etc.)
  GoogleMapController? _mapController;
  // Posición inicial de la cámara (ejemplo: UAEM Cuernavaca)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(18.9822, -99.2345),
    zoom: 14,
  );
  // Conjunto de marcadores a mostrar
  final Set<Marker> _markers = {};
  // Ubicación actual del usuario (cuando la tengamos)
  LatLng? _myLocation;
  @override
  void initState() {
    super.initState();
    _determinePosition(); // Al iniciar, pedimos permisos y ubicamos al usuario
  }
  /// 1) Verifica servicios de ubicación
  /// 2) Pide permisos si es necesario
  /// 3) Obtiene la posición actual
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // 1. ¿Servicios de ubicación activos?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // En una app real, muestra un diálogo pidiendo que lo active
      debugPrint('Servicios de ubicación desactivados');
      return;
    }
    // 2. Verifica permiso
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Pide permiso
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Permiso de ubicación denegado');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permiso negado permanentemente
      debugPrint(
          'Permiso de ubicación denegado permanentemente. Ve a ajustes del sistema.');
      return;
    }
    // 3. Si llegamos aquí, tenemos permisos -> obtenemos la posición
    final position = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _myLocation = userLatLng;
      // Marcador para la ubicación del usuario
      _markers.add(
        Marker(
          markerId: const MarkerId('my_location'),
          position: userLatLng,
          infoWindow: const InfoWindow(title: 'Estoy aquí'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });
    // Si el mapa ya está creado, movemos la cámara
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 16),
        ),
      );
    }
  }
  /// Mueve la cámara a la ubicación actual, si ya la tenemos
  Future<void> _goToMyLocation() async {
    if (_myLocation == null || _mapController == null) return;
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _myLocation!, zoom: 16),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Google Maps + Ubicación'),
      ),
      body: GoogleMap(
        // Posición inicial (antes de conocer la ubicación real)
        initialCameraPosition: _initialCameraPosition,
        // Se llama cuando el mapa está listo
        onMapCreated: (controller) {
          _mapController = controller;
        },
        // Muestra el botón azul de "mi ubicación"
        myLocationButtonEnabled: true,
        // Muestra el puntito azul cuando se tiene la ubicación
        myLocationEnabled: true,
        // Marcadores a dibujar en el mapa
        markers: _markers,
        // Cuando el usuario toca el mapa, agregamos un marcador
        onTap: (LatLng position) {
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId('marker_${_markers.length}'),
                position: position,
                infoWindow: InfoWindow(
                  title: 'Marcador ${_markers.length}',
                  snippet:
                      'Lat: ${position.latitude}, Lng: ${position.longitude}',
                ),
              ),
            );
          });
        },
      ),
      // Botón flotante para centrar la cámara en mi ubicación
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
