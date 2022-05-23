import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'todo_list_notifier.dart';

final todoListNotifierProvider =
    StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier(const []);
});

enum TodoFilter { all, done, yet }

final todoFilterProvider = StateProvider((ref) => TodoFilter.all);

final filteredTodoList = Provider((ref) {
  final todoList = ref.watch(todoListNotifierProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.done:
      return todoList.where((todo) => todo.done).toList();
    case TodoFilter.yet:
      return todoList.where((todo) => !todo.done).toList();
    default:
      return todoList;
  }
});

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MaterialApp(home: Home()),
    );
  }
}

class Home extends HookConsumerWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoList = ref.watch(filteredTodoList);
    final textController = useTextEditingController();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          children: [
            TextField(
              controller: textController,
              onSubmitted: (value) {
                ref.read(todoListNotifierProvider.notifier).add(value);
                textController.clear();
              },
            ),
            const FilterTab(),
            const SizedBox(height: 20.0),
            if (todoList.isEmpty)
              const Text(
                "Let's make new Todo!",
                style: TextStyle(
                  fontSize: 30.0,
                ),
              )
            else
              for (var i = 0; i < todoList.length; i++) ...[
                if (i > 0) const SizedBox(height: 10.0),
                ProviderScope(
                  overrides: [
                    _currentTodo.overrideWithValue(todoList[i]),
                  ],
                  child: const TodoItem(),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class FilterTab extends HookConsumerWidget {
  const FilterTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoFilterProvider);

    Color? textColorFor(TodoFilter value) {
      if (value == filter) {
        return Colors.blue;
      } else {
        return Colors.black;
      }
    }

    return Row(
      children: [
        TextButton(
          onPressed: () {
            ref.read(todoFilterProvider.notifier).state = TodoFilter.all;
          },
          style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all(textColorFor(TodoFilter.all)),
          ),
          child: const Text('ALL'),
        ),
        TextButton(
            onPressed: () {
              ref.read(todoFilterProvider.notifier).state = TodoFilter.done;
            },
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(textColorFor(TodoFilter.done)),
            ),
            child: const Text('DONE')),
        TextButton(
            onPressed: () {
              ref.read(todoFilterProvider.notifier).state = TodoFilter.yet;
            },
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(textColorFor(TodoFilter.yet)),
            ),
            child: const Text('YET')),
      ],
    );
  }
}

final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

class TodoItem extends HookConsumerWidget {
  const TodoItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);
    final itemFocusNode = useFocusNode();
    final itemIsFocus = useIsFocused(itemFocusNode);

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Focus(
      focusNode: itemFocusNode,
      onFocusChange: (focused) {
        if (!focused) {
          textEditingController.text = todo.description;
        } else {
          ref
              .read(todoListNotifierProvider.notifier)
              .edit(id: todo.id, desc: textEditingController.text);
        }
      },
      child: ListTile(
        onTap: () {
          itemFocusNode.requestFocus();
          textFieldFocusNode.requestFocus();
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
                value: todo.done,
                onChanged: (value) {
                  ref.read(todoListNotifierProvider.notifier).done(todo.id);
                }),
            const SizedBox(width: 20.0),
            Expanded(
              child: itemIsFocus
                  ? TextField(
                      autofocus: true,
                      focusNode: textFieldFocusNode,
                      onSubmitted: (value) {
                        ref
                            .read(todoListNotifierProvider.notifier)
                            .edit(id: todo.id, desc: value);
                      },
                      style: const TextStyle(
                        fontSize: 30.0,
                      ),
                    )
                  : Text(
                      todo.description,
                      style: const TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
            ),
            IconButton(
                onPressed: () {
                  ref.read(todoListNotifierProvider.notifier).delete(todo.id);
                },
                icon: const Icon(Icons.delete))
          ],
        ),
      ),
    );
  }
}

bool useIsFocused(FocusNode node) {
  final isFocused = useState(node.hasFocus);

  useEffect(() {
    void listener() {
      isFocused.value = node.hasFocus;
    }

    node.addListener(listener);
    return () {
      node.removeListener(listener);
    };
  }, [node]);

  return isFocused.value;
}
