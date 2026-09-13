import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional Reproduction of the Taj Company Limited Quran Cover Page
/// Design based on Hazrat Qari Raheem Bakhsh Rahmatullah Alaih's Tajweed Quran.
class MushafCoverPage extends StatelessWidget {
  const MushafCoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Top Bismillah Calligraphy (Placeholder/Icon)
          const Icon(Icons.wb_sunny_outlined, color: AppConstants.gold, size: 40),
          const SizedBox(height: 10),
          
          // 2. "Layamassuhu Illal Mutahharoon" Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1E6B5C),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: const Text(
              'لَا يَمَسُّهُ إِلَّا الْمُطَهَّرُونَ',
              style: TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const Spacer(),
          
          // 3. Central Large "Al-Quran al-Kareem" Medallion
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Floral Circle
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppConstants.gold, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/floral_circle_bg.png'), // Should be added to assets
                    fit: BoxFit.cover,
                    opacity: 0.2,
                  ),
                ),
              ),
              // Inner Red Circle
              Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'الْقُرْآنُ الْكَرِيمُ',
                      style: TextStyle(
                        fontFamily: AppConstants.uthmaniFont,
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'رنگین تجویدی',
                      style: TextStyle(
                        fontFamily: AppConstants.uthmaniFont,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // 4. Credits Section
          Text(
            'حضرت قاری رحیم بخش رحمۃ اللہ علیہ',
            style: GoogleFonts.notoNastaliqUrdu(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D3B2E),
            ),
          ),
          const SizedBox(height: 12),
          
          // 5. Taj Company Limited Logo Style
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories, color: Color(0xFF1E6B5C), size: 30),
              const SizedBox(width: 10),
              Text(
                'تاج کمپنی لمیٹڈ',
                style: GoogleFonts.notoNastaliqUrdu(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFB71C1C),
                ),
              ),
            ],
          ),
          const Text(
            'لاہور - کراچی - پشاور - راولپنڈی',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
