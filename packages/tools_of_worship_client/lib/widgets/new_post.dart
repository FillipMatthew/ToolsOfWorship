import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/apis/feed.dart';
import 'package:tools_of_worship_client/apis/fellowships.dart';
import 'package:tools_of_worship_client/apis/types/fellowship.dart';
import 'package:tools_of_worship_client/config/styling.dart';

class NewPost extends StatefulWidget {
  final Function(bool cancelled)? _onCompleted;

  const NewPost({Function(bool cancelled)? onCompleted, Key? key})
      : _onCompleted = onCompleted,
        super(key: key);

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  String? _heading;
  String? _selectedFellowshipId;
  String? _selectedFellowshipName;
  String? _article;
  bool _noFellowships = false;
  List<Fellowship>? _fellowships;

  @override
  void initState() {
    super.initState();

    ApiFellowships.getList().toList().then((fellowships) {
      setState(() {
        _noFellowships = fellowships.isEmpty;
        _fellowships = fellowships;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'New post',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const Divider(),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: DropdownButtonHideUnderline(
                  child: _buildDropdown(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: TextField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.bodySmall,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Heading',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _heading = value.isEmpty ? null : value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: TextField(
                    expands: true,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'Article',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _article = value.isEmpty ? null : value;
                      });
                    },
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
                onPressed: (_heading == null ||
                        _selectedFellowshipId == null ||
                        _article == null)
                    ? null
                    : onPost,
                child: const Text('Post'),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDropdown(BuildContext context) {
    if (_fellowships == null) {
      return Text(
        'Loading fellowships list.',
        style: TextStyle(
          color: Theme.of(context).errorColor,
        ),
      );
    }

    if (_noFellowships || _fellowships!.isEmpty) {
      return Text(
        'You need to be part of a fellowship to post.',
        style: TextStyle(
          color: Theme.of(context).errorColor,
        ),
      );
    }

    List<DropdownMenuItem<MapEntry<String, String>>> items = [];
    for (int i = 0; i < _fellowships!.length; ++i) {
      items.add(
        DropdownMenuItem(
          value: MapEntry(_fellowships![i].id, _fellowships![i].name),
          child: Row(
            children: [
              Text(_fellowships![i].name),
            ],
          ),
        ),
      );
    }

    return DropdownButton<MapEntry<String, String>>(
      items: items,
      onChanged: (selected) {
        _selectedFellowshipId = selected?.key;
        setState(() {
          _selectedFellowshipName = selected?.value;
        });
      },
      hint: _selectedFellowshipName == null
          ? const Text('Select a fellowship')
          : Text(_selectedFellowshipName!),
    );
  }

  void onCancel() {
    if (widget._onCompleted != null) {
      widget._onCompleted!(true);
    }
  }

  void onPost() async {
    if (widget._onCompleted != null) {
      if (_selectedFellowshipId == null ||
          _selectedFellowshipId!.isEmpty ||
          _heading == null ||
          _heading!.isEmpty ||
          _article == null ||
          _article!.isEmpty) {
        throw Exception('Data unexpectedly empty');
      }

      await ApiFeed.postPost(_selectedFellowshipId!, _heading!, _article!);

      widget._onCompleted!(false);
    }
  }
}
