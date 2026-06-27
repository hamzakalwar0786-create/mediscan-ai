// Features: EMERGENCY SOS BUTTON + NEARBY HOSPITALS
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  final LocationService _locationSvc = LocationService();
  bool _sosSending = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 1.0, end: 1.12).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ Send SOS?',
            style: TextStyle(color: Color(0xFFEF4444))),
        content: const Text(
            'This will call 1122 and share your live location with emergency contacts via WhatsApp/SMS.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                foregroundColor: Colors.white),
            child: const Text('Send SOS',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _sosSending = true);
    await _locationSvc.triggerSOS();
    if (mounted) {
      setState(() => _sosSending = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('🚨 SOS sent! Emergency services alerted.'),
        backgroundColor: Color(0xFFEF4444),
        duration: Duration(seconds: 5),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency & Hospitals')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── SOS Button ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppTheme.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    'EMERGENCY SOS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to call 1122 + share your location',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: child,
                    ),
                    child: GestureDetector(
                      onTap: _sosSending ? null : _triggerSOS,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.red,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.red.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: _sosSending
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.sos,
                                      color: Colors.white, size: 44),
                                  SizedBox(height: 4),
                                  Text(
                                    'SOS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Quick Call Buttons ──────────────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Quick Emergency Calls',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _CallButton(
                  number: '1122',
                  label: 'Rescue 1122',
                  icon: Icons.local_fire_department,
                  color: AppTheme.red,
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: _CallButton(
                  number: '115',
                  label: 'Edhi Ambulance',
                  icon: Icons.emergency,
                  color: Colors.orange,
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: _CallButton(
                  number: '1512',
                  label: 'Chhipa Rescue',
                  icon: Icons.medical_services_outlined,
                  color: Colors.green,
                )),
              ],
            ),
            const SizedBox(height: 20),

            // ── Find Nearby Hospitals ──────────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Nearby Hospitals',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),

            // Open Maps button
            _OpenMapsCard(
              onOpen: () => _locationSvc.openNearbyHospitals(),
            ),
            const SizedBox(height: 14),

            // Static hospital list (Pakistan major cities)
            ..._staticHospitals.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HospitalCard(hospital: h),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Static hospitals list ──────────────────────────────────────────────────────
const List<_StaticHospital> _staticHospitals = [
  _StaticHospital(
    name: 'Services Hospital Lahore',
    address: 'Shadman, Lahore, Punjab',
    phone: '+92-42-99203580',
    type: 'Government',
    is24h: true,
    emoji: '🏥',
  ),
  _StaticHospital(
    name: 'Jinnah Hospital Lahore',
    address: 'Jail Road, Lahore',
    phone: '+92-42-99231501',
    type: 'Government',
    is24h: true,
    emoji: '🏥',
  ),
  _StaticHospital(
    name: 'Aga Khan Hospital Karachi',
    address: 'Stadium Rd, Karachi',
    phone: '+92-21-34930051',
    type: 'Private',
    is24h: true,
    emoji: '🏨',
  ),
  _StaticHospital(
    name: 'PIMS Islamabad',
    address: 'G-8/3, Islamabad',
    phone: '+92-51-9261170',
    type: 'Government',
    is24h: true,
    emoji: '🏥',
  ),
  _StaticHospital(
    name: 'Shaukat Khanum Cancer Hospital',
    address: '7-A, Block R-3, Lahore',
    phone: '+92-42-35945100',
    type: 'Private',
    is24h: false,
    emoji: '🔬',
  ),
];

class _StaticHospital {
  final String name;
  final String address;
  final String phone;
  final String type;
  final bool is24h;
  final String emoji;
  const _StaticHospital({
    required this.name,
    required this.address,
    required this.phone,
    required this.type,
    required this.is24h,
    required this.emoji,
  });
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _CallButton extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  final Color color;
  const _CallButton(
      {required this.number,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri(scheme: 'tel', path: number);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              number,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 9, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _OpenMapsCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _OpenMapsCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.map_outlined,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find Nearest Hospitals',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      )),
                  SizedBox(height: 2),
                  Text('Opens Google Maps with live GPS',
                      style: TextStyle(
                          color: Colors.white60, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white60, size: 16),
          ],
        ),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final _StaticHospital hospital;
  const _HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Text(hospital.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(hospital.address,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: hospital.type == 'Government'
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(hospital.type,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: hospital.type == 'Government'
                                ? AppTheme.primaryBlue
                                : AppTheme.green,
                          )),
                    ),
                    if (hospital.is24h) ...[
                      const SizedBox(width: 6),
                      const Text('24/7',
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final uri = Uri(scheme: 'tel', path: hospital.phone);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            icon: Icon(Icons.phone_outlined,
                color: AppTheme.primaryBlue, size: 20),
          ),
        ],
      ),
    );
  }
}
