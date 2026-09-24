import 'package:latlong2/latlong.dart';

enum Maneuver {
  straight,
  turnLeft,
  turnRight,
  slightLeft,
  slightRight,
  uTurn,
  roundabout,
  arrive,
  other,
}

String instructionForManeuver(Maneuver maneuver) => switch (maneuver) {
      Maneuver.straight => 'Siga em frente',
      Maneuver.turnLeft => 'Vire à esquerda',
      Maneuver.turnRight => 'Vire para a direita',
      Maneuver.slightLeft => 'Vire levemente à esquerda',
      Maneuver.slightRight => 'Vire levemente à direita',
      Maneuver.uTurn => 'Faça o retorno',
      Maneuver.roundabout => 'Entre na rotatória',
      Maneuver.arrive => 'Você chegou ao destino',
      Maneuver.other => 'Continue pela via indicada',
    };

class NavigationStep {
  final Maneuver maneuver;
  final String instruction;
  final LatLng location;
  final double? distanceMeters;

  const NavigationStep({
    required this.maneuver,
    required this.instruction,
    required this.location,
    this.distanceMeters,
  });
}

class NavigationRoute {
  final List<LatLng> geometry;
  final List<NavigationStep> steps;

  const NavigationRoute({required this.geometry, required this.steps});
}
