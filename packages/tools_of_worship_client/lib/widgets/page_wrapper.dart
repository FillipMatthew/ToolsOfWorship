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

  Future<void> _showUserSidebar(BuildContext context) {
    return showDialog<void>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        double width = 350.0;
        double rightPadding = defaultPadding;
        bool fill = false;
        if ((screenWidth - (defaultPadding * 2.0)) <= (maxContentWidth / 2)) {
          width = screenWidth - (defaultPadding * 2);
          fill = true;
        } else if (screenWidth - (defaultPadding * 2.0) > maxAppWidth) {
          rightPadding += ((screenWidth - maxAppWidth) / 2.0);
        }

        return Dialog(
          alignment: fill ? null : Alignment.topRight,
          insetPadding: EdgeInsets.fromLTRB(
              defaultPadding, 60.0, rightPadding, defaultPadding),
          elevation: 0,
          backgroundColor: Colors.transparent,
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
              child: Container(
                width: fill ? null : width,
                constraints: fill ? const BoxConstraints.expand() : null,
                padding: const EdgeInsets.all(defaultPadding),
                child: UserSidebar(onCompleted: () => _hideUserSidebar()),
              ),
            ),
          ),
        );
      },
    );
  }

  void _hideUserSidebar() {
    if (_isOpen) {
      Navigator.of(context).pop();
      setState(() => _isOpen = false);
    }
  }

  void _onPressedUser() {
    if (!_isOpen) {
      _showUserSidebar(context).then((_) => setState(() => _isOpen = false));
      setState(() => _isOpen = true);
    }
  }
}
