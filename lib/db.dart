import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'main.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'events_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        Create Table events(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          photoUrl TEXT,
          date TEXT
          )
          ''');
      },
    );
  }

  Future<int> insertEvent(Event event) async {
    Database db = await instance.database;
    return await db.insert('events', event.toMap());
  }

  Future<List<Event>> getAllEvents() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return Event(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        imageFile: maps[i]['photoUrl'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  Future<void> deleteAllEvents() async {
    Database db = await instance.database;
    await db.delete('events');
  }
}
