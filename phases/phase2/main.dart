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

// STATIC: Home screen is now a StatefulWidget so the UI can change
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // LOGIC: List of goals, each goal is a Map with subject, hours, done
  final List<Map<String, dynamic>> _goals = [
    {'subject': 'Mathematics', 'hours': 3, 'done': false},
    {'subject': 'Flutter Programming', 'hours': 5, 'done': false},
    {'subject': 'Physics', 'hours': 2, 'done': false},
  ];

  // LOGIC: Sample subjects used by the + button for now
  final List<String> _sampleSubjects = [
    'Chemistry',
    'History',
    'Biology',
    'English',
    'Databases',
  ];

  // LOGIC: Counter used to pick the next sample subject
  int _sampleIndex = 0;

  // LOGIC: Add a sample goal to the list
  void _addSampleGoal() {
    setState(() {
      _goals.add({
        'subject': _sampleSubjects[_sampleIndex % _sampleSubjects.length],
        'hours': (_sampleIndex % 4) + 1,
        'done': false,
      });
      _sampleIndex++;
    });
  }

  // LOGIC: Flip the done value of the goal at this index
  void _toggleGoal(int index) {
    setState(() {
      _goals[index]['done'] = !_goals[index]['done'];
    });
  }

  // LOGIC: Remove the goal at this index
  void _deleteGoal(int index) {
    setState(() {
      _goals.removeAt(index);
    });
  }

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

      // STATIC: Body block (heading + list)
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

            // STATIC: Scrollable list built from the data
            Expanded(
              child: ListView.builder(
                // CONNECTION 1: UI reads its data from the LOGIC list
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final bool isDone = goal['done'];

                  // STATIC: One goal card
                  return Card(
                    child: ListTile(
                      // CONNECTION 2: UI calls LOGIC functions on user actions
                      onTap: () => _toggleGoal(index),
                      leading: Checkbox(
                        value: isDone,
                        onChanged: (value) => _toggleGoal(index),
                      ),
                      title: Text(
                        goal['subject'],
                        style: TextStyle(
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isDone ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Text('${goal['hours']} hours'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGoal(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // STATIC: Floating action button adds a sample goal for now
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleGoal,
        child: const Icon(Icons.add),
      ),
    );
  }
}