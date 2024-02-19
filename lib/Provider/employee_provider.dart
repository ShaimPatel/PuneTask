import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pune_task/Model/user_details_model.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

class EmployeeProvider extends ChangeNotifier {
  List<EmployeeDetailsModel> _employeesList = [];
  bool _isDatabaseEmpty = true;

  List<EmployeeDetailsModel> get employeesList => _employeesList;
  bool get isDatabaseEmpty => _isDatabaseEmpty;

  //! Function to fetch data from API and store in database
  Future<void> fetchDataFromAPIAndStoreInDatabase() async {
    if (_isDatabaseEmpty) {
      try {
        final response = await http.get(
            Uri.parse('https://dummy.restapiexample.com/api/v1/employees'));
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          developer.log("JsonData : $jsonData");
          if (jsonData["status"] == "success" &&
              jsonData["message"] ==
                  "Successfully! All records has been fetched.") {
            for (var data in jsonData['data']) {
              employeesList.add(EmployeeDetailsModel(
                id: data['id'],
                employeeName: data['employee_name'],
                employeeSalary: data['employee_salary'],
                employeeAge: data['employee_age'],
              ));
            }
            //? Store data in local database
            await _storeDataInDatabase(employeesList);
          }
          developer.log(employeesList.toList().toString());
        } else {
          throw Exception(
              'Failed to fetch data from API. Status Code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching data from API: $error');
        throw Exception('Failed to fetch data from API: $error');
      }
    }
  }

  //! Function to store data in local database
  Future<void> _storeDataInDatabase(
      List<EmployeeDetailsModel> employeesData) async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'employees_database.db'),
      onCreate: (db, version) async {
        return await db.execute(
          'CREATE TABLE employeesDetailsTable(id INTEGER PRIMARY KEY, employeeName TEXT, employeeSalary INTEGER, employeeAge INTEGER)',
        );
      },
      version: 1,
    );
    developer.log(database.toString());
    for (var employee in employeesList) {
      await database.insert(
        'employeesDetailsTable',
        {
          'id': employee.id,
          'employeeName': employee.employeeName,
          'employeeSalary': employee.employeeSalary.toString(),
          'employeeAge': employee.employeeAge.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    // List list = await database.rawQuery('SELECT * FROM employeesDetailsTable');
    // developer.log(list.toString());
    _isDatabaseEmpty = false;
    notifyListeners();
  }

  //! Function to retrieve data from local database
  Future<void> fetchDataFromDatabase() async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      path.join(databasePath, 'employees_database.db'),
    );
    final List<Map<String, dynamic>> maps =
        await database.query('employeesDetailsTable');
    _employeesList = List.generate(maps.length, (i) {
      return EmployeeDetailsModel(
        id: maps[i]['id'],
        employeeName: maps[i]['employeeName'],
        employeeSalary: maps[i]['employeeSalary'],
        employeeAge: maps[i]['employeeAge'],
      );
    });
    List list = await database.rawQuery('SELECT * FROM employeesDetailsTable');
    developer.log("$list List of inserted Table data");
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
    await database
        .delete('employeesDetailsTable', where: 'id = ?', whereArgs: [id]);
    _employeesList.removeWhere((employee) => employee.id == id);
    notifyListeners();
  }

  //! Function to update an employee in database
  Future<void> updateEmployee(String name, int age, int salary, int id) async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'employees_database.db'),
    );
    await database.update(
      'employeesDetailsTable',
      {
        'employeeName': name,
        'employeeSalary': salary,
        'employeeAge': age,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    int index = _employeesList.indexWhere((employee) => employee.id == id);
    developer.log(index.toString());
    if (index != -1) {
      _employeesList[index] = EmployeeDetailsModel(
        id: id,
        employeeName: name,
        employeeSalary: salary,
        employeeAge: age,
      );
      notifyListeners();
    }
  }
}
