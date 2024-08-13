import 'dart:convert';
import 'dart:io';

import 'person.dart';
import 'package:excel/excel.dart';

class ExcelConverterService {
  static Future<String> convertExcelToJson(String filePath) async {
    return jsonEncode(await getDataFromExcel(filePath));
  }

  static Future<List<Person>> convertExcelToPersonList(String filePath) async {
    return (await getDataFromExcel(filePath))
        .map((data) => Person.fromJson(data))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getDataFromExcel(
      String filePath) async {
    var file = File(filePath);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    List<Map<String, dynamic>> jsonList = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];

      if (sheet != null) {
        List<String> headers = [];

        for (var i = 0; i < sheet.maxRows; i++) {
          if (i == 0) {
            headers =
                sheet.rows[i].map((e) => e?.value.toString() ?? '').toList();
          } else {
            Map<String, dynamic> rowData = {};
            for (var j = 0; j < sheet.rows[i].length; j++) {
              var cellValue = sheet.rows[i][j];

              if (cellValue != null && cellValue.value != null) {
                if (cellValue.value is String ||
                    cellValue.value is num ||
                    cellValue.value is bool) {
                  rowData[headers[j]] = cellValue.value;
                } else {
                  rowData[headers[j]] = cellValue.value.toString();
                }
              } else {
                rowData[headers[j]] = null;
              }
            }
            jsonList.add(rowData);
          }
        }
      }
    }

    return jsonList;
  }
}
