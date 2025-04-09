import 'package:flutter/material.dart';
import 'package:wyc/screens/api_service.dart';
import 'package:wyc/screens/indexe.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  final String name;
  final String password;

  const VerifyCodePage({
    super.key,
    required this.email,
    required this.name,
    required this.password,
  });

  @override
  _VerifyCodePageState createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final TextEditingController codeController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  // Méthode de vérification
  void verifyCode() async {
    if (codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un code de vérification.')),
      );
      return;
    }

    setState(() {
      isLoading = true; // Indiquer que la requête est en cours
    });

    try {
      // Vérification du code de validation
      final response = await apiService.verifyCode(
        widget.email,
        codeController.text.trim(),
      );

      // Afficher toute la réponse pour débogage
      print(
        'Réponse de l\'API: $response',
      ); // Affiche toute la réponse du serveur

      // Vérification si la réponse contient un message
      if (response.containsKey('message')) {
        print('Message reçu: ${response['message']}');
      } else {
        print('Aucun message dans la réponse');
      }

      // Vérifier si le code est valide
      if (response['message'] == 'Email verifie avec succes!') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Vous pouvez maintenant vous connecter.')),
        );

        // Attendre un peu avant de rediriger vers la page de connexion
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Indexe()),
          );
        });
      } else {
        // Si la réponse n'est pas celle attendue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Code de vérification invalide.',
            ),
          ),
        );
      }
    } catch (error) {
      // Gérer les erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la vérification : $error')),
      );
    } finally {
      setState(() {
        isLoading = false; // Fin du chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc de la page
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(
                'Vérifiez votre email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFd0b258),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Entrez le code envoyé à ${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Code de vérification',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd0b258)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : verifyCode,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(327, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Color(0xFFd0b258),
                ),
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Vérifier le code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
