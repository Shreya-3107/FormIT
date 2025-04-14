import 'package:flutter/material.dart';
import 'package:trial/main.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool showModules = true;
  bool showTable = false;
  List<String> modules = ["Module 1", "Module 2", "Module 3", "Module 4", "Module 5"];
  List<String> fieldNames = ["Field 1", "Field 2", "Field 3", "Field 4"];
  List<List<String>> tableData = [
    ["abc", "555", "777", "jji"],
    ["def", "777", "99", "ihih"],
    ["fff", "88", "979", "jjo"],
    ["kkkk", "999", "999", "jjoo"],
  ];

  void _deleteRow(int rowIndex) {
    setState(() {
      tableData.removeAt(rowIndex);
    });
  }

  void _addRow() {
    setState(() {
      tableData.add(["", "", "", ""]);
    });
  }

  void _openModule() {
    setState(() {
      showModules = false;
      showTable = true;
    });
  }

  void _renameModule(int index) {
    TextEditingController controller = TextEditingController(text: modules[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rename Module"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            child: Text("Save"),
            onPressed: () {
              setState(() {
                modules[index] = controller.text;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deleteModule(int index) {
    setState(() {
      modules.removeAt(index);
    });
  }

  void _showModuleOptions(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Module Options"),
        actions: [
          TextButton(
            child: Text("Rename"),
            onPressed: () {
              Navigator.pop(context);
              _renameModule(index);
            },
          ),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              Navigator.pop(context);
              _deleteModule(index);
            },
          ),
          TextButton(
            child: Text("Open"),
            onPressed: () {
              Navigator.pop(context);
              _openModule();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Settings", style: TextStyle(color: Colors.black)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Settings"),
                    content: TextButton(
                      child: Text("Logout"),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(showModules ? "Modules" : "Stock Market Table"),
        leading: (showModules || !showTable)
            ? null
            : IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              showModules = true;
              showTable = false;
            });
          },
        ),
      ),
      body: showModules
          ? Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16),
              children: [
                for (int i = 0; i < modules.length; i++)
                  GestureDetector(
                    onTap: () => _showModuleOptions(i),
                    child: Container(
                      margin: EdgeInsets.all(8),
                      height: 100,
                      color: Colors.primaries[i * 2 % Colors.primaries.length].shade100,
                      child: Center(
                          child: Text(modules[i],
                              style: TextStyle(color: Colors.black))),
                    ),
                  ),
              ],
            ),
          ),
        ],
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 60,
                border: TableBorder.all(),
                columns: [
                  DataColumn(label: Text("S.No")),
                  for (int i = 0; i < fieldNames.length; i++)
                    DataColumn(
                      label: SizedBox(
                        width: 150,
                        child: TextFormField(
                          initialValue: fieldNames[i],
                          onChanged: (value) {
                            setState(() {
                              fieldNames[i] = value;
                            });
                          },
                        ),
                      ),
                    ),
                  DataColumn(label: Text("Actions")),
                ],
                rows: List.generate(tableData.length, (rowIndex) {
                  return DataRow(cells: [
                    DataCell(Text((rowIndex + 1).toString())),
                    for (int colIndex = 0; colIndex < tableData[rowIndex].length; colIndex++)
                      DataCell(
                        Container(
                          color: Colors.white,
                          child: SizedBox(
                            width: 150,
                            child: TextFormField(
                              initialValue: tableData[rowIndex][colIndex],
                              onChanged: (value) {
                                setState(() {
                                  tableData[rowIndex][colIndex] = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRow(rowIndex),
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addRow,
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 5),
                      Text("Add Record"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Copyright © 2025',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}















