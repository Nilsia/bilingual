import 'package:bilingual/models/words.dart';
import 'package:bilingual/utils/tools.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  final String tableName = "bilingual";

  static const String id = "id";
  static const String creationDate = "createDate";
  static const String words =
      "words"; // this one will be json example : {"english": glass, "french": verre}
  static const String containingPath = "path";
  static const String sentence = "sentence";
  static const String languages = "lang";

  late Future<Database> database;
  bool _initDone = false;

  DatabaseManager({hasToInit = false}) {
    if (hasToInit) {
      init();
      _initDone = true;
    }
  }

  Future<void> init() async {
    /* Directory dir = await getApplicationDocumentsDirectory();
    String appDocDir = dir.path; */
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'bilingual.db'),
      // When the database is first created, create a table to store all data.
      onCreate: (db, version) => createDb(db),
      version: 1,
    );
    _initDone = true;
  }

  void createDb(Database db) {
    String createTB = "CREATE TABLE IF NOT EXISTS";
    String idColDef = "INTEGER PRIMARY KEY AUTOINCREMENT";
    String nn = "NOT NULL";
    db.execute(
        '$createTB $tableName($id $idColDef $nn, $creationDate TEXT $nn, $words TEXT $nn, $containingPath TEXT $nn, $sentence TEXT $nn, $languages TEXT $nn);');
  }

  Future<bool> initDone() async {
    return _initDone;
  }

  /// insert Words into the database
  /// @return -1 on failure, 0 on success
  Future<int> addWords(Words words) async {
    final Database db = await database;
    final int res = await db.insert(tableName, words.toMap());
    return res == 0 ? -1 : 0;
  }

  Future<List<Words>> getAllWords({required String? path}) async {
    final Database db = await database;
    return Tools.nullFilter((path != null
            ? await db.query(tableName,
                columns: ["*"], where: "$containingPath = ?", whereArgs: [path])
            : await db.query(tableName, columns: ["*"]))
        .map((e) => Words.fromMap(e))
        .toList());
  }

  /// delete a Words from the database,
  /// return -1 in failure, 0 on success
  Future<int> removeWords(int wordsID) async {
    final Database db = await database;

    return (await db
                .delete(tableName, where: "$id = ?", whereArgs: [wordsID])) ==
            1
        ? 0
        : -1;
  }

  Future<int> updateWords(Words words) async {
    final Database db = await database;
    return await db.update(tableName, words.toMap(),
                where: "$id = ?", whereArgs: [words.id]) ==
            1
        ? 0
        : -1;
  }

  Future<int> setWordsPath(int wordsID, String newPath) async {
    final Database db = await database;
    return (await db.update(tableName, {containingPath: newPath},
                where: "$id = ?", whereArgs: [wordsID])) ==
            1
        ? 0
        : -1;
  }

  Future<List<String?>> getAllPathes() async => (await (await database)
          .rawQuery("select path from bilingual group by path"))
      .map<String>((e) => e[containingPath].toString())
      .toList();
}
