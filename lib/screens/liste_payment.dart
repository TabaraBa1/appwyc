import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final String url =
      'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/payments'; // API Laravel
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Fonction pour récupérer le token sécurisé
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Fonction pour récupérer tous les paiements
  Future<List<dynamic>> getPayments() async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Token non trouvé');
    }

    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
        return data['data']; // Retourne la liste des paiements
      } else {
        throw Exception('Aucune donnée trouvée');
      }
    } else {
      throw Exception('Erreur lors du chargement des paiements');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des paiements'),
        backgroundColor: Color(0xFFd0b258),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun paiement trouvé"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var payment = snapshot.data![index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(Icons.payment, color: Colors.green),
                  title: Text(
                    "Montant: ${payment['amount']} ${payment['currency']}",
                  ),
                  subtitle: Text("Statut: ${payment['status']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.info, color: Colors.blue),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text('Détails du paiement'),
                              content: Text(
                                'Montant : ${payment['amount']} ${payment['currency']}\n'
                                'Référence : ${payment['ref_command'] ?? "Non disponible"}\n'
                                'Statut : ${payment['status']}\n'
                                'Méthode : ${payment['payment_method'] ?? "Non spécifié"}\n'
                                'Date : ${payment['created_at']}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Fermer'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
