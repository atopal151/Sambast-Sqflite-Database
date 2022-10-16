import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'components/todo_Item.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class SambastDatabase extends StatefulWidget {
  const SambastDatabase({Key? key}) : super(key: key);

  @override
  State<SambastDatabase> createState() => _SambastDatabaseState();
}

class _SambastDatabaseState extends State<SambastDatabase> {
  static const kDbFileName = 'sembast_ex.db';
  static const kDbStoreName = 'example_store';


  late Future<bool> _initDbFuture;
  late Database _db;
  late StoreRef<int, Map<String, dynamic>> _store;
  List<TodoItem> _todos = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._initDbFuture=_initDb();
  }

  Future<bool> _initDb() async {
    final dbFolder = await path_provider.getApplicationDocumentsDirectory();
    final dbPath = join(dbFolder.path, kDbFileName);
    this._db = await databaseFactoryIo.openDatabase(dbPath);
    print('Db created at $dbPath');
    this._store = intMapStoreFactory.store(kDbStoreName);
    _getTodoItems();
    return true;
  }

  Future<void> _getTodoItems() async {
    final finder = Finder();
    final recordSnapshots = await this._store.find(this._db, finder: finder);
    this._todos = recordSnapshots
        .map(
          (snapshots) => TodoItem.fromJsonMap({
        ...snapshots.value,
        'id': snapshots.key,
      }),
    )
        .toList();
  }

  Future<void> _addTodoItem(TodoItem todo) async {
    final int id = await this._store.add(this._db, todo.toJsonMap());
    print("Inserted todo item with id= $id");
  }

  Future<void> _toggleTodoItem(TodoItem todo) async {
    todo.isDone = !todo.isDone;
    final int count = await this._store.update(
      this._db,
      todo.toJsonMap(),
      finder: Finder(filter: Filter.byKey(todo.id)),
    );
    print("Updated $count records in db.");
  }

  Future<void> _deleteTodoItem(TodoItem todo) async {
    final int count = await this._store.delete(
      this._db,
      finder: Finder(filter: Filter.byKey(todo.id)),
    );
    print("Updated $count records in db.");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: this._initDbFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text("Sembast Database Example"),
          ),
          body: ListView(
            children: this._todos.map(_itemToListTile).toList(),
          ),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  Future<void> _updateUI() async {
    await _getTodoItems();
    setState(() {});
  }

  ListTile _itemToListTile(TodoItem todo) {
    return ListTile(
      title: Text(
        todo.content,
        style: TextStyle(
          fontStyle: todo.isDone ? FontStyle.italic : null,
          color: todo.isDone ? Colors.grey : null,
          decoration: todo.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text("id=${todo.id}\n created at ${todo.createdAt}"),
      isThreeLine: true,
      leading: IconButton(
        icon: Icon(
          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
        ),
        onPressed: () async {
          await _toggleTodoItem(todo);
          _updateUI();
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await _deleteTodoItem(todo);
          _updateUI();
        },
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        await _addTodoItem(
          TodoItem(
            content: "asdasdgggghjj",
            createdAt: DateTime.now(),
          ),
        );
        _updateUI();
      },
      child: const Icon(Icons.add),
    );
  }
}
