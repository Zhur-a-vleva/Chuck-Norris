import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global_variables.dart';
import '../joke.dart';

String _selectedCategory = 'all';
List<String> _categories = [
  "all",
  "animal",
  "career",
  "celebrity",
  "dev",
  "explicit",
  "fashion",
  "food",
  "history",
  "money",
  "movie",
  "music",
  "political",
  "religion",
  "science",
  "sport",
  "travel"
];

class HomeStateful extends StatefulWidget {
  const HomeStateful({Key? key}) : super(key: key);

  @override
  State<HomeStateful> createState() => _Home();
}

class _Home extends State<HomeStateful> {
  late Future<Joke> _joke;
  Color _favoriteColor = Colors.grey;

  /// This function fetches joke, and when the result is ready update the state
  void _getNewJoke() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result) {
      _joke = fetchJoke();
      _joke.then((joke) => setState(() {}));
      _joke.then((joke) => _favoriteColor =
          savedJokes.contains(joke.value) ? Colors.red : Colors.grey);
    } else {
      setState(() {
        _joke = Future(() {
          return Joke('', '', '',
              "Chuck Norris advises you to check your internet connection!");
        });
        _joke.then((joke) => setState(() {}));
      });
    }
  }

  /// This function fetches joke from the API and either returns Future<Joke> or throws an exception
  Future<Joke> fetchJoke() async {
    if (_selectedCategory == "all") {
      final response =
          await http.get(Uri.parse('https://api.chucknorris.io/jokes/random'));
      if (response.statusCode == 200) {
        return Joke.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load Joke');
      }
    } else {
      final response = await http.get(Uri.parse(
          'https://api.chucknorris.io/jokes/random?category=$_selectedCategory'));
      if (response.statusCode == 200) {
        return Joke.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load Joke');
      }
    }
  }

  void _addToStorage() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result) {
      setState(() {
        if (_favoriteColor == Colors.grey) {
          _favoriteColor = Colors.red;
          _joke.then((joke) => savedJokes.add(joke.value));
        } else {
          _favoriteColor = Colors.grey;
          _joke.then((joke) => savedJokes.remove(joke.value));
        }
      });
    }
    await prefs.setStringList(savedJokesKey, savedJokes);
  }

  @override
  void initState() {
    super.initState();
    _getNewJoke(); // Fetching first joke
    _getPrefsAndData();
  }

  void _getPrefsAndData() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(savedJokesKey) != null) {
      savedJokes = prefs.getStringList(savedJokesKey)!;
    } else {
      savedJokes = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        int sensitivity =
            8; // This parameter needs in order to differ horizontal swipes from vertical
        // Swiping in right direction
        if (details.delta.dx > sensitivity) {
          _getNewJoke();
        }
        // Swiping in left direction
        if (details.delta.dx < -sensitivity) {
          _getNewJoke();
        }
      },
      child: Center(
          child: SafeArea(
              left: true,
              top: true,
              right: true,
              minimum: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(left: 15, top: 15),
                        child: Text("Select category:",
                            style: TextStyle(
                                color: Colors.blueGrey, fontSize: 15))),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 200, left: 15, right: 15),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        elevation: 16,
                        style: const TextStyle(color: Colors.blue),
                        underline: Container(
                          height: 2,
                          color: Colors.blue,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        items: _categories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        isExpanded: true,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(bottom: 40.0),
                            child: FutureBuilder<Joke>(
                              future: _joke,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data!.value,
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(fontSize: 15));
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                // By default, show a loading spinner
                                return const CircularProgressIndicator();
                              },
                            )),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // Button for fetching random jokes
                              FloatingActionButton.extended(
                                backgroundColor: Colors.blue,
                                elevation: 10,
                                onPressed: _getNewJoke,
                                label: const Text("I like it! More",
                                    style: TextStyle(fontSize: 20)),
                              ),
                              IconButton(
                                  icon: Icon(Icons.favorite,
                                      color: _favoriteColor),
                                  onPressed: _addToStorage),
                            ]),
                        // Button for getting information about developers
                        TextButton(
                          child: const Text("About developers",
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 10)),
                          onPressed: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Developer\'s information'),
                              content: const Text(
                                  'Name: Dasha Zhuravleva\nStatus: Student of Innopolis University\nMessage: Have a nice day ;)'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Nice'),
                                  child: const Text('Nice'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]))),
    );
  }
}
