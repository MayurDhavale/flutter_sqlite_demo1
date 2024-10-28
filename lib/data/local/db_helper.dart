import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  ///singletone
  DbHelper._();

  static final DbHelper getInstance = DbHelper._();

  static const String TABLE_NOTE = "note";
  static const String COLUMN_NOTE_SNO = "s_no";
  static const String COLUMN_NOTE_TITLE = "title";
  static const String COLUMN_NOTE_DESC = "desc";

  Database? myDb;

  Future<Database> getDb() async {
    myDb ??= await openDb();
    return myDb!;
    // if (myDb != null) {
    //   return myDb!;
    // } else {
    //   myDb = await openDb();
    //   return myDb!;
    // }
  }

  Future<Database> openDb() async {
    // Directory appDir = await getDatabasesPath();

    // final dbPath = join(appDir.path, "noteDb.db");

    // final databaseDirPath = await getDatabasesPath();
    // final dbPath = join(databaseDirPath, 'noteDb.db');

    var databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'noteDb.db');

    return await openDatabase(dbPath, onCreate: (db, version) {
      /// create all tables here
      db.execute(
          "create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)");

      //
      //
    }, version: 1);
  }

  /// all queries
  /// insertion
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDb();

    int rowsEffected = await db.insert(
        TABLE_NOTE, {COLUMN_NOTE_TITLE: mTitle, COLUMN_NOTE_DESC: mDesc});
    return rowsEffected > 0;
  }

  /// reading all data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDb();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);

    return mData;
  }

  Future<bool> updateNote(
      {required String mTitle, required String mDesc, required int sno}) async {
    var db = await getDb();

    int rowsEffected = await db.update(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TITLE: mTitle,
          COLUMN_NOTE_DESC: mDesc,
        },
        where: "$COLUMN_NOTE_SNO = $sno");

    return rowsEffected > 0;
  }

  Future<bool> deleteNote({required int sno}) async {
    var db = await getDb();

    int rowsEffected = await db
        .delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ?", whereArgs: ['$sno']);

    return rowsEffected > 0;
  }
}
