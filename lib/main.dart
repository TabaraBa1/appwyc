import 'package:flutter/material.dart';
// import 'package:uni_links/uni_links.dart'; // Ajoute cette dépendance dans pubspec.yaml
import 'package:wyc/screens/log_in.dart';
import 'package:wyc/screens/regis_ter.dart';
import 'package:wyc/screens/index.dart';
// import 'package:wyc/screens/log_in.dart';
import 'dart:async';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize(); // Initialisation d'AdMob
  // Déclare ton device comme un device de test
  // MobileAds.instance.updateRequestConfiguration(
  //   RequestConfiguration(testDeviceIds: ['6699E2F8423ECF37391D8E51B6D52A42']),
  // );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  // void initState() {
  //   super.initState();
  //   _handleDeepLink();
  // }
  // void _handleDeepLink() async {
  //   _sub = linkStream.listen((String? link) {
  //     if (link != null) {
  //       if (link.contains('/payment/success')) {
  //         Navigator.pushNamed(context, '/success');
  //       } else if (link.contains('/payment/cancel')) {
  //         Navigator.pushNamed(context, '/cancel');
  //       }
  //     }
  //   });
  // }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Register App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Index(),
      routes: {
        '/login': (context) => Log_in(),
        '/register': (context) => Regis_ter(),
        '/success': (context) => SuccessPage(),
        '/cancel': (context) => CancelPage(),
      },
    );
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paiement Réussi')),
      body: Center(child: Text('Merci pour votre paiement !')),
    );
  }
}

class CancelPage extends StatelessWidget {
  const CancelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paiement Annulé')),
      body: Center(child: Text('Votre paiement a été annulé.')),
    );
  }
}
