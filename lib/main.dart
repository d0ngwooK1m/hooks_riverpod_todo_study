import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'todo_list_notifier.dart';

final todoListNotifierProvider =
StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
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
    final todoList = ref.watch(todoListNotifierProvider);
    final textController = useTextEditingController();
    return Scaffold(
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
          const SizedBox(height: 20.0,),
          for (var i = 0; i < todoList.length; i++) ...[
            if(i > 0) const SizedBox(height: 10.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(value: false, onChanged: (value) {}),
                  Expanded(
                    child: Text(
                      todoList[i].description,
                      style: const TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                  IconButton(onPressed: () {
                    ref.read(todoListNotifierProvider.notifier).delete(todoList[i].id);
                  }, icon: const Icon(Icons.delete))
                ],
              ),
            )
          ],
        ],
      ),
    );
  }
}




