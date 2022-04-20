import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/config/styling.dart';
import 'package:tools_of_worship_client/widgets/user_sidebar.dart';

class PageWrapper extends StatefulWidget {
  final Widget _content;

  const PageWrapper(Widget content, {Key? key})
      : _content = content,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper>
    with SingleTickerProviderStateMixin {
  static const _animationDuration =
      Duration(milliseconds: defaultMenuAnimationMS);
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  AppBar(
                    title: const Text('Tools of Worship'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: _onPressedUser,
                      ),
                    ],
                  ),
                  Expanded(
                    child: widget._content,
                  ),
                ],
              ),
              _buildUserSidebar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserSidebar() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double width = 350.0;
    bool fill = false;
    if ((screenWidth - (defaultPadding * 2)) <= (maxContentWidth / 2)) {
      width = screenWidth - (defaultPadding * 2);
      fill = true;
    }

    return Positioned(
      right: defaultPadding,
      width: width,
      top: 60.0,
      bottom: fill ? defaultPadding : null,
      child: IgnorePointer(
        ignoring: !_isOpen,
        child: ExcludeFocus(
          excluding: !_isOpen,
          child: AnimatedOpacity(
            duration: _animationDuration,
            opacity: _isOpen ? 1.0 : 0.0,
            child: Card(
              color: Theme.of(context).cardColor.withOpacity(0.8),
              elevation: defaultMenuElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: const Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: UserSidebar(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPressedUser() {
    setState(() => _isOpen = !_isOpen);
  }
}
