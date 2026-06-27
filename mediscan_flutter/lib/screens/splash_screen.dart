import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _scanAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      _navigate();
    });
  }

  void _navigate() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ambient light blobs
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.green.withOpacity(0.07),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo card
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.primaryBlue.withOpacity(0.15),
                            blurRadius: 30 + (_pulseController.value * 10),
                            spreadRadius: 2,
                          )
                        ],
                        border: Border.all(
                          color: Colors.grey.shade100,
                        ),
                      ),
                      child: _buildLogoBox(),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'MediScan AI',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.darkBlue,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Bouncing dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue
                                .withOpacity(1.0 - (i * 0.25)),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          // Footer
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'AI-POWERED HEALTHCARE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user,
                          size: 14, color: AppTheme.green),
                      const SizedBox(width: 6),
                      Text(
                        'Secure Clinical Data Processing',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoBox() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          // White cross
          Container(width: 8, height: 60, color: Colors.white),
          Container(width: 60, height: 8, color: Colors.white),
          // Heartbeat line
          CustomPaint(
            size: const Size(80, 60),
            painter: _HeartbeatPainter(),
          ),
          // Scanning laser line
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (_, __) {
              return Positioned(
                top: 120 * _scanAnim.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.6),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.25, size.height / 2);
    path.lineTo(size.width * 0.35, 0);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.65, size.height / 2);
    path.lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
