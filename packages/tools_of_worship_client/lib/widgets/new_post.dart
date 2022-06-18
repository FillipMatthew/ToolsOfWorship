import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/config/styling.dart';

class NewPost extends StatelessWidget {
  final Function(bool cancelled)? _onCompleted;

  const NewPost({Function(bool cancelled)? onCompleted, Key? key})
      : _onCompleted = onCompleted,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text("New post"),
        ),
        const Divider(),
        Expanded(
          child: Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: TextField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Title',
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: TextField(
                    expands: true,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'Article',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: onPost,
                child: const Text('Post'),
              ),
            ],
          ),
        )
      ],
    );
  }

  void onCancel() {
    if (_onCompleted != null) {
      _onCompleted!(true);
    }
  }

  void onPost() {
    if (_onCompleted != null) {
      _onCompleted!(false);
    }
  }
}
