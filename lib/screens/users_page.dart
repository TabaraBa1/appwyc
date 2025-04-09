import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final String url =
      'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/users'; // Endpoint pour récupérer les utilisateurs
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Fonction pour récupérer le token sécurisé
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Fonction pour récupérer les utilisateurs
  Future<List<dynamic>> getUsers() async {
    String? token = await getToken(); // Récupère le token stocké
    if (token == null) {
      throw Exception('Token non trouvé');
    }

    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Vérifie la réponse brute pour mieux comprendre sa structure
    print(
      'Réponse brute : ${response.body}',
    ); // Affiche la réponse brute du serveur

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // Vérifie la structure de 'data'
      print('Données décodées : $data');

      if (data['data'] != null) {
        return data['data'];
      } else {
        throw Exception('Aucune donnée dans la réponse');
      }
    } else {
      throw Exception('Erreur lors du chargement des utilisateurs');
    }
  }

  // Fonction pour supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    // Afficher un dialog pour demander confirmation avant de supprimer
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(false); // Ferme le dialog et retourne false
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(true); // Ferme le dialog et retourne true
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );

    // Si l'utilisateur confirme la suppression (confirmDelete == true)
    if (confirmDelete == true) {
      String? token = await getToken(); // Récupère le token stocké
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      String deleteUrl =
          'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/users/$userId';
      var response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Authorization': 'Bearer $token',
        }, // Ajouter le token d'authentification
      );

      if (response.statusCode == 200) {
        setState(() {}); // Mettre à jour l'affichage après suppression
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur supprimé avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression')),
        );
      }
    } else {
      // Si l'utilisateur annule la suppression, rien ne se passe
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Suppression annulée')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Utilisateurs inscrits'),
        backgroundColor: Color(0xFFd0b258),
      ),
      body: FutureBuilder(
        future: getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun utilisateur trouvé"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var user = snapshot.data![index];
              int userId =
                  int.tryParse(user['id'].toString()) ??
                  0; // Convertir 'id' en entier

              // Récupérer les informations supplémentaires : city et telephone
              String city = user['city'] ?? 'Ville inconnue';
              String telephone = user['telephone'] ?? 'Téléphone inconnu';

              return ListTile(
                title: Text(user['name'] ?? 'Sans nom'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['email']),
                    Text('Ville : $city'),
                    Text('Téléphone : $telephone'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    deleteUser(userId.toString()); // Utilise 'userId' converti
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
