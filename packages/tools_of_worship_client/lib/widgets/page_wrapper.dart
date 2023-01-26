import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/config/styling.dart';
import 'package:tools_of_worship_client/widgets/user_sidebar.dart';

class PageWrapper extends StatefulWidget {
  final Widget _child;

  const PageWrapper({required Widget child, Key? key})
      : _child = child,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper>
    with SingleTickerProviderStateMixin {
  static const _animationDuration =
      Duration(milliseconds: defaultMenuAnimationMS);
  bool _isOpen = false;
  OverlayEntry? _userSideBar;

  @override
  void dispose() {
    _hideUserSidebar();

    super.dispose();
  }

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
                    child: widget._child,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserSidebar() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double width = 350.0;
    bool fill = false;
    if ((screenWidth - (defaultPadding * 2)) <= (maxContentWidth / 2)) {
      width = screenWidth - (defaultPadding * 2);
      fill = true;
    }

    double appPadding = 0.0;
    if (!fill) {
      if (screenWidth > maxAppWidth) {
        appPadding = (screenWidth - maxAppWidth) / 2.0;
      }
    }

    _userSideBar = OverlayEntry(
      builder: (context) {
        return Positioned(
          right: defaultPadding + appPadding,
          width: width,
          top: 60.0,
          bottom: fill ? defaultPadding : null,
          child: AnimatedOpacity(
            duration: _animationDuration,
            opacity: _isOpen ? 1.0 : 0.0,
            child: Card(
              color: Theme.of(context)
                  .cardColor
                  .withOpacity(defaultOverlayOpacity),
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
        );
      },
    );

    final overlay = Overlay.of(context);
    overlay.insert(_userSideBar!);
  }

  void _hideUserSidebar() {
    _userSideBar?.remove();
    _userSideBar = null;
  }

  void _onPressedUser() {
    if (!_isOpen) {
      _showUserSidebar();
    } else {
      _hideUserSidebar();
    }

    setState(() => _isOpen = !_isOpen);
  }
}
