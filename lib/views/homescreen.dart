import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/add_expense.dart';
import 'package:flutter_application_1/views/expenses_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const DashboardPage(),
    const AddExpense(),
    const ExpensesList(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.blueAccent,
        items: const <Widget>[
          Icon(Icons.dashboard, size: 30),
          Icon(Icons.add, size: 30),
          Icon(Icons.list, size: 30),
          Icon(Icons.person, size: 30),
        ],

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Expense Dashboard",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text("Total Expenses"),
              subtitle: const Text("Ksh 3500"),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              title: const Text("Food"),
              trailing: const Text("Ksh 1200"),
            ),
          ),

          Card(
            child: ListTile(
              title: const Text("Transport"),
              trailing: const Text("Ksh 800"),
            ),
          ),

          Card(
            child: ListTile(
              title: const Text("Shopping"),
              trailing: const Text("Ksh 1500"),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("User Profile", style: TextStyle(fontSize: 22)),
    );
  }
}
