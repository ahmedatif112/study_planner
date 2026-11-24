import 'package:flutter/material.dart';

import 'database_helper.dart';

// LOGIC: App start, initialise the database before the app runs
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initDatabase();
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

// STATIC: Reusable card widget, used three times in the summary row
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// STATIC: Home screen is a StatefulWidget so the UI can change
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // LOGIC: List of goals, each Map holds id, subject, hours, done
  final List<Map<String, dynamic>> _goals = [];

  // LOGIC: Load saved goals when the screen opens
  // (initState cannot be async, so it calls a separate async function)
  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  // LOGIC: Read all goals from the database and show them on screen
  Future<void> _loadGoals() async {
    final saved = await DatabaseHelper.getGoals();
    if (!mounted) return;
    setState(() {
      _goals.clear();
      _goals.addAll(saved);
    });
  }

  // LOGIC: Total hours of all goals (fold starts from 0 and adds each goal)
  int get _totalHours =>
      _goals.fold<int>(0, (sum, goal) => sum + (goal['hours'] as int));

  // LOGIC: Number of completed goals (where filters, length counts)
  int get _completedCount =>
      _goals.where((goal) => goal['done'] == true).length;

  // LOGIC: Number of goals still to do
  int get _remainingCount => _goals.length - _completedCount;

  // LOGIC: Open the Add Goal screen, wait for the result, then save it
  Future<void> _openAddGoalScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );

    // LOGIC: Ignore the result if the user pressed back (result is null)
    if (result == null) return;

    // LOGIC: Insert into the database, then store the returned id in the list
    final int newId = await DatabaseHelper.insertGoal(result);
    result['id'] = newId;

    if (!mounted) return;
    setState(() {
      _goals.add(result);
    });
  }

  // LOGIC: Flip the done value in the database and on screen
  Future<void> _toggleGoal(int index) async {
    final int id = _goals[index]['id'];
    final bool newDone = !_goals[index]['done'];

    await DatabaseHelper.updateGoal(id, newDone);

    if (!mounted) return;
    setState(() {
      _goals[index]['done'] = newDone;
    });
  }

  // LOGIC: Remove the goal from the database and from the screen
  Future<void> _deleteGoal(int index) async {
    final int id = _goals[index]['id'];

    await DatabaseHelper.deleteGoal(id);

    if (!mounted) return;
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

      // STATIC: Body block (summary row + heading + list)
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATIC: Summary row, three cards share the width evenly
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total hours',
                    // CONNECTION 1: UI reads values from LOGIC getters
                    value: '$_totalHours',
                    icon: Icons.schedule,
                    color: Colors.indigo,
                  ),
                ),
                Expanded(
                  child: SummaryCard(
                    title: 'Completed goals',
                    value: '$_completedCount',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: SummaryCard(
                    title: 'Remaining goals',
                    value: '$_remainingCount',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // STATIC: Heading above the list
            const Text(
              'My Study Goals',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // STATIC: Empty message or the goal list
            Expanded(
              child: _goals.isEmpty
                  // STATIC: Friendly message when the list is empty
                  ? const Center(
                      child: Text(
                        'No goals yet. Tap + to add your first goal!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  // STATIC: Scrollable list built from the data
                  : ListView.builder(
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        final goal = _goals[index];
                        final bool isDone = goal['done'];

                        // STATIC: One goal card
                        return Card(
                          child: ListTile(
                            // CONNECTION 2: UI calls LOGIC functions on actions
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

      // STATIC: Floating action button opens the Add Goal screen
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddGoalScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// STATIC: Second screen where the user types a new goal
class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  // LOGIC: Controllers read the text typed in the two fields
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  // LOGIC: Error messages shown under the fields (null means no error)
  String? _subjectError;
  String? _hoursError;

  // LOGIC: Free the controllers when the screen closes
  @override
  void dispose() {
    _subjectController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  // LOGIC: Validate the input, then send the new goal back with pop
  void _saveGoal() {
    final String subject = _subjectController.text.trim();
    final int? hours = int.tryParse(_hoursController.text.trim());

    // LOGIC: Subject must not be empty
    final String? subjectError = subject.isEmpty
        ? 'Subject must not be empty'
        : null;

    // LOGIC: Hours must be a number greater than 0
    final String? hoursError = (hours == null || hours <= 0)
        ? 'Hours must be a number greater than 0'
        : null;

    setState(() {
      _subjectError = subjectError;
      _hoursError = hoursError;
    });

    // LOGIC: Stop here if anything is invalid
    if (subjectError != null || hoursError != null) return;

    // CONNECTION 3: Return the new goal to the first screen
    Navigator.pop(context, {'subject': subject, 'hours': hours, 'done': false});
  }

  @override
  Widget build(BuildContext context) {
    // STATIC: Scaffold gives the page structure
    return Scaffold(
      // STATIC: AppBar with the screen title and a back button
      appBar: AppBar(
        title: const Text('Add Goal'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),

      // STATIC: Form block (two fields and a Save button)
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // STATIC: Subject text field
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                prefixIcon: const Icon(Icons.menu_book),
                border: const OutlineInputBorder(),
                errorText: _subjectError,
              ),
            ),
            const SizedBox(height: 16),

            // STATIC: Hours text field (number keyboard)
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Hours',
                prefixIcon: const Icon(Icons.schedule),
                border: const OutlineInputBorder(),
                errorText: _hoursError,
              ),
            ),
            const SizedBox(height: 24),

            // STATIC: Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveGoal,
                icon: const Icon(Icons.save),
                label: const Text('Save Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
