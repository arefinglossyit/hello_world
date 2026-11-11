import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class Todo {
  final int? id;
  final String title;
  final bool isDone;

  const Todo({this.id, required this.title, this.isDone = false});

  Todo copyWith({int? id, String? title, bool? isDone}) => Todo(
        id: id ?? this.id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'isDone': isDone ? 1 : 0,
      };

  factory Todo.fromMap(Map<String, Object?> map) => Todo(
        id: map['id'] as int?,
        title: map['title'] as String,
        isDone: (map['isDone'] as int? ?? 0) == 1,
      );
}

abstract class TodoRepository {
  Future<List<Todo>> getAll();
  Future<Todo> add(Todo todo);
  Future<void> update(Todo todo);
  Future<void> delete(Todo todo);
}

/// Stores to-dos in a local SQLite database on the device.
class SqfliteTodoRepository implements TodoRepository {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      p.join(await getDatabasesPath(), 'todos.db'),
      version: 1,
      onCreate: (db, _) => db.execute(
        'CREATE TABLE todos('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'title TEXT NOT NULL, '
        'isDone INTEGER NOT NULL DEFAULT 0)',
      ),
    );
    return _db!;
  }

  @override
  Future<List<Todo>> getAll() async {
    final rows = await (await database).query('todos', orderBy: 'id DESC');
    return rows.map(Todo.fromMap).toList();
  }

  @override
  Future<Todo> add(Todo todo) async {
    final id = await (await database)
        .insert('todos', todo.toMap()..remove('id'));
    return todo.copyWith(id: id);
  }

  @override
  Future<void> update(Todo todo) async {
    await (await database)
        .update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  @override
  Future<void> delete(Todo todo) async {
    await (await database)
        .delete('todos', where: 'id = ?', whereArgs: [todo.id]);
  }
}

/// Simple in-memory implementation used in widget tests.
class InMemoryTodoRepository implements TodoRepository {
  final _todos = <Todo>[];
  int _nextId = 1;

  @override
  Future<List<Todo>> getAll() async => List.of(_todos);

  @override
  Future<Todo> add(Todo todo) async {
    final added = todo.copyWith(id: _nextId++);
    _todos.insert(0, added);
    return added;
  }

  @override
  Future<void> update(Todo todo) async {
    final i = _todos.indexWhere((t) => t.id == todo.id);
    if (i >= 0) _todos[i] = todo;
  }

  @override
  Future<void> delete(Todo todo) async {
    _todos.removeWhere((t) => t.id == todo.id);
  }
}
