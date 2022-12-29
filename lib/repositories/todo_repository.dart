import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoRepository{

  static const todoListKey = 'todo_list';


  TodoRepository(){
    SharedPreferences.getInstance().then((value){
      sharedPreferences = value;
      print(sharedPreferences.get(todoListKey));
    });
  }

  late SharedPreferences sharedPreferences;

  void saveTodoList(List<Todo> todos){
    final String jsonSring = json.encode(todos);
    print(jsonSring);
    sharedPreferences.setString( todoListKey , jsonSring);
  }

  Future<List<Todo>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecode = json.decode(jsonString) as List;
    return jsonDecode.map((e) => Todo.fromJson(e)).toList();
  }

}