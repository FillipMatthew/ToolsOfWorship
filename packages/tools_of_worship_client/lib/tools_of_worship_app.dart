import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/tools_of_worship_client.dart';

class ToolsOfWorshipApp extends StatefulWidget {
  const ToolsOfWorshipApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ToolsOfWorshipAppState();
  }
}

class _ToolsOfWorshipAppState extends State<ToolsOfWorshipApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tools of Worship',
      theme: ThemeData.from(colorScheme: defaultColourScheme),
      routes: <String, WidgetBuilder>{
        Routing.root: (BuildContext context) => const WelcomePage(),
        Routing.signup: (BuildContext context) => const SignupPage(),
        Routing.home: (BuildContext context) => const HomePage(),
      },
    );
  }
}
