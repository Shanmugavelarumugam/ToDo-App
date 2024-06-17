import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/task.dart'; // Adjust import path as per your project structure
import '../services/database_helper.dart'; // Adjust import path as per your project structure

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Replace with your actual database helper

  TaskProvider() {
    loadTasks();
  }

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);

  Future<void> loadTasks() async {
    try {
      final tasks = await _dbHelper.queryAllTasks();
      _tasks.clear();
      _tasks.addAll(tasks.map((task) => Task.fromMap(task)).toList());
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Failed to load tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final id = await _dbHelper.insertTask(task.toMap());
      task = Task(
        id: id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        isCompleted: task.isCompleted,
        category: task.category,
      );
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Failed to add task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _dbHelper.updateTask(task.toMap());
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      // Handle error
      print('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _dbHelper.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Failed to delete task: $e');
    }
  }

  void toggleTaskCompletion(int id) {
    try {
      final task = _tasks.firstWhere((task) => task.id == id);
      task.isCompleted = !task.isCompleted;
      updateTask(task);
    } catch (e) {
      // Handle error
      print('Failed to toggle task completion: $e');
    }
  }
}
