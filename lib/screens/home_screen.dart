import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import '../screens/task_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _sortOption = 'Due Date';
  String _filterOption = 'All';

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearch(tasks: taskProvider.tasks),
              );
            },
          ),
        ],
      ),
      body: _buildTaskList(taskProvider.tasks),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TaskScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
              ),
            ),
            _buildDrawerItem(
              icon: Icons.list,
              title: 'All Tasks',
              onTap: () => _updateFilter('All'),
            ),
            _buildDrawerItem(
              icon: Icons.check_circle,
              title: 'Completed',
              onTap: () => _updateFilter('Completed'),
            ),
            _buildDrawerItem(
              icon: Icons.radio_button_unchecked,
              title: 'Pending',
              onTap: () => _updateFilter('Pending'),
            ),
            Divider(),
            _buildDrawerItem(
              icon: Icons.sort,
              title: 'Sort by',
              onTap: () async {
                final sortOption = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Sort by'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSortOption('Due Date'),
                        _buildSortOption('Priority'),
                        _buildSortOption('Category'),
                      ],
                    ),
                  ),
                );
                if (sortOption != null && sortOption != _sortOption) {
                  setState(() {
                    _sortOption = sortOption;
                  });
                }
              },
            ),
            Divider(),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                // Navigate to settings screen or perform settings action
                Navigator.pop(context); // Close the drawer
                // Implement your settings logic here
              },
            ),
            _buildDrawerItem(
              icon: Icons.feedback,
              title: 'Send Feedback',
              onTap: () {
                // Navigate to send feedback screen or perform feedback action
                Navigator.pop(context); // Close the drawer
                // Implement your send feedback logic here
              },
            ),
            _buildDrawerItem(
              icon: Icons.help,
              title: 'Help',
              onTap: () {
                // Navigate to help screen or perform help action
                Navigator.pop(context); // Close the drawer
                // Implement your help logic here
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        onTap();
        Navigator.pop(context); // Close the drawer
      },
    );
  }

  Widget _buildSortOption(String option) {
    return ListTile(
      title: Text(option),
      onTap: () {
        Navigator.pop(context, option);
      },
    );
  }

  Widget _buildTaskList(List<Task>? tasks) {
    if (tasks == null || tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks to display.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    List<Task> tasksToShow = List.from(tasks); // Create a modifiable copy

    // Apply filtering based on _filterOption
    switch (_filterOption) {
      case 'Completed':
        tasksToShow = tasksToShow.where((task) => task.isCompleted).toList();
        break;
      case 'Pending':
        tasksToShow = tasksToShow.where((task) => !task.isCompleted).toList();
        break;
      default:
        break;
    }

    // Apply sorting based on _sortOption
    switch (_sortOption) {
      case 'Priority':
        tasksToShow.sort((a, b) => b.priority?.compareTo(a.priority ?? 0) ?? 0);
        break;
      case 'Category':
        tasksToShow.sort((a, b) => a.category.compareTo(b.category));
        break;
      default:
        tasksToShow.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '$_filterOption Tasks - Sorted by $_sortOption',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tasksToShow.length,
            itemBuilder: (context, index) {
              final task = tasksToShow[index];
              return TaskItem(
                task: task,
                onCheckboxChanged: (isChecked) {
                  setState(() {
                    task.isCompleted = isChecked; // Handle null safely
                  });
                  Provider.of<TaskProvider>(context, listen: false)
                      .updateTask(task);
                },
                onDeletePressed: () {
                  Provider.of<TaskProvider>(context, listen: false)
                      .deleteTask(task.id); // Ensure id is not null
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TaskScreen(task: task),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _updateFilter(String option) {
    setState(() {
      _filterOption = option;
    });
    Navigator.pop(context); // Close the drawer after selecting filter option
  }
}

class TaskSearch extends SearchDelegate<Task> {
  final List<Task> tasks;

  TaskSearch({required this.tasks});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = tasks
        .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = tasks
        .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildSearchResults(results);
  }

  Widget _buildSearchResults(List<Task> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final task = results[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description), // Ensure description is not null
          onTap: () {
            close(context, task);
          },
        );
      },
    );
  }
}
