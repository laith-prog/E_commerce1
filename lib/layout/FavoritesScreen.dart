import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: ListView.builder(
        itemCount: 5,  // Number of dummy favorites
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Favorite Item #${index + 1}'),
            subtitle: Text('This is a dummy favorite item'),
            leading: Icon(Icons.favorite, color: Colors.red),
          );
        },
      ),
    );
  }
}
