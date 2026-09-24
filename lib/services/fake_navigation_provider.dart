import 'package:latlong2/latlong.dart';
import '../models/navigation_route.dart';
import 'navigation_provider.dart';

class FakeNavigationProvider implements NavigationProvider {
  static const origin = LatLng(-15.7989, -47.8666);
  static const destination = LatLng(-15.8015, -47.8636);

  @override
  Future<NavigationRoute> getRoute(LatLng origin, LatLng destination) async {
    return NavigationRoute(
      geometry: [
        origin,
        const LatLng(-15.7989, -47.8647),
        const LatLng(-15.8000, -47.8647),
        const LatLng(-15.8000, -47.8636),
        destination,
      ],
      steps: [
        NavigationStep(
          maneuver: Maneuver.straight,
          instruction: instructionForManeuver(Maneuver.straight),
          location: origin,
        ),
        NavigationStep(
          maneuver: Maneuver.turnRight,
          instruction: instructionForManeuver(Maneuver.turnRight),
          location: const LatLng(-15.7989, -47.8647),
        ),
        NavigationStep(
          maneuver: Maneuver.turnLeft,
          instruction: instructionForManeuver(Maneuver.turnLeft),
          location: const LatLng(-15.8000, -47.8647),
        ),
        NavigationStep(
          maneuver: Maneuver.straight,
          instruction: instructionForManeuver(Maneuver.straight),
          location: const LatLng(-15.8000, -47.8636),
        ),
      ],
    );
  }
}
