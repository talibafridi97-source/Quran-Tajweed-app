class ArabicTextNormalizer {
  // Unicode ranges for Arabic combining diacritical marks (Tashkeel / Harakat)
  static final RegExp _harakatRegex = RegExp(
    r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED\u08D4-\u08E1\u08E3-\u08FF\uFE70-\uFE7F]',
  );

  /// Strips all Harakat / diacritics and normalizes letter variations for robust search.
  /// NEVER use this to mutate stored canonical Quran text!
  static String normalize(String text) {
    if (text.isEmpty) return '';

    // Step 1: Strip non-spacing combining diacritics (Zabar, Zer, Pesh, Tanween, Shaddah, Sukun, Maddah)
    String clean = text.replaceAll(_harakatRegex, '');

    // Step 2: Strip Quranic stop marks / small symbols / Tatweel
    clean = clean
        .replaceAll('\u0640', '') // Tatweel (Kashida)
        .replaceAll('\u06E2', '') // Small High Meem
        .replaceAll('\u06ED', '') // Small Low Meem
        .replaceAll('\u06E1', '') // Small High Dotless Head of Khah
        .replaceAll('\u06E0', '') // Small High Upright Rectangular Zero
        .replaceAll('\u06DF', '') // Small High Rounded Zero
        .replaceAll('\u06E5', '') // Small Waw
        .replaceAll('\u06E6', '') // Small Ya
        .replaceAll('\uFEFF', ''); // Byte Order Mark

    // Step 3: Unify Alef variations [إ, أ, آ, ٱ, ٲ, ٳ] -> ا
    clean = clean
        .replaceAll(RegExp(r'[\u0622\u0623\u0625\u0671\u0672\u0673\u0675]'), 'ا')
        // Unify Taa Marbuta [ة] -> ه
        .replaceAll('\u0629', 'ه')
        // Unify Alif Maksura [ى] -> ي and Hamza on Ya [ئ] -> ي
        .replaceAll(RegExp(r'[\u0649\u0626]'), 'ي')
        // Unify Waw with Hamza [ؤ] -> و
        .replaceAll('\u0624', 'و');

    return clean.trim();
  }
}
