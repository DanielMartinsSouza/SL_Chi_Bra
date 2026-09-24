import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/navigation_route.dart';
import 'navigation_provider.dart';

class OsrmNavigationProvider implements NavigationProvider {
  final http.Client _client;

  OsrmNavigationProvider({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<NavigationRoute> getRoute(LatLng origin, LatLng destination) async {
    final uri = Uri.https(
        'router.project-osrm.org',
        '/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}',
        {'overview': 'full', 'geometries': 'geojson', 'steps': 'true'});
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('OSRM respondeu com HTTP ${response.statusCode}.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['code'] != 'Ok') throw FormatException('OSRM: ${data['code']}');
    final route = (data['routes'] as List).first as Map<String, dynamic>;
    final coordinates = (route['geometry']['coordinates'] as List)
        .map((point) => _latLng(point as List))
        .toList();
    final steps = <NavigationStep>[];
    for (final leg in route['legs'] as List) {
      for (final rawStep in (leg as Map<String, dynamic>)['steps'] as List) {
        final step = rawStep as Map<String, dynamic>;
        final maneuver = step['maneuver'] as Map<String, dynamic>;
        final type = _maneuver(
            maneuver['type'] as String, maneuver['modifier'] as String?);
        steps.add(NavigationStep(
          maneuver: type,
          instruction: instructionForManeuver(type),
          location: _latLng(maneuver['location'] as List),
          distanceMeters: (step['distance'] as num).toDouble(),
        ));
      }
    }
    if (coordinates.isEmpty || steps.isEmpty) {
      throw const FormatException('OSRM retornou uma rota vazia.');
    }
    return NavigationRoute(geometry: coordinates, steps: steps);
  }

  LatLng _latLng(List coordinates) => LatLng(
      (coordinates[1] as num).toDouble(), (coordinates[0] as num).toDouble());

  Maneuver _maneuver(String type, String? modifier) {
    if (type == 'arrive') return Maneuver.arrive;
    if (type == 'roundabout' || type == 'rotary') return Maneuver.roundabout;
    if (type == 'depart' || type == 'continue') return Maneuver.straight;
    if (type == 'turn' ||
        type == 'end of road' ||
        type == 'fork' ||
        type == 'on ramp') {
      return switch (modifier) {
        'left' => Maneuver.turnLeft,
        'right' => Maneuver.turnRight,
        'slight left' => Maneuver.slightLeft,
        'slight right' => Maneuver.slightRight,
        'uturn' => Maneuver.uTurn,
        'straight' => Maneuver.straight,
        _ => Maneuver.other,
      };
    }
    return Maneuver.other;
  }
}
