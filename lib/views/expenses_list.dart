import 'package:flutter/material.dart';

class ExpensesList extends StatefulWidget {
  const ExpensesList({super.key});

  @override
  State<ExpensesList> createState() => _ExpensesListState();
}

class _ExpensesListState extends State<ExpensesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses List")),
      body: ListView(
        children: const [
          ListTile(title: Text("Food"), trailing: Text("Ksh 300")),
          ListTile(title: Text("Transport"), trailing: Text("Ksh 200")),
          ListTile(title: Text("Shopping"), trailing: Text("Ksh 500")),
        ],
      ),
    );
  }
}
