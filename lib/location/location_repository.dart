import 'dart:async';
import 'package:geolocator/geolocator.dart';

enum LocStatus { ok, serviceOff, denied, deniedForever }

class LocationRepository {
  /// Pide permisos + valida servicio de ubicación.
  /// Devuelve un estado para que la UI muestre mensajes útiles.
  Future<LocStatus> ensureReady() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return LocStatus.serviceOff;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission(); // ✅ popup aquí
    }

    if (perm == LocationPermission.denied) return LocStatus.denied;
    if (perm == LocationPermission.deniedForever)
      return LocStatus.deniedForever;

    return LocStatus.ok;
  }

  /// Stream principal (event-driven por el SO; ideal para “verde”).
  Stream<Position> watch({required bool debugFast}) {
    final settings = LocationSettings(
      // Para probar que “sí se mueve”: high + distanceFilter pequeño.
      // Para modo verde: low + distanceFilter 25/50.
      accuracy: debugFast ? LocationAccuracy.high : LocationAccuracy.low,
      distanceFilter: debugFast ? 1 : 25,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Fallback: polling suave si el stream no emite (algunos Xiaomi hacen cosas raras).
  Stream<Position> poll({required Duration every}) async* {
    while (true) {
      yield await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await Future.delayed(every);
    }
  }
}
