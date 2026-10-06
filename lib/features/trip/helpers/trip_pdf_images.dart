import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:http/http.dart' as http;
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';

class TripPdfImages {
  static Future<Map<String, Uint8List>> load(
      TripDetails trip, ImageBaseUrl? base) async {
    String? url(String? root, String? file) {
      if (file == null || file.isEmpty || file == 'null') return null;
      if (file.startsWith('https://') || file.startsWith('http://')) {
        return file;
      }
      if (root == null || root.isEmpty) return null;
      return '${root.replaceFirst(RegExp(r'/+$'), '')}/${file.replaceFirst(RegExp(r'^/+'), '')}';
    }

    final urls = {
      'driver': url(base?.profileImageDriver, trip.driver?.profileImage),
      'vehicle': url(base?.vehicleModel, trip.vehicle?.model?.image) ??
          url(base?.vehicleCategory, trip.vehicleCategory?.image),
    };
    final images = <String, Uint8List>{};
    await Future.wait(urls.entries.map((entry) async {
      if (entry.value == null) return;
      final client = http.Client();
      try {
        final response = await client
            .get(Uri.parse(entry.value!))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) return;
        // Embed the original photo as a compact image; document text stays text.
        final codec = await ui.instantiateImageCodec(response.bodyBytes,
            targetWidth: 480, allowUpscaling: false);
        try {
          final frame = await codec.getNextFrame();
          try {
            final data =
                await frame.image.toByteData(format: ui.ImageByteFormat.png);
            if (data != null) images[entry.key] = data.buffer.asUint8List();
          } finally {
            frame.image.dispose();
          }
        } finally {
          codec.dispose();
        }
      } catch (_) {
        // A missing/offline image must not prevent downloading the trip details.
      } finally {
        client.close();
      }
    }));
    return images;
  }
}
