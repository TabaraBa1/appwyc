import 'package:flutter/material.dart';
// import 'package:site/screens/indexe.dart';
import 'package:wyc/screens/log_in.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  @override
  void initState() {
    super.initState();

    // Redirection automatique après 5 secondes
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // builder: (context) => Indexe()),
          builder: (context) => Log_in(),
        ), // Page de destination
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFFd0b258), elevation: 0),
      backgroundColor: Color(0xFFd0b258),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou image principale
              Image.asset(
                'assets/images/97.png',
                height: 200, // Augmenter la hauteur de l'image
                width:
                    200, // Ajouter une largeur pour agrandir proportionnellement
                fit: BoxFit.cover, // Optionnel : pour ajuster le contenu
              ),
              // Vous pouvez ajouter d'autres widgets ici si nécessaire
            ],
          ),
        ),
      ),
    );
  }
}
