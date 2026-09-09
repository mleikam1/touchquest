import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'services/save_service.dart';
void main() async {WidgetsFlutterBinding.ensureInitialized(); final save=SaveService(await SharedPreferences.getInstance()); runApp(TouchQuestApp(save:save));}
