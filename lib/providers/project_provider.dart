import 'package:flutter/material.dart';
import 'package:clocky/models/project.dart';
import 'package:clocky/services/database_service.dart';

class ProjectProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Project> _projects = [];

  List<Project> get projects => List.unmodifiable(_projects);

  Project? getById(int id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadProjects() async {
    _projects = await _db.getProjects();
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    final id = await _db.insertProject(project);
    _projects.add(project.copyWith(id: id));
    _projects.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    await _db.updateProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      _projects.sort((a, b) => a.name.compareTo(b.name));
    }
    notifyListeners();
  }

  Future<void> deleteProject(int id) async {
    await _db.deleteProject(id);
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
