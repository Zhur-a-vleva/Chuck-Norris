import 'package:chuck_norris/screens/home_page.dart';
import 'package:chuck_norris/screens/search_page.dart';
import 'package:flutter/material.dart';

import 'joke.dart';
import 'screens/favorite_page.dart';

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
  late List<Widget> _pages;
  late Widget _home;
  late Widget _favorite;
  late Widget _search;
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
    _search = const SearchStateful();
    _pages = [_home, _favorite, _search];
    _currentPage = _home;
    _selectedIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showGuide(context)); // Showing dialog with the guide
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jokes about Chuck Norris")),
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
