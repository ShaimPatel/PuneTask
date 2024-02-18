import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pune_task/Model/user_details_model.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class EmployeeProvider extends ChangeNotifier {
  List<EmployeeDetailsModel> _employees = [];
  bool _isDatabaseEmpty = true;

  List<EmployeeDetailsModel> get employees => _employees;
  bool get isDatabaseEmpty => _isDatabaseEmpty;

  //! Function to fetch data from API and store in database
  Future<void> fetchDataFromAPIAndStoreInDatabase() async {
    if (_isDatabaseEmpty) {
      final response = await http
          .get(Uri.parse('https://dummy.restapiexample.com/api/v1/employees'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<EmployeeDetailsModel> employeesList = [];
        for (var data in jsonData['data']) {
          employeesList.add(EmployeeDetailsModel(
            id: data['id'],
            employeeName: data['employee_name'],
            employeeSalary:
                double.parse(data['employee_salary'].toString()).toDouble(),
            employeeAge: data['employee_age'],
          ));
        }
        //? Store data in local database
        // print(employeesList.toString());
        await _storeDataInDatabase(employeesList);
      } else {
        throw Exception('Failed to fetch data from API');
      }
    }
  }

  //! Function to store data in local database
  Future<void> _storeDataInDatabase(
      List<EmployeeDetailsModel> employees) async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'employees_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE employees(id INTEGER PRIMARY KEY, employeeName TEXT, employeeSalary INTEGER, age INTEGER)',
        );
      },
      version: 1,
    );

    for (var employee in employees) {
      await database.insert(
        'employees',
        {
          'id': employee.id,
          'employeeName': employee.employeeName,
          'employeeSalary': employee.employeeSalary,
          'employeeAge': employee.employeeAge,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    _isDatabaseEmpty = false;
    notifyListeners();
  }

  //! Function to retrieve data from local database
  Future<void> fetchDataFromDatabase() async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      path.join(databasePath, 'employees_database.db'),
    );
    final List<Map<String, dynamic>> maps = await database.query('employees');
    _employees = List.generate(maps.length, (i) {
      return EmployeeDetailsModel(
        id: maps[i]['id'],
        employeeName: maps[i]['employeeName'],
        employeeSalary: maps[i]['employeeSalary'],
        employeeAge: maps[i]['employeeAge'],
      );
    });
    List list = await database.rawQuery('SELECT * FROM employees');
    // print(list.toString());
    if (list.isEmpty) {
      _isDatabaseEmpty = true;
    }
    notifyListeners();
  }

  //! Function to delete an employee from database
  Future<void> deleteEmployee(int id) async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'employees_database.db'),
    );
    await database.delete('employees', where: 'id = ?', whereArgs: [id]);
    _employees.removeWhere((employee) => employee.id == id);
    notifyListeners();
  }

  //! Function to update an employee in database
  Future<void> updateEmployee(
      String name, int age, double salary, int id) async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'employees_database.db'),
    );
    await database.update(
      'employees',
      {
        'employeeName': name,
        'employeeSalary': salary,
        'employeeAge': age,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    int index = _employees.indexWhere((employee) => employee.id == id);
    if (index != -1) {
      // _employees[index] = ;
    }
  }
}
