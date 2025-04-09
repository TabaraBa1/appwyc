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

class PaymentPage extends StatefulWidget {
  final double totalAmount;

  const PaymentPage({super.key, required this.totalAmount});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String clientNumber = '';
  String selectedRegion = 'Tambacounda';
  String deliveryMessage = '';
  final SecureStorage secureStorage = SecureStorage();
  final RegExp senegalPhoneRegex = RegExp(r'^(77|78|70|76|75)\d{7}$');
  final String paymentUrl =
      "https://paytech.sn/payment/checkout/eey3kom8nn7lz2";
  final String env = "test";
  String get paymentApiUrl =>
      env == "test"
          ? "https://sandbox.paytech.com/api/payment/pay"
          : "https://api.paytech.com/api/payment/pay";

  List<String> regions = ['Tambacounda', 'Dakar'];

  /// Met à jour les informations utilisateur avec le token
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
        "Authorization": "Bearer $token", // Ajout du token ici
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

  /// Effectue le paiement avec le token
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

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token", // Ajout du token ici
      },
      body: json.encode({
        "amount": widget.totalAmount.toString(),
        "client_number": clientNumber,
        "telephone": clientNumber,
        "payment_method": selectedRegion,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PayTech(paymentUrl)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de paiement : ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd0b258),
        title: Text(
          'Informations personelle ',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Couleur du texte
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
                'Total à payer : ${widget.totalAmount % 1 == 0 ? widget.totalAmount.toInt() : widget.totalAmount.toStringAsFixed(2)} f',
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
                // hintText: 'Ex : 771234567',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Color(0xFFd0b258),
                    width: 2.0,
                  ), // Couleur orange
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
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ), // Couleur de la bordure par défaut
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Color(
                      0xFFd0b258,
                    ), // Couleur de la bordure lorsqu'on clique
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Color(
                      0xFFd0b258,
                    ), // Couleur de la bordure lorsqu'on ne clique pas
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Color(
                      0xFFd0b258,
                    ), // Couleur de la bordure lorsqu'il y a une erreur
                    width: 2.0,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.location_on,
                  color: Color(0xFFd0b258),
                ), // Couleur de l'icône
              ),

              onChanged: (value) {
                setState(() {
                  selectedRegion = value!;
                  if (selectedRegion == 'Dakar') {
                    deliveryMessage =
                        'Livraison à Dakar sous 48 h, frais : 2000 f.';
                  } else if (selectedRegion == 'Tambacounda') {
                    deliveryMessage =
                        'Les produits arriveront sous 14 jours maximum,\nDes frais de 100 F sont à prévoir pour la récupération';
                  } else {
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
                  if (!senegalPhoneRegex.hasMatch(clientNumber)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Veuillez entrer un numéro valide au Sénégal (77, 78, 70, 76, 75).',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (clientNumber.isNotEmpty) {
                    await updateUserInfo(); // Met à jour les infos avant le paiement
                    makePayment(); // Lance le paiement
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Veuillez entrer votre numéro de client.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
