import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/tools_of_worship_client.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body section
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600.0) {
            return Center(
              child: SizedBox(
                width: 600.0,
                child: _body(context),
              ),
            );
          } else {
            return _body(context);
          }
        },
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Text(
              'Tools of Worship',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
