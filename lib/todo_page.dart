import 'package:flutter/material.dart';

import 'todo_repository.dart';

/// A local to-do list backed by SQLite.
///
/// CRUD mapping:
/// - Tap "+"            -> INSERT a new to-do
/// - Tap a to-do        -> UPDATE its title (edit dialog)
/// - Tap the checkbox   -> UPDATE done/undone
/// - Swipe left/right   -> DELETE
class TodoPage extends StatefulWidget {
  const TodoPage({super.key, this.repository});

  final TodoRepository? repository;

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late final TodoRepository _repo;
  List<Todo> _todos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? SqfliteTodoRepository();
    _refresh();
  }

  Future<void> _refresh() async {
    final todos = await _repo.getAll();
    if (mounted) {
      setState(() {
        _todos = todos;
        _loading = false;
      });
    }
  }

  Future<String?> _showTitleDialog({String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial.isEmpty ? 'Add To-Do' : 'Edit To-Do'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'What needs to be done?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final title = await _showTitleDialog();
    if (title == null || title.isEmpty) return;
    await _repo.add(Todo(title: title));
    await _refresh();
  }

  Future<void> _edit(Todo todo) async {
    final title = await _showTitleDialog(initial: todo.title);
    if (title == null || title.isEmpty || title == todo.title) return;
    await _repo.update(todo.copyWith(title: title));
    await _refresh();
  }

  Future<void> _toggle(Todo todo) async {
    await _repo.update(todo.copyWith(isDone: !todo.isDone));
    await _refresh();
  }

  Future<void> _delete(Todo todo) async {
    await _repo.delete(todo);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My To-Do List')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        tooltip: 'Add to-do',
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _todos.isEmpty
              ? const Center(
                  child: Text('No to-dos yet. Tap + to add one.'),
                )
              : ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    final todo = _todos[index];
                    return Dismissible(
                      key: ValueKey(todo.id),
                      direction: DismissDirection.horizontal,
                      onDismissed: (_) => _delete(todo),
                      background: Container(
                        color: Theme.of(context).colorScheme.error,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: CheckboxListTile(
                        value: todo.isDone,
                        onChanged: (_) => _toggle(todo),
                        title: GestureDetector(
                          onTap: () => _edit(todo),
                          child: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isDone ? Colors.grey : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
