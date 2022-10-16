import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'sambast_lite/sambast_database.dart';
import 'sqflite/sqflite_database.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Database Example"),
          actions: const [
            Icon(Icons.info),
            SizedBox(
              width: 10,
            )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 350,
                color: Colors.blue,
                child: TextButton(
                  child: const Text(
                    "Sqflite Example",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SqfliteDatabase()),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 350,
                color: Colors.blue,
                child: TextButton(
                  child: const Text(
                    "Sambast Example",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SambastDatabase()),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
