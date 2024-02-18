import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:pune_task/Pages/employee_data_update_page.dart';

import '../Provider/employee_provider.dart';
import '../Res/Utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = false;

  @override
  void initState() {
    Utils.toastMessage("Swipe the card Right to Left for Delete the record");

    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isVisible = true;
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void scrollTo() {
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 300), curve: Curves.bounceInOut);
  }

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      debounceDuration: Duration.zero,
      connectivityBuilder: (
        BuildContext ctx,
        ConnectivityResult connectivity,
        Widget child,
      ) {
        if (connectivity == ConnectivityResult.none) {
          return Scaffold(
            backgroundColor: Colors.green[100],
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Center(
                    child: Text('Please check your internet connection!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              ],
            ),
          );
        }
        return child;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("User Details"),
        ),
        floatingActionButton: _isVisible
            ? FloatingActionButton(
                onPressed: scrollTo,
                child: const Icon(Icons.arrow_upward),
              )
            : null,
        body: Consumer<EmployeeProvider>(
          builder: (context, employeeProvider, _) {
            // Fetch data from API and store in database if database is empty
            employeeProvider.fetchDataFromDatabase();
            // Fetch data from database
            if (employeeProvider.isDatabaseEmpty) {
              final employeePro =
                  Provider.of<EmployeeProvider>(context, listen: false);
              if (employeePro.isDatabaseEmpty) {
                employeePro.fetchDataFromAPIAndStoreInDatabase();
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                controller: _scrollController,
                itemCount: employeeProvider.employees.length,
                itemBuilder: (context, index) {
                  final employee = employeeProvider.employees[index];
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key(employee.id.toString()),
                    onDismissed: (direction) {
                      // Delete the item when dismissed
                      employeeProvider.deleteEmployee(employee.id!);
                      setState(() {
                        employeeProvider.employees.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          showCloseIcon: true,
                          shape: const RoundedRectangleBorder(),
                          elevation: 1,
                          content: Row(
                            children: [
                              CircleAvatar(
                                child: Text(employee.id!.toString()),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                    'Employee ${employee.employeeName!} has been dismissed'),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                      //? Check if all records are deleted, then fetch data from the server again
                      if (employeeProvider.isDatabaseEmpty) {
                        employeeProvider.fetchDataFromAPIAndStoreInDatabase();
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        color: Colors.green[100],
                        child: ListTile(
                          isThreeLine: true,
                          leading: const CircleAvatar(
                            radius: 25,
                            child: Image(
                              image: AssetImage(
                                  "assets/Images/employee_profile.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            employee.employeeName!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Age : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                    TextSpan(
                                      text: employee.employeeAge.toString(),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //? Salary
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Salary : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                    TextSpan(
                                      text: employee.employeeSalary.toString(),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: Colors.grey[50],
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (contex) => EmployeeDataUpdatePage(
                                          age: employee.employeeAge!,
                                          id: employee.id!,
                                          name: employee.employeeName!,
                                          salary: employee.employeeSalary!,
                                        )));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
