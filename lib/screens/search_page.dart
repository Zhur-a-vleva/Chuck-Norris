import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../joke.dart';

class SearchStateful extends StatefulWidget {
  const SearchStateful({Key? key}) : super(key: key);

  @override
  State<SearchStateful> createState() => Search();
}

class Search extends State<SearchStateful> {
  TextEditingController editingController = TextEditingController();
  List<Joke> items = [];

  Future<List<Joke>> fetchJokes(String query) async {
    final response = await http
        .get(Uri.parse('https://api.chucknorris.io/jokes/search?query=$query'));
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var result = body["result"] as List;
      return result.map<Joke>((json) => Joke.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Jokes');
    }
  }

  void filterSearchResults(String query) {
    Future<List<Joke>> list = fetchJokes(query);
    list.then((value) => setState(() {
          items = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 8, right: 8, bottom: 10, top: 15),
          child: TextField(
            onChanged: (value) {
              filterSearchResults(value);
            },
            controller: editingController,
            decoration: const InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          ),
        ),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.white,
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Flexible(
                            child: Text(items[index].value,
                                textAlign: TextAlign.justify)),
                      ));
                })),
      ],
    );
  }
}
