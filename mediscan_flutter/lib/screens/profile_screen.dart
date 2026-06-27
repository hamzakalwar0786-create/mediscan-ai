import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'reminders_screen.dart';
import 'health_trends_screen.dart';
import 'emergency_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _personalInfoOpen = false;
  String _userName = 'Dr. Sarah Mitchell';
  String _bloodType = 'O Positive (O+)';
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<ap.AuthProvider>().user;
    if (user == null) return;
    try {
      final profile = await _firestore.fetchUserProfile(user.uid);
      if (profile != null && mounted) {
        setState(() {
          _userName = profile['displayName'] ??
              user.displayName ??
              _userName;
          _bloodType = profile['bloodType'] ?? _bloodType;
        });
      }
    } catch (_) {}
  }

  Future<void> _updateProfile() async {
    final user = context.read<ap.AuthProvider>().user;
    if (user == null) return;
    await _firestore.updateUserProfile(user.uid, {
      'displayName': _userName,
      'bloodType': _bloodType,
    });
  }

  void _editName() {
    final ctrl = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(hintText: 'Enter your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _userName = ctrl.text.trim());
                _updateProfile();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editBloodType() {
    final types = [
      'A Positive (A+)',
      'A Negative (A-)',
      'B Positive (B+)',
      'B Negative (B-)',
      'AB Positive (AB+)',
      'AB Negative (AB-)',
      'O Positive (O+)',
      'O Negative (O-)',
    ];
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Blood Type'),
        children: types.map((t) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => _bloodType = t);
              _updateProfile();
              Navigator.pop(context);
            },
            child: Text(t),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      child: Text(
                        (_userName.isNotEmpty
                            ? _userName[0].toUpperCase()
                            : 'U'),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _editName,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _editBloodType,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.water_drop,
                            size: 12, color: AppTheme.red),
                        const SizedBox(width: 4),
                        Text(
                          _bloodType,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Personal info section
          _MenuSection(children: [
            _MenuItem(
              icon: Icons.person_outline,
              iconColor: AppTheme.primaryBlue,
              iconBg: AppTheme.primaryBlue.withOpacity(0.1),
              title: 'Personal Information',
              onTap: () =>
                  setState(() => _personalInfoOpen = !_personalInfoOpen),
              trailing: Icon(
                _personalInfoOpen
                    ? Icons.expand_less
                    : Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ),
            if (_personalInfoOpen)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                color: Colors.grey.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('Email', user?.email ?? 'N/A'),
                    _InfoRow('Status', 'Verified Health Patient'),
                    _InfoRow('UID', user?.uid.substring(0, 12) ?? 'N/A'),
                  ],
                ),
              ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.folder_open_outlined,
              iconColor: Colors.green,
              iconBg: Colors.green.withOpacity(0.1),
              title: 'Health Records',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Loading clinic cloud directories...')),
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.verified_user_outlined,
              iconColor: Colors.orange,
              iconBg: Colors.orange.withOpacity(0.1),
              title: 'Insurance Details',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Validating insurance ledger context...')),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Preferences section
          _MenuSection(children: [
            _MenuItem(
              icon: Icons.dark_mode_outlined,
              iconColor: Colors.grey.shade700,
              iconBg: Colors.grey.shade100,
              title: 'Dark Mode',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) =>
                    context.read<ThemeProvider>().toggleDarkMode(),
                activeColor: AppTheme.primaryBlue,
              ),
              onTap: () =>
                  context.read<ThemeProvider>().toggleDarkMode(),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.language,
              iconColor: Colors.grey.shade700,
              iconBg: Colors.grey.shade100,
              title: 'Language',
              subtitle: 'English / Urdu / Hindi support',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Language selection coming soon.')),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Support section
          _MenuSection(children: [
            _MenuItem(
              icon: Icons.add_alarm_outlined,
              iconColor: Colors.purple,
              iconBg: Colors.purple.withOpacity(0.1),
              title: 'Medicine Reminders',
              subtitle: 'Daily push notification alerts',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RemindersScreen())),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.trending_up,
              iconColor: AppTheme.green,
              iconBg: AppTheme.green.withOpacity(0.1),
              title: 'Health Trends',
              subtitle: 'Charts showing improvement over time',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const HealthTrendsScreen())),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.sos,
              iconColor: AppTheme.red,
              iconBg: AppTheme.red.withOpacity(0.1),
              title: 'Emergency & Hospitals',
              subtitle: 'SOS button + nearby hospitals map',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const EmergencyScreen())),
            ),
          ]),
          const SizedBox(height: 12),

          // Help section
          _MenuSection(children: [
            _MenuItem(
              icon: Icons.help_outline,
              iconColor: AppTheme.primaryBlue,
              iconBg: AppTheme.primaryBlue.withOpacity(0.1),
              title: 'Help & Support',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('MediScan AI Support is online.')),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Sign Out'),
                    content:
                        const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text('Sign Out',
                              style:
                                  TextStyle(color: Color(0xFFEF4444)))),
                    ],
                  ),
                );
                if (confirm == true) widget.onLogout();
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.red,
                side: BorderSide(color: AppTheme.red.withOpacity(0.3)),
                backgroundColor: AppTheme.red.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<Widget> children;
  const _MenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9CA3AF)))
          : null,
      trailing: trailing ??
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11),
          children: [
            TextSpan(
                text: '$label: ',
                style:
                    const TextStyle(color: Color(0xFF9CA3AF))),
            TextSpan(
                text: value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }
}
