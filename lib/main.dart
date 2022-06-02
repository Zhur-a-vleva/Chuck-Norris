import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'joke.dart';

/// This function fetches joke from the API and either returns Future<Joke> or throws an exception
Future<Joke> fetchJoke() async {
  final response =
      await http.get(Uri.parse('https://api.chucknorris.io/jokes/random'));
  if (response.statusCode == 200) {
    return Joke.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load Joke');
  }
}

/// This function shows dialog in the very beginning. Dialog contains guide for users
_showGuide(BuildContext context) {
  return showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Guide"),
          content: const Text(
              "- Press button \"I like it! More\" to get new joke about Chuck Norris\n- Click \"About developers to"
              " get personal information about them\n- Swipe left/right to get new joke\n\nFunny jokes to you!"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        );
      });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jokes about Chuck Norris',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Joke> _joke;

  /// Perform actions when application starts
  @override
  void initState() {
    super.initState();
    _getNewJoke(); // Fetching first joke
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showGuide(context)); // Showing dialog with the guide
  }

  /// This function fetches joke, and when the result is ready update the state
  void _getNewJoke() {
    _joke = fetchJoke();
    _joke.then((joke) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jokes about Chuck Norris"),
      ),
      body:
          // GestureDetector for performing fetching joke with swipe
          GestureDetector(
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

                      // Button for fetching random jokes
                      FloatingActionButton.extended(
                        backgroundColor: Colors.blue,
                        elevation: 10,
                        onPressed: _getNewJoke,
                        label: const Text("I like it! More",
                            style: TextStyle(fontSize: 20)),
                      ),

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
                                onPressed: () => Navigator.pop(context, 'Nice'),
                                child: const Text('Nice'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
    );
  }
}
