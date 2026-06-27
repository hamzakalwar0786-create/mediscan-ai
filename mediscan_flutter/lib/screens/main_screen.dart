import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/reports_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../models/medical_report.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'categories_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import 'analysis_screen.dart';
import 'emergency_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTab = 0;
  MedicalReport? _selectedReport;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<ap.AuthProvider>();
      if (auth.user != null) {
        context.read<ReportsProvider>().setUserId(auth.user!.uid);
        context.read<ChatProvider>().setUserId(auth.user!.uid);
      }
    });
  }

  void _openScan() async {
    final report = await showModalBottomSheet<MedicalReport>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ScanScreen(),
    );
    if (report != null && mounted) {
      setState(() {
        _selectedReport = report;
      });
    }
  }

  void _selectReport(MedicalReport report) {
    setState(() => _selectedReport = report);
  }

  void _navigateToTab(int tab) {
    setState(() {
      _selectedReport = null;
      _currentTab = tab;
    });
  }

  Future<void> _logout() async {
    await context.read<ap.AuthProvider>().signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isOnline = context.watch<ReportsProvider>().isOnline;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0A09) : const Color(0xFFF7F9FB),
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          // Offline banner
          if (!isOnline)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFFF7ED),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off,
                      size: 14, color: Color(0xFFEA580C)),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Offline mode — reports saved locally, will sync when connected',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFEA580C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _selectedReport != null
                ? AnalysisScreen(
                    report: _selectedReport!,
                    onBack: () => setState(() => _selectedReport = null),
                    onConsult: () {
                      if (_selectedReport != null) {
                        final title = _selectedReport!.title;
                        final status = _selectedReport!.status;
                        context.read<ChatProvider>().sendMessage(
                            'Can you clarify my results of "$title" where my stats indicate $status?');
                      }
                      setState(() {
                        _selectedReport = null;
                        _currentTab = 2;
                      });
                    },
                  )
                : _buildBody(),
          ),
        ],
      ),
      floatingActionButton: _selectedReport == null
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EmergencyScreen())),
              backgroundColor: AppTheme.red,
              mini: true,
              tooltip: 'Emergency SOS',
              child: const Icon(Icons.sos, color: Colors.white, size: 20),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1C1917) : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
            height: 1,
            color: isDark
                ? const Color(0xFF292524)
                : const Color(0xFFF3F4F6)),
      ),
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('M',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'MediScan AI',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: isDark
                  ? const Color(0xFF93C5FD)
                  : AppTheme.darkBlue,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<ThemeProvider>(
          builder: (_, tp, __) => IconButton(
            onPressed: () => context.read<ThemeProvider>().toggleDarkMode(),
            icon: Icon(
              tp.isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: tp.isDarkMode
                  ? const Color(0xFFFBBF24)
                  : Colors.grey.shade700,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Recent alerts: All clinical scanning servers are active and HIPAA-compliant.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_outlined, size: 22),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return DashboardScreen(
          onScanClick: _openScan,
          onSelectReport: _selectReport,
          onNavigateToTab: _navigateToTab,
        );
      case 1:
        return CategoriesScreen(onScanClick: _openScan);
      case 2:
        return const ChatScreen();
      case 3:
        return HistoryScreen(onSelectReport: _selectReport);
      case 4:
        return ProfileScreen(onLogout: _logout);
      default:
        return DashboardScreen(
          onScanClick: _openScan,
          onSelectReport: _selectReport,
          onNavigateToTab: _navigateToTab,
        );
    }
  }

  Widget _buildBottomNav(bool isDark) {

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1917) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF292524)
                : const Color(0xFFF3F4F6),
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // Home
              _navButton(0, Icons.dashboard_outlined, 'Home', isDark),
              // Search
              _navButton(1, Icons.search_outlined, 'Search', isDark),
              // Central FAB Scan
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: GestureDetector(
                        onTap: _openScan,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Icon(Icons.document_scanner,
                              color: Colors.white, size: 26),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Chat
              _navButton(2, Icons.chat_bubble_outline, 'Doctor AI', isDark),
              // History
              _navButton(3, Icons.history, 'History', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(int tab, IconData icon, String label, bool isDark) {
    final isActive = _currentTab == tab && _selectedReport == null;
    final activeColor =
        isDark ? const Color(0xFF60A5FA) : AppTheme.primaryBlue;
    final inactiveColor =
        isDark ? const Color(0xFF78716C) : Colors.grey.shade400;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _selectedReport = null;
          _currentTab = tab;
        }),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isActive ? activeColor : inactiveColor, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


