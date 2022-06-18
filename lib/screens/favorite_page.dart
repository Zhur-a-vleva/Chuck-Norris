import 'package:flutter/material.dart';

import '../global_variables.dart';

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
                  padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(savedJokes[index],
                                textAlign: TextAlign.justify)),
                        IconButton(
                            onPressed: () {
                              _deleteJoke(index);
                            },
                            icon: const Icon(Icons.delete))
                      ])));
        });
  }
}
