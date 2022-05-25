import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
// Sembast (simple embedded application store database) is a document-based
// database that resides in a single file. It is loaded in memory when you
// open it from the app, and it's very efficient, as the file is automatically
// compacted when needed. Data is stored in JSON format, with key-value pairs.
// You can even encrypt data if your app requires it.
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'todo.dart';

class TodoDb {
  // private internal constructor
  TodoDb._internal();

  // this needs to be a singleton
  static final TodoDb _singleton = TodoDb._internal();

  // A normal constructor returns a new instance of the current class.
  // A factory constructor can only return a single instance of the
  // current class: that's why factory constructors are often used when
  // you need to implement the singleton pattern.
  factory TodoDb() {
    return _singleton;
  }

  // Creating an instance of database factory for accessing databases
  DatabaseFactory dbFactory = databaseFactoryIo;
  // Creating a store reference for holding a database
  final store = intMapStoreFactory.store('todos');
  // Creating an instance of a sembast (simple embedded application store databse)
  Database? _database;

  // Retrieving the database. This gets a new or existing database.
  Future<Database?> get database async {
    if (_database == null) {
      await _openDb().then((db) {
        _database = db;
      });
    }
    return _database;
  }

  // Opening the database from the specific path
  Future _openDb() async {
    final docsPath = await getApplicationDocumentsDirectory();
    final dbPath = join(docsPath.path, 'todos.db');
    final db = await dbFactory.openDatabase(dbPath);
    return db;
  }

  // This adds a record, and return its generated key
  Future insertTodo(Todo todo) async {
    await store.add(_database!, todo.toMap());
  }

  // This updates records matching a given finder
  Future updateTodo(Todo todo) async {
    // Finder is a helper for searching a given store
    final finder = Finder(filter: Filter.byKey(todo.id));
    await store.update(_database!, todo.toMap(), finder: finder);
  }

  // This deletes records matching a given finder
  Future deleteTodo(Todo todo) async {
    final finder = Finder(filter: Filter.byKey(todo.id));
    await store.delete(_database!, finder: finder);
  }

  Future deleteAll() async {
    // Clears all records from the store
    await store.delete(_database!);
  }

  // Retrieves all the todos from the database
  Future<List<Todo>> getTodos() async {
    await database;
    final finder = Finder(sortOrders: [
      SortOrder('priority'),
      SortOrder('id'),
    ]);

    final todosSnapshot = await store.find(_database!, finder: finder);

    return todosSnapshot.map((snapshot) {
      final todo = Todo.fromMap(snapshot.value);
      // the id is automatically generated
      todo.id = snapshot.key;
      return todo;
    }).toList();
  }
}
