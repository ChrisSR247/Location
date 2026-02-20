import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'location_repository.dart';

final locationRepoProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

class ProximityState {
  final bool ready;
  final String statusMsg;
  final double distanceMeters;
  final bool within50m;
  final Position? last;

  const ProximityState({
    required this.ready,
    required this.statusMsg,
    required this.distanceMeters,
    required this.within50m,
    required this.last,
  });

  static const initial = ProximityState(
    ready: false,
    statusMsg: "Iniciando…",
    distanceMeters: double.infinity,
    within50m: false,
    last: null,
  );
}

class ProximityController extends StateNotifier<ProximityState> {
  ProximityController(
    this.ref, {
    required this.poiLat,
    required this.poiLon,
    this.debugFast = true, // ✅ ponlo false cuando ya funcione
  }) : super(ProximityState.initial) {
    _init();
  }

  final Ref ref;
  final double poiLat;
  final double poiLon;
  final bool debugFast;

  StreamSubscription<Position>? _sub;
  Timer? _fallbackTimer;
  bool _gotFirstFix = false;

  Future<void> _init() async {
    final repo = ref.read(locationRepoProvider);

    final st = await repo.ensureReady();
    if (st == LocStatus.serviceOff) {
      state = const ProximityState(
        ready: false,
        statusMsg: "GPS apagado. Enciende Ubicación.",
        distanceMeters: double.infinity,
        within50m: false,
        last: null,
      );
      return;
    }
    if (st == LocStatus.denied) {
      state = const ProximityState(
        ready: false,
        statusMsg: "Permiso denegado. Dale Permitir.",
        distanceMeters: double.infinity,
        within50m: false,
        last: null,
      );
      return;
    }
    if (st == LocStatus.deniedForever) {
      state = const ProximityState(
        ready: false,
        statusMsg: "Permiso bloqueado. Ve a Ajustes > Apps > Permisos.",
        distanceMeters: double.infinity,
        within50m: false,
        last: null,
      );
      return;
    }

    // ✅ Ya OK
    state = ProximityState(
      ready: true,
      statusMsg: "Permisos OK. Esperando posición…",
      distanceMeters: state.distanceMeters,
      within50m: state.within50m,
      last: state.last,
    );

    // Stream principal
    _sub = repo
        .watch(debugFast: debugFast)
        .listen(
          _onPos,
          onError: (e) {
            state = ProximityState(
              ready: true,
              statusMsg: "Error en stream: $e",
              distanceMeters: state.distanceMeters,
              within50m: state.within50m,
              last: state.last,
            );
          },
        );

    // ✅ Fallback si en 8s no llega primera posición
    _fallbackTimer = Timer(const Duration(seconds: 8), () {
      if (_gotFirstFix) return;
      state = ProximityState(
        ready: true,
        statusMsg: "Stream no emitió. Activando fallback (polling)…",
        distanceMeters: state.distanceMeters,
        within50m: state.within50m,
        last: state.last,
      );

      _sub?.cancel();
      _sub = repo.poll(every: const Duration(seconds: 3)).listen(_onPos);
    });
  }

  void _onPos(Position p) {
    _gotFirstFix = true;
    final d = Geolocator.distanceBetween(
      p.latitude,
      p.longitude,
      poiLat,
      poiLon,
    );

    state = ProximityState(
      ready: true,
      statusMsg: "Posición OK",
      distanceMeters: d,
      within50m: d <= 50.0,
      last: p,
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;

    _sub?.cancel(); // ✅ no leaks
    _sub = null;

    super.dispose();
  }
}

final proximityProvider = StateNotifierProvider.autoDispose
    .family<ProximityController, ProximityState, ({double lat, double lon})>((
      ref,
      poi,
    ) {
      final c = ProximityController(ref, poiLat: poi.lat, poiLon: poi.lon);
      ref.onDispose(c.dispose);
      return c;
    });
