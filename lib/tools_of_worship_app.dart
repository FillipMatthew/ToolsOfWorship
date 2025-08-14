import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/feed.dart';
import 'config/styling.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/welcome.dart';
import 'providers/account_authentication.dart';
import 'providers/fellowships.dart';

class ToolsOfWorshipApp extends StatefulWidget {
  const ToolsOfWorshipApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ToolsOfWorshipAppState();
  }
}

class _ToolsOfWorshipAppState extends State<ToolsOfWorshipApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountAuthentication>(
      create: (_) => AccountAuthentication(),
      builder: (context, _) => MaterialApp(
        title: 'Tools of Worship',
        theme: ThemeData.from(colorScheme: defaultColourScheme),
        home: FutureBuilder(
          future: _silentSignIn(context),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const WelcomePage();
            }

            if (snapshot.data == false) {
              return const LoginPage();
            }

            return MultiProvider(
              providers: [
                ProxyProvider<AccountAuthentication, ApiFeed>(
                  create: (context) => ApiFeed(
                      context.select<AccountAuthentication, String>(
                          (accountAuth) => accountAuth.authToken)),
                  update: (_, accountAuth, ___) =>
                      ApiFeed(accountAuth.authToken),
                ),
                ProxyProvider<AccountAuthentication, FellowshipsProvider>(
                  create: (context) => FellowshipsProvider(
                      context.select<AccountAuthentication, String>(
                          (accountAuth) => accountAuth.authToken)),
                  update: (_, accountAuth, fellowships) {
                    if (fellowships != null) {
                      fellowships.authToken = accountAuth.authToken;
                      return fellowships;
                    } else {
                      return FellowshipsProvider(accountAuth.authToken);
                    }
                  },
                ),
              ],
              child: const HomePage(),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _silentSignIn(BuildContext context) async {
    if (context.select<AccountAuthentication, bool>(
        (accountAuth) => accountAuth.isSignedIn)) {
      return true;
    } else {
      return context.read<AccountAuthentication>().signInSilent();
    }
  }
}
