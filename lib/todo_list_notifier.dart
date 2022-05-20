import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@immutable
class Todo {
  final String id;
  final String description;

  const Todo({
    required this.id,
    required this.description,
  });
}

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier([List<Todo>? initialTodos]) : super(initialTodos ?? []);

  void add(String description) {
    state = [
      ...state,
      Todo(id: _uuid.v4(), description: description),
    ];
  }

  void delete(String id) {
    state = [
      for (var todo in state)
        if (todo.id != id)
          todo
    ];
  }
}