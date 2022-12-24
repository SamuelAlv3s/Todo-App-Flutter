import 'dart:convert';

import 'package:first_app/models/item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = <Item>[];

  HomePage({super.key}) {
    items = [];
    // items.add(Item(title: "Item 1", done: true));
    // items.add(Item(title: "Item 2", done: false));
    // items.add(Item(title: "Item 3", done: true));
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  _HomePageState() {
    load();
  }

  void add() {
    if (newTaskController.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskController.text, done: false));
      newTaskController.text = "";
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  Future save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: const InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(color: Colors.white)),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return Dismissible(
            key: Key(item.title),
            background: Container(color: Colors.red.withOpacity(0.2)),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                remove(index);
              }
            },
            child: CheckboxListTile(
                title: Text(item.title),
                value: item.done,
                onChanged: (value) {
                  setState(() {
                    item.done = value as bool;
                    save();
                  });
                }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}
