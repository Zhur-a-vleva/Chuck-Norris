import 'package:shared_preferences/shared_preferences.dart';

List<String> savedJokes = [];
late SharedPreferences prefs;
String savedJokesKey = "SAVED_JOKES_KEY";
