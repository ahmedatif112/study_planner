import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// STATIC: Root widget of the app (MaterialApp with theme)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Study Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// STATIC: Home screen (StatelessWidget, fixed content only)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // STATIC: Scaffold gives the page structure
    return Scaffold(
      // STATIC: AppBar with the app title
      appBar: AppBar(
        title: const Text('My Study Planner'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),

      // STATIC: Body block (heading + list of goal cards)
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATIC: Heading above the list
            const Text(
              'My Study Goals',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // STATIC: Goal card 1 (hard-coded)
            const Card(
              child: ListTile(
                leading: Icon(Icons.menu_book),
                title: Text('Mathematics'),
                subtitle: Text('3 hours'),
              ),
            ),

            // STATIC: Goal card 2 (hard-coded)
            const Card(
              child: ListTile(
                leading: Icon(Icons.code),
                title: Text('Flutter Programming'),
                subtitle: Text('5 hours'),
              ),
            ),

            // STATIC: Goal card 3 (hard-coded)
            const Card(
              child: ListTile(
                leading: Icon(Icons.science),
                title: Text('Physics'),
                subtitle: Text('2 hours'),
              ),
            ),
          ],
        ),
      ),

      // STATIC: Floating action button (does nothing yet)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}