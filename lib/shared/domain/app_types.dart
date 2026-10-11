/// Languages currently supported by the assessment catalogue.
enum AppLanguage { english, french, german, spanish }

extension AppLanguageX on AppLanguage {
  String get label => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.french => 'French',
        AppLanguage.german => 'German',
        AppLanguage.spanish => 'Spanish',
      };
}

/// Common European Framework proficiency bands.
enum CefrLevel { a1, a2, b1, b2, c1, c2 }

extension CefrLevelX on CefrLevel {
  String get label => name.toUpperCase();
}

/// Skills measured independently by an assessment.
enum LanguageSkill { grammar, vocabulary, listening, speaking, reading, writing }
