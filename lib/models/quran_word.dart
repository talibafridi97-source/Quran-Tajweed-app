class QuranWord {
  final int? id;
  final int? position;
  final String? codeV2;
  final String? textUthmani;
  final int? lineNumber;
  final int? pageNumber;
  final String? charTypeName;
  final String? verseKey;
  final String? audioUrl;
  final String? translation;
  final String? transliteration;

  QuranWord({
    this.id,
    this.position,
    this.codeV2,
    this.textUthmani,
    this.lineNumber,
    this.pageNumber,
    this.charTypeName,
    this.verseKey,
    this.audioUrl,
    this.translation,
    this.transliteration,
  });

  bool get isEnd => charTypeName == 'end';

  factory QuranWord.fromJson(Map<String, dynamic> json, {String? verseKey}) {
    String? trans;
    if (json['translation'] != null) {
      if (json['translation'] is Map) {
        trans = json['translation']['text'];
      } else if (json['translation'] is String) {
        trans = json['translation'];
      }
    }

    String? translit;
    if (json['transliteration'] != null) {
      if (json['transliteration'] is Map) {
        translit = json['transliteration']['text'];
      } else if (json['transliteration'] is String) {
        translit = json['transliteration'];
      }
    }

    return QuranWord(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      position: json['position'] is int ? json['position'] : int.tryParse(json['position']?.toString() ?? ''),
      codeV2: json['code_v2']?.toString() ?? json['codeV2']?.toString(),
      textUthmani: json['text_uthmani']?.toString() ?? json['textUthmani']?.toString() ?? json['text']?.toString(),
      lineNumber: json['line_number'] is int ? json['line_number'] : int.tryParse(json['line_number']?.toString() ?? json['lineNumber']?.toString() ?? ''),
      pageNumber: json['page_number'] is int ? json['page_number'] : int.tryParse(json['page_number']?.toString() ?? json['pageNumber']?.toString() ?? json['v2_page']?.toString() ?? ''),
      charTypeName: json['char_type_name']?.toString() ?? json['charTypeName']?.toString(),
      verseKey: json['verse_key']?.toString() ?? json['verseKey']?.toString() ?? verseKey,
      audioUrl: json['audio_url']?.toString() ?? json['audioUrl']?.toString(),
      translation: trans,
      transliteration: translit,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'position': position,
    'code_v2': codeV2,
    'text_uthmani': textUthmani,
    'line_number': lineNumber,
    'page_number': pageNumber,
    'char_type_name': charTypeName,
    'verse_key': verseKey,
    'audio_url': audioUrl,
    'translation': translation,
    'transliteration': transliteration,
  };

  factory QuranWord.fromDb(Map<String, dynamic> map) {
    return QuranWord(
      id: map['id'] as int?,
      position: map['position'] as int?,
      codeV2: map['code_v2'] as String?,
      textUthmani: map['text_uthmani'] as String?,
      lineNumber: map['line_number'] as int?,
      pageNumber: map['page_number'] as int?,
      charTypeName: map['char_type_name'] as String?,
      verseKey: map['verse_key'] as String?,
      audioUrl: map['audio_url'] as String?,
      translation: map['translation'] as String?,
      transliteration: map['transliteration'] as String?,
    );
  }

  Map<String, dynamic> toDbMap() => {
    'id': id,
    'position': position,
    'code_v2': codeV2,
    'text_uthmani': textUthmani,
    'line_number': lineNumber,
    'page_number': pageNumber,
    'char_type_name': charTypeName,
    'verse_key': verseKey,
    'audio_url': audioUrl,
    'translation': translation,
    'transliteration': transliteration,
  };
}
