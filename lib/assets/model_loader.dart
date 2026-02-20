import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

final modelLoaderProvider = Provider((ref) => ModelLoader());

class ModelLoader {
  // Ejemplo: cache simple por nombre.
  Future<File> getModelCached({required String name, required Uri url}) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name.glb');

    if (await file.exists()) return file;

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("No se pudo descargar modelo ($name)");
    }
    await file.writeAsBytes(res.bodyBytes, flush: true);
    return file;
  }
}
