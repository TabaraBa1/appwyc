import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wyc/screens/add_product.dart';
import 'package:wyc/screens/product_detail.dart';
import 'package:wyc/screens/add_category.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:file_picker/file_picker.dart';

import 'package:wyc/screens/users_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String url =
      'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/products';

  Future getProducts() async {
    var response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);
    print(
      "Données récupérées: $data",
    ); // Ajoute ce print pour voir la réponse API
    return data;
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Déconnexion",
            style: TextStyle(
              color: Color(0xFFd0b258), // Couleur du titre
            ),
          ),
          content: Text(
            "Voulez-vous vraiment vous déconnecter ?",
            style: TextStyle(
              color: Color(0xFFd0b258), // Couleur du titre
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: Text(
                "Annuler",
                style: TextStyle(
                  color: Color(0xFFd0b258), // Couleur du titre
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                // Ajoutez ici la logique pour vider le token ou réinitialiser l'état de connexion
                Navigator.pushReplacementNamed(
                  context,
                  '/login',
                ); // Redirige vers la page de connexion
              },
              child: Text(
                "Se déconnecter",
                style: TextStyle(
                  color: Color(0xFFd0b258), // Couleur du titre
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future deleteProduct(String productId) async {
    String url =
        'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/products/$productId';
    var response = await http.delete(Uri.parse(url));
    return json.decode(response.body);
  }

  Future<void> _confirmDelete(BuildContext context, String productId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation de suppression"),
          content: Text("Voulez-vous supprimer ce produit définitivement ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                deleteProduct(productId).then((value) {
                  setState(() {}); // Rafraîchit l'interface
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Produit supprimé !')));
                  Navigator.of(
                    context,
                  ).pop(); // Ferme la boîte de dialogue après suppression
                });
              },
              child: Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProduct()),
                );
              },
              backgroundColor: Color(0xFFd0b258),
              child: Icon(Icons.add),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCategoryScreen()),
                );
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.category, color: Color(0xFFd0b258)),
            ),
          ),

          Positioned(
            bottom: 10,
            right: 80, // Positionne à gauche pour éviter la superposition
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersPage()),
                );
              },
              backgroundColor: Colors.black,
              child: Icon(Icons.people, color: Color(0xFFd0b258)),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          'Bienvenue Admin!',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Couleur du texte
          ),
        ),
        backgroundColor: Color(0xFFd0b258),
        elevation: 5,

        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data['data'] == null) {
            return Center(child: Text('Aucun produit disponible.'));
          }

          List products =
              snapshot.data['data']; // Récupère la liste des produits

          if (products.isEmpty) {
            return Center(child: Text('Aucun produit disponible.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];

              String imageUrl =
                  product['image'] != null
                      ? product['image']
                      : 'https://via.placeholder.com/120'; // Image par défaut si l'URL est vide

              String name = product['name'] ?? 'Nom non disponible';
              String price =
                  product['price'] != null
                      ? '${product['price']} f'
                      : 'Prix inconnu';

              return Container(
                color: Colors.white,
                height: 150,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black45,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProductDetail(product: product),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(9.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Prix : $price',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Handle edit
                                    },
                                    child: Text(''),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _confirmDelete(
                                        context,
                                        product['id'].toString(),
                                      );
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
