// Features: EMERGENCY BUTTON + NEARBY HOSPITALS
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notification_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;
  LocationService._();

  // ── Request & get current location ────────────────────────────────────────
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  // ── SOS Emergency — call 1122 + share location ────────────────────────────
  Future<void> triggerSOS() async {
    // 1. Show notification immediately
    await NotificationService().showEmergencyAlert();

    // 2. Get location
    final position = await getCurrentPosition();

    // 3. Call 1122 (Pakistan emergency)
    await callEmergency('1122');

    // 4. If position found, open share with location
    if (position != null) {
      await shareLocationViaWhatsApp(position);
    }
  }

  // ── Call emergency number ─────────────────────────────────────────────────
  Future<void> callEmergency(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ── Share location via WhatsApp/SMS ───────────────────────────────────────
  Future<void> shareLocationViaWhatsApp(Position position) async {
    final message = Uri.encodeComponent(
      '🚨 EMERGENCY — I need help!\n'
      'My location: https://maps.google.com/?q=${position.latitude},${position.longitude}\n'
      'Sent via MediScan AI',
    );
    final uri = Uri.parse('whatsapp://send?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: SMS
      final smsUri = Uri.parse('sms:?body=$message');
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }
  }

  // ── Open Google Maps with nearby hospitals search ─────────────────────────
  Future<void> openNearbyHospitals() async {
    final position = await getCurrentPosition();
    Uri uri;

    if (position != null) {
      uri = Uri.parse(
          'https://www.google.com/maps/search/hospitals+near+me/@${position.latitude},${position.longitude},14z');
    } else {
      uri = Uri.parse(
          'https://www.google.com/maps/search/hospitals+near+me');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Calculate distance between two coordinates (km) ──────────────────────
  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}

// ── Mock nearby hospitals data (shown when Maps not available) ────────────────
class NearbyHospital {
  final String name;
  final String address;
  final String phone;
  final double lat;
  final double lng;
  final double distanceKm;
  final String type; // 'Government', 'Private', 'Clinic'
  final bool is24Hours;

  const NearbyHospital({
    required this.name,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.type,
    this.is24Hours = true,
  });
}
