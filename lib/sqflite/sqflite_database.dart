import 'dart:io';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:english_words/english_words.dart' as english_words;
import 'components/todo_item.dart';

class SqfliteDatabase extends StatefulWidget {
  const SqfliteDatabase({Key? key}) : super(key: key);

  @override
  State<SqfliteDatabase> createState() => _SqfliteDatabaseState();
}

class _SqfliteDatabaseState extends State<SqfliteDatabase> {
  static const kDvFileName = "sqflite_ex.db";
  static const kDbTableName = "example_tbl";
  static const kDbTableDeneme = "deneme_tbl";
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  late Database _db;
  List<TodoItem> _todos = [];

//-----------veritabanı oluşturma --------------------------------
  Future<void> initDb() async {
    final dbFolder = await getDatabasesPath();
    if (!await Directory(dbFolder).exists()) {
      await Directory(dbFolder).create(recursive: true);
    }
    final dbPath = join(dbFolder, kDvFileName);
    this._db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE $kDbTableName (id INTEGER PRIMARY KEY, isDone BIT NOT NULL, content TEXT, createdAt INT)');
        await db.execute(
            'CREATE TABLE $kDbTableDeneme (id INTEGER PRIMARY KEY, isDone BIT NOT NULL, content TEXT, createdAt INT)');
      },
    );
  }

//-------------veritabanından veri getirme------------------------------
  Future<void> getTodoItems() async {
    final List<Map<String, dynamic>> jsons =
      await this._db.rawQuery('SELECT * FROM $kDbTableName');
    print('${jsons.length} rows retrieved from db! ');
    this._todos = jsons.map((json) => TodoItem.fromJsonMap(json)).toList();
    print('hfgdfgd rows retrieved from db! ');
  }

  //---------------veritabanına veri ekleme----------------------------------

  Future<void> addTodoItem(TodoItem todo) async {
    await this._db.transaction((Transaction txn) async {
      final int id = await txn.rawInsert(
          'INSERT INTO $kDbTableName(content,isDone,createdAt) VALUES("${todo
              .content}", ${todo.isDone ? 1 : 0}, ${todo.createdAt
              .millisecondsSinceEpoch})');
      print("Inserted todo item with id=$id");
    });
  }

  Future<void> toogleTodoItem(TodoItem todo) async {
    final int count =
        await this._db.rawUpdate('UPDATE ${kDbTableName} SET ${todo.isDone},WHERE ${todo.id} ');


        /*await this._db.rawUpdate([if (todo.isDone) 0 else 1, todo.id]);*/
  }


  //--------------veritabanından veri silme-------------------------
  Future<void> deleteTodoItem(TodoItem todo) async {
    final count = await this
        ._db
        .rawDelete('DELETE FROM $kDbTableName WHERE id=${todo.id}');
    print("Update $count records in .db ");
  }


  Future<bool> _asyncInit() async {
    await _memoizer.runOnce(() async {
      await initDb();
      await getTodoItems();
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _asyncInit(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == false) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            children: this._todos.map(_itemToListTile).toList(),
          ),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  Future<void> _updateUI() async {
    await getTodoItems();
    setState(() {});
  }

  ListTile _itemToListTile(TodoItem todo) =>
      ListTile(
        title: Text(
          todo.content,
          style: TextStyle(
            fontStyle: todo.isDone ? FontStyle.italic : null,
            color: todo.isDone ? Colors.grey : null,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('id=${todo.id}\ncreated at ${todo.createdAt}'),
        isThreeLine: true,
        leading: IconButton(
          icon: Icon(
            todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          ),
          onPressed: () async {
            await toogleTodoItem(todo);
            _updateUI();
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await deleteTodoItem(todo);
            _updateUI();
          },
        ),
      );

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        await addTodoItem(
          TodoItem(
            content: "asdag",
            createdAt: DateTime.now(),
          ),
        );
        _updateUI();
      },
      child: const Icon(Icons.add),
    );
  }
}