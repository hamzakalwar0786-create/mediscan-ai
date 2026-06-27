import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnim;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(begin: 0.04, end: 0.96).animate(
      CurvedAnimation(
          parent: _scanLineController, curve: Curves.easeInOut),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  // ── Camera capture ─────────────────────────────────────────────────────────
  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 2000,
      maxHeight: 2000,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _analyze(bytes, file.name);
  }

  // ── Gallery / File upload ──────────────────────────────────────────────────
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2000,
      maxHeight: 2000,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _analyze(bytes, file.name);
  }

  Future<void> _analyze(Uint8List bytes, String fileName) async {
    final provider = context.read<ReportsProvider>();
    final report = await provider.scanReport(
      imageBytes: bytes,
      fileName: fileName,
    );
    if (report != null && mounted) {
      Navigator.of(context).pop(report);
    }
  }

  void _simulateScan(int index) async {
    final provider = context.read<ReportsProvider>();
    await Future.delayed(const Duration(milliseconds: 1200));
    final report = provider.simulateScan(index);
    if (mounted) Navigator.of(context).pop(report);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();
    final isScanning = provider.isScanning;

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Color(0xFF07090E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 24),
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Scan Medical Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'MEDISCAN AI • OCR POWERED',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Column(
                    children: [
                      // ── PRIMARY ACTIONS: 2 BIG BUTTONS ──────────────────
                      Row(
                        children: [
                          // SCAN with Camera
                          Expanded(
                            child: _PrimaryActionCard(
                              icon: Icons.camera_alt,
                              label: 'Scan Report',
                              sublabel: 'Use Camera',
                              gradient: [
                                AppTheme.primaryBlue,
                                AppTheme.darkBlue,
                              ],
                              onTap: _pickFromCamera,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // UPLOAD Image
                          Expanded(
                            child: _PrimaryActionCard(
                              icon: Icons.upload_file_outlined,
                              label: 'Upload Image',
                              sublabel: 'From Gallery',
                              gradient: const [
                                Color(0xFF059669),
                                Color(0xFF065F46),
                              ],
                              onTap: _pickFromGallery,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Scanner viewfinder ───────────────────────────────
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryBlue
                                  .withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              // BG
                              Container(
                                color: const Color(0xFF0C0E14),
                                child: Center(
                                  child: Icon(
                                    Icons.description_outlined,
                                    size: 64,
                                    color: Colors.white
                                        .withValues(alpha: 0.04),
                                  ),
                                ),
                              ),
                              // Laser line
                              AnimatedBuilder(
                                animation: _scanLineAnim,
                                builder: (_, __) {
                                  final h =
                                      MediaQuery.of(context).size.width *
                                          0.75 *
                                          (4 / 3);
                                  return Positioned(
                                    top: h * _scanLineAnim.value,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.cyanAccent
                                                .withValues(alpha: 0.8),
                                            Colors.cyanAccent,
                                            Colors.cyanAccent
                                                .withValues(alpha: 0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.cyanAccent
                                                .withValues(alpha: 0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Corner marks
                              ..._buildCornerMarks(),
                              // Label
                              Positioned(
                                bottom: 16,
                                left: 12,
                                right: 12,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 5),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.7),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Align medical document within frame',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Divider ──────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                                color: Colors.white
                                    .withValues(alpha: 0.1)),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'QUICK DEMO SCANS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                                color: Colors.white
                                    .withValues(alpha: 0.1)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Simulator buttons ────────────────────────────────
                      Row(
                        children: [
                          _SimButton(
                            label: 'CBC Blood',
                            icon: Icons.bloodtype_outlined,
                            onTap: () => _simulateScan(0),
                          ),
                          const SizedBox(width: 8),
                          _SimButton(
                            label: 'Lipid Panel',
                            icon: Icons.monitor_heart_outlined,
                            onTap: () => _simulateScan(1),
                          ),
                          const SizedBox(width: 8),
                          _SimButton(
                            label: 'Vitamin D',
                            icon: Icons.wb_sunny_outlined,
                            onTap: () => _simulateScan(2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Error
                      if (provider.scanError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.scanError!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Processing overlay ─────────────────────────────────────────────
          if (isScanning)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xF507090E),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryBlue
                                    .withValues(alpha: 0.2),
                                width: 4,
                              ),
                            ),
                          ),
                          RotationTransition(
                            turns: _spinController,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryBlue,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                          Icon(Icons.biotech_outlined,
                              color: AppTheme.primaryBlue, size: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Analyzing Report...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        provider.scanStatus,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'BIO-INTELLIGENCE ACTIVE',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerMarks() {
    return [
      Positioned(
          top: 14, left: 14, child: _cornerMark(top: true, left: true)),
      Positioned(
          top: 14, right: 14, child: _cornerMark(top: true, left: false)),
      Positioned(
          bottom: 14,
          left: 14,
          child: _cornerMark(top: false, left: true)),
      Positioned(
          bottom: 14,
          right: 14,
          child: _cornerMark(top: false, left: false)),
    ];
  }

  Widget _cornerMark({required bool top, required bool left}) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _CornerPainter(top: top, left: left)),
    );
  }
}

// ── Primary action card widget ────────────────────────────────────────────────
class _PrimaryActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Simulator button ───────────────────────────────────────────────────────────
class _SimButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SimButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white54, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Corner mark painter ───────────────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;
  const _CornerPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
