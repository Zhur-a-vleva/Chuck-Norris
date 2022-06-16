import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'joke.dart';

void main() {
  runApp(const MyApp());
}

List<String> savedJokes = [];
late SharedPreferences prefs;
String savedJokesKey = "SAVED_JOKES_KEY";

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

const String homePage = "Home";
const String favouritePage = "Favorite";

class _MyHomePageState extends State<MyHomePage> {
  late Future<Joke> _joke;
  late List<Widget> _pages;
  late Widget _home;
  late Widget _favorite;
  late int _selectedIndex;
  late Widget _currentPage;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _currentPage = _pages[_selectedIndex];
    });
  }

  /// Perform actions when application starts
  @override
  void initState() {
    super.initState();
    _home = const HomeStateful();
    _favorite = const FavoriteStateful();
    _pages = [_home, _favorite];
    _currentPage = _home;
    _selectedIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showGuide(context)); // Showing dialog with the guide
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jokes about Chuck Norris"),
      ),
      body: _currentPage,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

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
          return new Joke('', '', '',
              "Chuck Norris advises you to check your internet connection!");
        });
        _joke.then((joke) => setState(() {}));
      });
    }
  }

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

  void _addToStorage() async {
    String text = "";
    _joke.then((joke) => text = joke.value);
    if (text.compareTo(
            "Chuck Norris advises you to check your internet connection!") ==
        0) {
      setState(() {
        if (_favoriteColor == Colors.grey) {
          _favoriteColor = Colors.red;
          savedJokes.add(text);
        } else {
          _favoriteColor = Colors.grey;
          savedJokes.remove(text);
        }
      });
      await prefs.setStringList(savedJokesKey, savedJokes);
    }
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
                          icon: Icon(Icons.favorite, color: _favoriteColor),
                          onPressed: _addToStorage),
                    ]),
                // Button for getting information about developers
                TextButton(
                  child: const Text("About developers",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 10)),
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
        ));
  }
}

class FavoriteStateful extends StatefulWidget {
  const FavoriteStateful({Key? key}) : super(key: key);

  @override
  State<FavoriteStateful> createState() => Favorite();
}

class Favorite extends State<FavoriteStateful> {
  void _deleteJoke(int index) async {
    setState(() {
      savedJokes.removeAt(index);
    });
    await prefs.setStringList(savedJokesKey, savedJokes);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: savedJokes.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Colors.white,
              elevation: 10,
              child: Padding(
                  padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text('${savedJokes[index]}',
                                textAlign: TextAlign.justify)),
                        IconButton(
                            onPressed: () {
                              _deleteJoke(index);
                            },
                            icon: Icon(Icons.delete))
                      ])));
        });
  }
}
