import 'dart:async';
import '../data/todo.dart';
import '../data/todo_db.dart';

class TodoBloc {
  // Creating an instance of database helper class
  late TodoDb db;
  List<Todo> todoList = [];

  // Stream controllers create a linked 'Stream' and 'StreamSink'. You can
  // think of them as a pipe where 'StreamSink' represents data to be
  // passed through the stream controller (pipe) and 'Stream' represents
  // data emitted from it. When using a BLoC, everything is a stream of
  // events. The BLoC receives streams of events/data from the source,
  // handles any required business logic, and publishes streams of data.

  // Creating a 'StreamController' for handling list of 'Todo's
  // This named constructor creates a stream controller where the stream
  // can be listened to more than once.
  final _todosStreamController = StreamController<List<Todo>>.broadcast();

  // Creating stream controllers for performing actions on todos
  final _todoInsertController = StreamController<Todo>();
  final _todoUpdateController = StreamController<Todo>();
  final _todoDeleteController = StreamController<Todo>();

  TodoBloc() {
    db = TodoDb();
    getTodos();
    // Listening to changes:
    _todosStreamController.stream.listen(returnTodos);
    _todoInsertController.stream.listen(_addTodo);
    _todoUpdateController.stream.listen(_updateTodo);
    _todoDeleteController.stream.listen(_deleteTodo);
  }

  Stream<List<Todo>> get todos => _todosStreamController.stream;
  StreamSink<List<Todo>> get todosSink => _todosStreamController.sink;
  StreamSink<Todo> get todoInsertSink => _todoInsertController.sink;
  StreamSink<Todo> get todoUpdateSink => _todoUpdateController.sink;
  StreamSink<Todo> get todoDeleteSink => _todoDeleteController.sink;

  // Retrieving todos from the sembast (document based) database
  Future getTodos() async {
    List<Todo> todos = await db.getTodos();
    todoList = todos;
    todosSink.add(todos);
  }

  List<Todo> returnTodos(todos) {
    return todos;
  }

  void _deleteTodo(Todo todo) {
    db.deleteTodo(todo).then((value) => getTodos());
  }

  void _updateTodo(Todo todo) {
    db.updateTodo(todo).then((value) => getTodos());
  }

  void _addTodo(Todo todo) {
    db.insertTodo(todo).then((value) => getTodos());
  }

  // in the dispose method, we need to close the stream controllers
  void dispose() {
    _todosStreamController.close();
    _todoInsertController.close();
    _todoUpdateController.close();
    _todoDeleteController.close();
  }
}
