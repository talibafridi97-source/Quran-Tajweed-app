import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/settings_provider.dart';

class OnboardingSlide {
  final String title;
  final String arabicTitle;
  final String description;
  final IconData icon;
  final Color accentColor;

  const OnboardingSlide({
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Professional 16-Line Quran Mushaf',
      arabicTitle: 'المصحف الشريف',
      description: 'Read the Holy Quran with responsive 16-line layout, beautiful typography, and complete offline preservation.',
      icon: Icons.menu_book_rounded,
      accentColor: AppConstants.primaryGreen,
    ),
    OnboardingSlide(
      title: 'Interactive Tajweed Guide',
      arabicTitle: 'أحكام التجويد الملونة',
      description: 'Learn and perfect recitation with color-coded Ghunnah, Qalqalah, Ikhfa, Idgham, Madd, and Waqf stopping signs.',
      icon: Icons.school_rounded,
      accentColor: AppConstants.gold,
    ),
    OnboardingSlide(
      title: 'Multi-Translations & Tafsir',
      arabicTitle: 'الترجمة والتفسير',
      description: 'Deepen understanding with Urdu & English translations, Tafsir Ibn Kathir, Bayan-ul-Quran, and FTS5 search.',
      icon: Icons.translate_rounded,
      accentColor: Color(0xFF00897B),
    ),
    OnboardingSlide(
      title: 'Smart Digital Tasbeeh & Tools',
      arabicTitle: 'التسبيح والختمة',
      description: 'Count and log your daily Dhikr, set custom Khatam plans, and access authentic Masnoon Duas and 99 Names of Allah.',
      icon: Icons.fingerprint_rounded,
      accentColor: Color(0xFFE65100),
    ),
    OnboardingSlide(
      title: 'Accurate Prayer Times & Qibla',
      arabicTitle: 'أوقات الصلاة والقبلة',
      description: 'Astronomical calculation methods, live countdown timer, Adhan notifications, and real-time Qibla compass.',
      icon: Icons.explore_rounded,
      accentColor: Color(0xFF1E88E5),
    ),
  ];

  void _finishOnboarding() async {
    final settings = context.read<SettingsProvider>();
    await settings.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Slide Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Decorative Icon Badge
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slide.accentColor.withValues(alpha: 0.12),
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.35),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 68,
                            color: slide.accentColor,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Arabic Title
                        Text(
                          slide.arabicTitle,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: slide.accentColor,
                            fontFamily: AppConstants.uthmaniFont,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // English Title
                        Text(
                          slide.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 14),

                        // Description
                        Text(
                          slide.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: scheme.onSurface.withValues(alpha: 0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation: Indicator & Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Smooth Dot Indicators
                  Row(
                    children: List.generate(_slides.length, (idx) {
                      final isActive = _currentPage == idx;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? scheme.primary : scheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastPage ? Icons.check_circle : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
