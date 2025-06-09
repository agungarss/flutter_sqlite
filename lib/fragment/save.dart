import 'package:flutter/material.dart';

class SaveFragment extends StatelessWidget {
  const SaveFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your saved items will appear here',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
