import 'dart:convert';

import 'package:bilingual/models/database_manager.dart';

class Words {
  int id;
  List<String> translations = [];
  late DateTime creationDate;
  String containingPath, sentence, languages;

  Words(this.id, this.translations, this.creationDate, this.containingPath,
      this.sentence, this.languages);

  Words.none(
      {this.id = -1,
      this.containingPath = "",
      this.sentence = "",
      this.languages = ''}) {
    creationDate = DateTime.now();
  }

  Map<String, String> toMap() => {
        DatabaseManager.containingPath: containingPath,
        DatabaseManager.creationDate: creationDate.toString(),
        DatabaseManager.words: jsonEncode(translations),
        DatabaseManager.sentence: sentence,
        DatabaseManager.languages: languages,
      };

  static Words? fromMap(Map<String, Object?> map) {
    if (!map.containsKey(DatabaseManager.id) ||
        !map.containsKey(DatabaseManager.containingPath) ||
        !map.containsKey(DatabaseManager.creationDate) ||
        !map.containsKey(DatabaseManager.words) ||
        !map.containsKey(DatabaseManager.sentence) ||
        !map.containsKey(DatabaseManager.languages)) {
      return null;
    }

    int? id = int.tryParse(map[DatabaseManager.id].toString());

    String containingPath = map[DatabaseManager.containingPath].toString();
    String sentence = map[DatabaseManager.sentence].toString();
    String languages = map[DatabaseManager.languages].toString();

    DateTime? creationDate =
        DateTime.tryParse(map[DatabaseManager.creationDate].toString());
    List<String>? translations =
        jsonDecode(map[DatabaseManager.words].toString()).cast<String>();

    return id != null && creationDate != null && translations != null
        ? Words(
            id, translations, creationDate, containingPath, sentence, languages)
        : null;
  }
}
