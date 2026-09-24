import 'package:latlong2/latlong.dart';
import '../models/navigation_route.dart';

abstract class NavigationProvider {
  Future<NavigationRoute> getRoute(LatLng origin, LatLng destination);
}
