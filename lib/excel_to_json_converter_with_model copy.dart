import 'dart:io';

import 'excel_converter_service.dart';
import 'round_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'person.dart';

class ExcelToJsonConverter extends StatefulWidget {
  const ExcelToJsonConverter({super.key});

  @override
  ExcelToJsonConverterState createState() => ExcelToJsonConverterState();
}

class ExcelToJsonConverterState extends State<ExcelToJsonConverter> {
  List<Person>? personList;
  List<Person>? filteredPersonList;
  String? jsonString; // State variable to hold JSON string
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterPersons);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPersons);
    _searchController.dispose();
    super.dispose();
  }

  void _filterPersons() {
    final query = _searchController.text.toLowerCase();
    if (personList != null) {
      setState(() {
        filteredPersonList = personList!.where((person) {
          return person.name.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel to Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: RoundButton(
                    title: 'Pick Excel to JSON',
                    width: 80,
                    onPressed: () {
                      pickAndConvertFileToJson();
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RoundButton(
                    width: 80,
                    title: 'Pick Excel to Model',
                    onPressed: () {
                      pickAndConvertFileToModel();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            jsonString != null
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        jsonString!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                : filteredPersonList != null
                    ? TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search by Name',
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Container(),
            filteredPersonList != null
                ? Expanded(
                    child: ListView.builder(
                      itemCount: filteredPersonList!.length,
                      itemBuilder: (context, index) {
                        final person = filteredPersonList![index];
                        return ListTile(
                          title: Text(person.name),
                          subtitle: Text(
                              'Age: ${person.age}, Average Success: ${person.averageSuccess}'),
                        );
                      },
                    ),
                  )
                : const Text('No file selected'),
          ],
        ),
      ),
    );
  }

  Future<void> pickAndConvertFileToModel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      try {
        List<Person> persons =
            await ExcelConverterService.convertExcelToPersonList(file.path);
        setState(() {
          jsonString = null;
          personList = persons;
          filteredPersonList = persons; //init
        });
      } catch (e) {
        // Handle error
        print('Error converting file to Person list: $e');
        setState(() {
          jsonString = 'Error converting file to Person list';
        });
      }
    } else {
      setState(() {
        jsonString = 'No file selected';
      });
    }
  }

  Future<void> pickAndConvertFileToJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      try {
        String personsJson =
            await ExcelConverterService.convertExcelToJson(file.path);
        setState(() {
          jsonString =
              personsJson; // Store the JSON string in the state variable
          personList = null; // Clear the person list if it exists
          filteredPersonList = null;
        });
      } catch (e) {
        // Handle error
        print('Error converting file to JSON: $e');
        setState(() {
          jsonString = 'Error converting file to JSON';
        });
      }
    } else {
      setState(() {
        jsonString = 'No file selected';
      });
    }
  }
}
