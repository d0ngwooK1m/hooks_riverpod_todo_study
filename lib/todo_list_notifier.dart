import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@immutable
class Todo {
  final String id;
  final String description;
  final bool done;

  const Todo({
    required this.id,
    required this.description,
    required this.done,
  });
}

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier(List<Todo>? initialTodos) : super(initialTodos ?? []);

  void add(String description) {
    state = [
      ...state,
      Todo(
        id: _uuid.v4(),
        description: description,
        done: false,
      ),
    ];
  }

  void delete(String id) {
    state = [
      for (final todo in state)
        if (todo.id != id) todo
    ];
  }

  void edit({required String id, required String desc}) {
    print('this is state ${state[0].id}, $id');
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            description: desc,
            done: todo.done,
          )
        else
          todo
    ];
  }

  void done(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            description: todo.description,
            done: !todo.done,
          )
      else
        todo
    ];
  }
}
