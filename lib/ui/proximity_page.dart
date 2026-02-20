import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../location/proximity_controller.dart';

class ProximityPage extends ConsumerWidget {
  const ProximityPage({super.key});

  // ✅ Cambia por el punto de crisis real
  static const poiLat = -3.99313;
  static const poiLon = -79.20422;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(proximityProvider((lat: poiLat, lon: poiLon)));

    return Scaffold(
      appBar: AppBar(title: const Text("GPS + Proximidad (Riverpod)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Estado: ${st.statusMsg}"),
            const SizedBox(height: 10),
            Text("Distancia al POI: ${st.distanceMeters.toStringAsFixed(1)} m"),
            const SizedBox(height: 10),
            Text(st.within50m ? "✅ Dentro de 50m" : "⏳ Fuera de 50m"),
            const Divider(height: 24),
            Text("Última posición:"),
            Text(
              st.last == null
                  ? "—"
                  : "lat=${st.last!.latitude}, lon=${st.last!.longitude}\n"
                        "acc=${st.last!.accuracy}m",
            ),
            const SizedBox(height: 20),
            const Text(
              "Tip: prueba caminando o moviéndote unos metros.\n"
              "En algunos Xiaomi, desactiva ahorro de batería para la app.",
            ),
          ],
        ),
      ),
    );
  }
}
