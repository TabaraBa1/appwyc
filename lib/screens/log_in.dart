import 'package:flutter/material.dart';
import 'package:wyc/screens/api_service.dart';
import 'package:wyc/screens/home_page.dart';
import 'package:wyc/screens/homeclient.dart';
import 'package:wyc/screens/secure_storage.dart';
import 'package:wyc/screens/regis_ter.dart';

class Log_in extends StatefulWidget {
  const Log_in({super.key});

  @override
  _Log_inState createState() => _Log_inState();
}

class _Log_inState extends State<Log_in> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _obscurePassword = true;

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorSnackbar(
        "L'email et le mot de passe ne peuvent pas être vides.",
      );
      return;
    }

    try {
      final response = await apiService.login(
        emailController.text,
        passwordController.text,
      );

      if (response['token'] == null) {
        _showErrorSnackbar("La connexion a échoué. Veuillez réessayer.");
        return;
      }

      final String token = response['token'];
      final String role = response['user']['role'] ?? 'guest';
      final String userName = response['user']['name'] ?? 'Utilisateur';

      await SecureStorage().saveToken(token);

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (role == 'client') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Homeclient(userName: userName),
          ),
        );
      } else {
        _showErrorSnackbar("Rôle non reconnu.");
      }
    } catch (e) {
      _showErrorSnackbar("email ou mot de passe incorrect : $e");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Arrière-plan blanc pour la page entière
      body: Center(
        // Centrer le formulaire
        child: SingleChildScrollView(
          child: Container(
            width: 350, // Largeur fixe pour centrer le formulaire
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Formulaire de connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Se connecter',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.spa, color: Color(0xFFd0b258), size: 40),
                  ],
                ),
                SizedBox(height: 50),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey),
                    hintText: 'Entrez votre email',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.email, color: Color(0xFFd0b258)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Color(0xFFd0b258)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(color: Colors.grey),
                    hintText: 'Entrez votre mot de passe',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFFd0b258)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color(0xFFd0b258),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Color(0xFFd0b258)),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(327, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: Color(0xFFd0b258),
                  ),
                  child: Text(
                    'Se connecter',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Regis_ter()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Color(0xFFd0b258)),
                    backgroundColor: Colors.white,
                    minimumSize: Size(327, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'S\'inscrire',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


  // void _showForgotPasswordModal(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
  //     ),
  //     builder: (BuildContext context) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Mot de passe oublié?',
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close),
  //                   onPressed: () => Navigator.of(context).pop(),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 20),
  //             ListTile(
  //               leading: Icon(Icons.email_outlined),
  //               title: Text('votre email'),
  //               subtitle: Text('entrer votre email'),
  //               trailing: Icon(Icons.arrow_forward_ios),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 _showEmailPhoneEntryModal(context, 'email');
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _sendPasswordResetLink(String email) async {
  //   if (email.isEmpty) {
  //     _showErrorSnackbar("L'email ne peut pas être vide.");
  //     return;
  //   }

  //   try {
  //     final response = await apiService.sendPasswordResetLink(email);
  //     print("Réponse de l'API: $response"); // Ajout de logs pour le débogage

  //     if (response['message'] != null) {
  //       _showErrorSnackbar(response['message']);
  //     } else {
  //       _showErrorSnackbar("Lien de réinitialisation envoyé avec succès.");
  //     }
  //   } catch (e) {
  //     _showErrorSnackbar(
  //       "Erreur lors de l'envoi du lien de réinitialisation : $e",
  //     );
  //   }
  // }

  // void _showEmailPhoneEntryModal(BuildContext context, String method) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
  //     ),
  //     builder: (BuildContext context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(20.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   method == 'email'
  //                       ? 'Entrer votre email'
  //                       : 'Entrer votre numero ',
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close),
  //                   onPressed: () => Navigator.of(context).pop(),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 10),
  //             Text(
  //               'Veuillez entrer un ${method == 'email' ? 'adresse email' : 'numero'} pour demander une réinitialisation du mot de passe.',
  //               style: TextStyle(fontSize: 14),
  //             ),
  //             SizedBox(height: 20),
  //             TextFormField(
  //               keyboardType:
  //                   method == 'email'
  //                       ? TextInputType.emailAddress
  //                       : TextInputType.phone,
  //               decoration: InputDecoration(
  //                 hintText:
  //                     method == 'email'
  //                         ? 'Entrer votre email'
  //                         : 'Entrer votre numero',
  //                 prefixIcon: Icon(
  //                   method == 'email'
  //                       ? Icons.email_outlined
  //                       : Icons.phone_outlined,
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 20),
  //             ElevatedButton(
  //               onPressed: () {
  //                 _sendPasswordResetLink(emailController.text);
  //                 Navigator.of(context).pop();
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 minimumSize: Size(327, 56),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(40.0),
  //                 ),
  //                 backgroundColor: Color(0xFFdf8600),
  //               ),
  //               child: Text(
  //                 'Envoyer le lien',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.w700,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Include your existing _showForgotPasswordModal method here

