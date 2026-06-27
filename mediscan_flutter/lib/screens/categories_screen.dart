import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  final VoidCallback onScanClick;
  const CategoriesScreen({super.key, required this.onScanClick});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _query = '';

  static const List<_Category> _categories = [
    _Category(
      title: 'Blood Tests',
      desc:
          'CBC, Sugar, Thyroid. Check infection, biological markers, and anemia levels.',
      icon: Icons.bloodtype_outlined,
      color: Color(0xFF0052CC),
      bg: Color(0xFFEFF6FF),
    ),
    _Category(
      title: 'Urine Tests',
      desc:
          'Screening for metabolic disorders, kidney function, and urinary tract infections.',
      icon: Icons.science_outlined,
      color: Color(0xFF15803D),
      bg: Color(0xFFF0FDF4),
    ),
    _Category(
      title: 'Imaging',
      desc:
          'X-Ray, MRI, and CT Scans for internal visual clinical diagnosis and body charting.',
      icon: Icons.medical_information_outlined,
      color: Color(0xFFEA580C),
      bg: Color(0xFFFFF7ED),
    ),
    _Category(
      title: 'Cardiac Tests',
      desc:
          'Electrocardiograms (ECG) and Stress Tests to monitor arterial rhythm.',
      icon: Icons.monitor_heart_outlined,
      color: Color(0xFFEF4444),
      bg: Color(0xFFFEF2F2),
    ),
    _Category(
      title: 'Hormone Tests',
      desc:
          'Analyzing endocrine health, insulin paths, thyroid balances, and metabolism.',
      icon: Icons.biotech_outlined,
      color: Color(0xFF7C3AED),
      bg: Color(0xFFF5F3FF),
    ),
    _Category(
      title: 'COVID-19',
      desc:
          'Rapid antigen checks and PCR tests for instant diagnostic viral screening.',
      icon: Icons.coronavirus_outlined,
      color: Color(0xFF0F766E),
      bg: Color(0xFFF0FDFA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _categories.where((c) {
      final q = _query.toLowerCase();
      return c.title.toLowerCase().contains(q) ||
          c.desc.toLowerCase().contains(q);
    }).toSet();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagnostic Categories',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'SEARCH AND SELECT A TEST CATEGORY FOR AI-ASSISTED ANALYSIS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search blood, cardiac, or MRI tests...',
              prefixIcon: Icon(Icons.search,
                  size: 18, color: Colors.grey.shade400),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppTheme.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Categories grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.95,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final isMatch = filtered.contains(cat);
              return AnimatedOpacity(
                opacity: isMatch ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cat.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(cat.icon,
                            color: cat.color, size: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cat.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          cat.desc,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Scan promo card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: AppTheme.green, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'AI POWERED SCAN',
                      style: TextStyle(
                        color: Color(0xFF6BFF8F),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Instant Result Decoding',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload any medical report to get a simplified clinical summary in seconds.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.onScanClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Start Scan Now',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Category {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final Color bg;

  const _Category({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.bg,
  });
}
