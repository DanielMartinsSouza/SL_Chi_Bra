import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/navigation_route.dart';
import '../../services/fake_navigation_provider.dart';

class RouteMap extends StatelessWidget {
  final NavigationRoute? route;
  final NavigationStep? currentStep;

  const RouteMap({super.key, required this.route, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: FakeNavigationProvider.origin,
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.china_brasil_sl',
          ),
          if (route != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: route!.geometry,
                  strokeWidth: 5,
                  color: Colors.blueAccent,
                ),
              ],
            ),
          if (currentStep != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: currentStep!.location,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 36),
                ),
              ],
            ),
          SimpleAttributionWidget(
            source: const Text('OpenStreetMap contributors'),
            onTap: () =>
                launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
          ),
        ],
      ),
    );
  }
}
