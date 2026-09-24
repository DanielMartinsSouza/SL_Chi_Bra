import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/navigation_route.dart';
import '../services/navigation_provider.dart';

class NavigationController extends ChangeNotifier {
  NavigationProvider provider;
  final Future<void> Function(String instruction) playInstruction;
  NavigationRoute? route;
  int currentIndex = 0;
  bool isLoading = false;
  bool isAdvancing = false;
  String? error;

  NavigationController({required this.provider, required this.playInstruction});

  NavigationStep? get currentStep =>
      route == null || route!.steps.isEmpty ? null : route!.steps[currentIndex];

  bool get hasNext => route != null && currentIndex + 1 < route!.steps.length;

  Future<void> load(LatLng origin, LatLng destination) async {
    if (isLoading || isAdvancing) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final loaded = await provider.getRoute(origin, destination);
      if (loaded.steps.isEmpty) {
        throw const FormatException('Rota sem instruções.');
      }
      route = loaded;
      currentIndex = 0;
    } catch (e) {
      error = 'Não foi possível carregar a rota: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> useProvider(
      NavigationProvider newProvider, LatLng origin, LatLng destination) async {
    if (isLoading || isAdvancing) return;
    final previous = provider;
    provider = newProvider;
    await load(origin, destination);
    if (error != null) provider = previous;
  }

  Future<void> playCurrent() async {
    if (currentStep == null || isAdvancing) return;
    isAdvancing = true;
    notifyListeners();
    try {
      await playInstruction(currentStep!.instruction);
    } finally {
      isAdvancing = false;
      notifyListeners();
    }
  }

  Future<void> next() async {
    if (!hasNext || isAdvancing) return;
    currentIndex++;
    notifyListeners();
    await playCurrent();
  }
}
