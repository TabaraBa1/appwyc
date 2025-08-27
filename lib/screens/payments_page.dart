import 'package:flutter/material.dart';
import 'package:wyc/screens/paytech.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}

class PaymentsPage extends StatefulWidget {
  final List<dynamic> products; // Liste de produits
  final double totalAmount;

  const PaymentsPage({
    Key? key,
    required this.products,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String paymentMethod = "wave";
  String clientNumber = '774465244';
  String selectedRegion = 'Dakar';
  double deliveryFee = 2000; // Frais par défaut pour Dakar
  String deliveryMessage = 'Livraison à Dakar sous 48 h, frais : 2000 f.';

  final SecureStorage secureStorage = SecureStorage();
  final RegExp senegalPhoneRegex = RegExp(r'^(77|78|70|76|75)\d{7}$');

  final String paymentUrl =
      "https://paytech.sn/payment/checkout/eey3kpm9xfpsw9";
  final String env = "production";

  String get paymentApiUrl =>
      env == "test"
          ? "https://sandbox.paytech.com/api/payment/pay"
          : "https://api.paytech.com/api/payment/pay";

  List<String> regions = ['Tambacounda', 'Dakar'];

  Future<void> updateUserInfo() async {
    final String url =
        "https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/user/update";

    String? token = await secureStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : Token non trouvé')));
      return;
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({"telephone": clientNumber, "city": selectedRegion}),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de mise à jour : ${response.statusCode}'),
        ),
      );
    }
  }

  Future<void> makePayment() async {
    final String url =
        "https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/payment/pay";

    String? token = await secureStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : Token non trouvé')));
      return;
    }

    final String refCommand = "REF${DateTime.now().millisecondsSinceEpoch}";

    if (paymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : Méthode de paiement invalide')),
      );
      return;
    }

    if (clientNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : Numéro de téléphone manquant')),
      );
      return;
    }

    final double finalAmount = widget.totalAmount + deliveryFee;

    // Exemple : on prend le premier produit pour le nom (à adapter si besoin)
    final productName =
        widget.products.isNotEmpty ? widget.products[0]['name'] : "Produit";

    print('Données envoyées à PayTech :');
    print({
      "item_name": productName,
      "payment_method": paymentMethod,
      "item_price": finalAmount,
      "currency": "XOF",
      "ref_command": refCommand,
      "command_name": productName,
      "ipn_url":
          "https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/payment/ipn",
      "success_url": "https://paytech.sn/mobile/success",
      "cancel_url": "https://paytech.sn/mobile/cancel",
      "telephone": clientNumber,
      "clientNumber": clientNumber,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "item_name": productName,
        "amount": finalAmount,
        "payment_method": paymentMethod,
        "currency": "XOF",
        "ref_command": refCommand,
        "command_name": productName,
        "ipn_url":
            "https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/payment/ipn",
        "success_url": "https://paytech.sn/mobile/success",
        "cancel_url": "https://paytech.sn/mobile/cancel",
        "telephone": clientNumber,
        "clientNumber": clientNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Réponse complète PayTech : $data');

      if (data.containsKey('redirect_url')) {
        final String paymentUrl = data['redirect_url'];

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PayTech(paymentUrl)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : URL de paiement non trouvée.')),
        );
      }
    } else {
      final errorData = json.decode(response.body);
      print('Erreur serveur : $errorData');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur de paiement : ${response.statusCode}, ${errorData['message'] ?? 'Message non disponible'}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double finalTotal = widget.totalAmount + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd0b258),
        title: Text(
          'Informations personnelles',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Total à payer : ${finalTotal % 1 == 0 ? finalTotal.toInt() : finalTotal.toStringAsFixed(2)} f',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd0b258),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Entrez vos informations',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Numéro du client',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFFd0b258), width: 2.0),
                ),
                prefixIcon: Icon(Icons.phone, color: Color(0xFFd0b258)),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  clientNumber = value;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedRegion,
              items:
                  regions.map((String region) {
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
              decoration: InputDecoration(
                labelText: 'Sélectionnez votre région',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFFd0b258), width: 2.0),
                ),
                prefixIcon: Icon(Icons.location_on, color: Color(0xFFd0b258)),
              ),
              onChanged: (value) {
                // if (value == 'UCAD' &&
                //     (widget.product['category'] == null ||
                //         widget.product['category']['name']
                //                 ?.toString()
                //                 .toUpperCase() !=
                //             'ETUDIANTS')) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text(
                //         'Seuls les produits de la catégorie ÉTUDIANTS peuvent utiliser la livraison UCAD.',
                //       ),
                //       backgroundColor: Colors.red,
                //     ),
                //   );
                //   return;
                // }

                setState(() {
                  selectedRegion = value!;
                  if (selectedRegion == 'Dakar') {
                    deliveryFee = 2000;
                    deliveryMessage =
                        'Livraison à Dakar sous 48 h, frais : 2000 f.';
                  } else if (selectedRegion == 'Tambacounda') {
                    deliveryFee = 1000;
                    deliveryMessage =
                        'Les produits arriveront sous 7 jours maximum, frais de récupération : 2000 f.';
                    // } else if (selectedRegion == 'UCAD') {
                    //   deliveryFee = 500;
                    //   deliveryMessage = 'frais de livraison: 500 f.';
                  } else {
                    deliveryFee = 0;
                    deliveryMessage = '';
                  }
                });
              },
            ),
            SizedBox(height: 10),
            if (deliveryMessage.isNotEmpty)
              Center(
                child: Text(
                  deliveryMessage,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),

            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Validation du numéro de téléphone avant de continuer
                  if (!senegalPhoneRegex.hasMatch(clientNumber)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Numéro de téléphone invalide, doit commencer par 77,78,70,76, ou 75 et faire 9 chiffres.",
                        ),
                      ),
                    );
                    return;
                  }
                  await updateUserInfo();
                  await makePayment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFd0b258),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Poursuivre le paiement',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
