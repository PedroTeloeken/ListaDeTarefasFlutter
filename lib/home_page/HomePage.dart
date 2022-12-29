import 'package:flutter/material.dart';
import 'package:list_of_tasks_git/models/todo.dart';
import 'package:list_of_tasks_git/repositories/todo_repository.dart';
import 'package:list_of_tasks_git/widgets/todo_list_itens.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;
  String? errorText;
  TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff00d7f3),
          title: const Text("Lista de Tarefa"),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: todoController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: "Adicione uma tarfefa",
                            hintText: "Ex: Estudar para a prova",
                            errorText: errorText,
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff00d7f3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String text = todoController.text;

                          if (text.isEmpty) {
                            setState(() {
                              errorText = "A terefa não pode ser vazia";
                            });
                            return;
                          }

                          setState(() {
                            String title = todoController.text;
                            DateTime datetime = DateTime.now();
                            Todo newTodo = Todo(title: title, dateTime: datetime);
                            todos.add(newTodo);
                            errorText = null;
                          });
                          todoController.clear();
                          todoRepository.saveTodoList(todos);
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(14),
                            primary: const Color(0xff00d7f3)),
                        child: const Icon(
                          Icons.add,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text("Você possui 0 tarefas pendentes "),
                    ),
                    ElevatedButton(
                      onPressed: showDeleteAllTodos,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(14),
                          primary: const Color(0xff00d7f3)),
                      child: const Text("Limpar tudo"),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
      todoRepository.saveTodoList(todos);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          "Tarefa ${todo.title} foi removida com sucesso!",
          style: const TextStyle(
            color: Color(0xff00d7f3),
          ),
        ),
        action: SnackBarAction(
            label: "Desfazer?",
            textColor: const Color(0xff00d7f3),
            onPressed: () {
              setState(() {
                todos.insert(deletedTodoPos!, deletedTodo!);
              });
              todoRepository.saveTodoList(todos);
            }),
      ),
    );
  }

  void showDeleteAllTodos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Tudo?'),
        content: const Text('Você tem certeza que deseja apagar tudo?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                todos.clear();
                Navigator.of(context).pop();
                todoRepository.saveTodoList(todos);
              });
            },
            style: TextButton.styleFrom(
              primary: Colors.red,
            ),
            child: const Text(
              'Excluir tudo',
            ),
          ),
        ],
      ),
    );
  }
}
