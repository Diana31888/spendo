// DBHelper - manages all SQLite database operations
// uses singleton pattern so only one DB connection exists in the app

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  // returns existing DB or creates a new one on first launch
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendo.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // creates the expenses table the first time the app runs
  Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      category TEXT NOT NULL,
      date TEXT NOT NULL,
      currency TEXT NOT NULL DEFAULT 'TRY'
    )
  ''');
}

  // INSERT - save a new expense to the database
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  // READ - get all expenses, newest first
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((row) => Expense.fromMap(row)).toList();
  }

  // READ - get only this month's expenses (for home screen summary)
  Future<List<Expense>> getMonthlyExpenses(String yearMonth) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'date LIKE ?',
      whereArgs: ['$yearMonth%'],
      orderBy: 'date DESC',
    );
    return result.map((row) => Expense.fromMap(row)).toList();
  }

  // DELETE - remove an expense by id
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // UPDATE - edit an existing expense
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }
}