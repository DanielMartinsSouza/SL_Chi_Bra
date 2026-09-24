import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:china_brasil_sl/controllers/navigation_controller.dart';
import 'package:china_brasil_sl/models/navigation_route.dart';
import 'package:china_brasil_sl/services/fake_navigation_provider.dart';
import 'package:china_brasil_sl/services/osrm_navigation_provider.dart';

void main() {
  test('Próximo não avança duas vezes enquanto uma instrução está pendente',
      () async {
    final spoken = <String>[];
    final pending = Completer<void>();
    final controller = NavigationController(
      provider: FakeNavigationProvider(),
      playInstruction: (instruction) async {
        spoken.add(instruction);
        if (instruction == 'Vire para a direita') await pending.future;
      },
    );
    await controller.load(
        FakeNavigationProvider.origin, FakeNavigationProvider.destination);
    await controller.playCurrent();
    final next = controller.next();
    await controller.next();
    expect(controller.currentIndex, 1);
    expect(spoken, ['Siga em frente', 'Vire para a direita']);
    pending.complete();
    await next;
    await controller.next();
    expect(controller.currentStep!.maneuver, Maneuver.turnLeft);
    controller.dispose();
  });

  test(
      'OSRM converte coordenadas e manobras estruturadas para instruções pt-BR',
      () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters['steps'], 'true');
      expect(request.url.queryParameters['geometries'], 'geojson');
      return http.Response('''{
        "code": "Ok", "routes": [{
          "geometry": {"coordinates": [[-47.8666,-15.7989],[-47.8647,-15.7989]]},
          "legs": [{"steps": [
            {"distance": 40, "maneuver": {"type": "depart", "location": [-47.8666,-15.7989]}},
            {"distance": 100, "maneuver": {"type": "turn", "modifier": "right", "location": [-47.8647,-15.7989]}},
            {"distance": 0, "maneuver": {"type": "arrive", "location": [-47.8647,-15.7989]}}
          ]}]
        }]
      }''', 200);
    });
    final route = await OsrmNavigationProvider(client: client).getRoute(
        FakeNavigationProvider.origin, FakeNavigationProvider.destination);
    expect(route.geometry.first.latitude, closeTo(-15.7989, 0.00001));
    expect(route.steps.map((s) => s.instruction), [
      'Siga em frente',
      'Vire para a direita',
      'Você chegou ao destino',
    ]);
    expect(route.steps[1].maneuver, Maneuver.turnRight);
  });
}
