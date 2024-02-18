// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pune_task/Provider/employee_provider.dart';

import '../Res/Utils/utils.dart';

// ignore: must_be_immutable
class EmployeeDataUpdatePage extends StatefulWidget {
  int id;
  String name;
  double salary;
  int age;

  EmployeeDataUpdatePage({
    Key? key,
    required this.id,
    required this.name,
    required this.salary,
    required this.age,
  }) : super(key: key);

  @override
  State<EmployeeDataUpdatePage> createState() => _EmployeeDataUpdatePageState();
}

class _EmployeeDataUpdatePageState extends State<EmployeeDataUpdatePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController salaryController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.name;
    salaryController.text = widget.salary.toString();
    ageController.text = widget.age.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Update"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: "Employee Name",
              ),
            ),

            const SizedBox(height: 10),
            TextFormField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Employee Age",
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Employee Salary",
              ),
            ),
            //!
            const SizedBox(height: 50),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          Utils.toastMessage("Name can't be empty");
                        } else if (ageController.text.trim().isEmpty) {
                          Utils.toastMessage("Age can't be empty");
                        } else if (salaryController.text.trim().isEmpty) {
                          Utils.toastMessage("Salary can't be empty");
                        } else if (nameController.text.trim() == widget.name &&
                            ageController.text.trim() ==
                                widget.age.toString() &&
                            salaryController.text.trim() ==
                                widget.salary.toString()) {
                          Utils.toastMessage("All Feaild value are same");
                          Navigator.pop(context);
                        } else {
                          Provider.of<EmployeeProvider>(context, listen: false)
                              .updateEmployee(
                                  nameController.text.trim(),
                                  int.parse(ageController.text.trim()),
                                  double.parse(salaryController.text.trim()),
                                  widget.id);
                          Utils.toastMessage(
                              "Employee Details Updated Successfully");
                          Navigator.pop(context);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Text(
                          "Update".toUpperCase(),
                          style: const TextStyle(fontSize: 19),
                        ),
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
