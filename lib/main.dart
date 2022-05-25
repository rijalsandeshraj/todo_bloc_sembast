import 'package:flutter/material.dart';
import 'todo_screen.dart';
import 'data/todo.dart';
import 'bloc/todo_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todos BLoC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TodoBloc todoBloc;
  late List<Todo> todos;

  @override
  void initState() {
    todoBloc = TodoBloc();
    todos = todoBloc.todoList;
    super.initState();
  }

  @override
  void dispose() {
    todoBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Todo todo = Todo(
      name: '',
      description: '',
      completeBy: '',
      priority: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: StreamBuilder<List<Todo>>(
        stream: todoBloc.todos,
        initialData: todos,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ListView.builder(
              itemCount: snapshot.hasData ? snapshot.data.length : 0,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(snapshot.data[index].id.toString()),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (_) =>
                      todoBloc.todoDeleteSink.add(snapshot.data[index]),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).highlightColor,
                      child: Text('${snapshot.data[index].priority}'),
                    ),
                    title: Text('${snapshot.data[index].name}'),
                    subtitle: Text('${snapshot.data[index].description}'),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TodoScreen(snapshot.data[index], false)));
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TodoScreen(todo, true)));
        },
      ),
    );
  }
}
