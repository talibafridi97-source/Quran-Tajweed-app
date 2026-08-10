import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/constants.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _counter = 0;
  int _targetGoal = 33;
  String _selectedDua = 'سُبْحَانَ اللَّهِ (SubhanAllah)';

  final List<String> _presets = [
    'سُبْحَانَ اللَّهِ (SubhanAllah)',
    'الْحَمْدُ لِلَّهِ (Alhamdulillah)',
    'اللَّهُ أَكْبَرُ (Allahu Akbar)',
    'أَسْتَغْفِرُ اللَّهَ (Astaghfirullah)',
    'لَا إِلٰهَ إِلَّا اللَّهُ (La ilaha illallah)',
    'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ (Salawat)',
  ];

  void _incrementCounter() {
    HapticFeedback.lightImpact();
    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Digital Tasbeeh Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCounter,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Presets Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDua,
                  isExpanded: true,
                  items: _presets.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedDua = val;
                        _counter = 0;
                      });
                    }
                  },
                ),
              ),
            ),

            const Spacer(),

            // Large Digital Counter Display
            GestureDetector(
              onTap: _incrementCounter,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.primaryGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryGreen.withOpacity(0.35),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_counter',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Target: $_targetGoal',
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Tap the circle to count',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const Spacer(),

            // Goal Selection Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [33, 100, 500, 1000].map((goal) {
                final isSelected = _targetGoal == goal;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text('$goal'),
                    selected: isSelected,
                    selectedColor: AppConstants.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _targetGoal = goal;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
