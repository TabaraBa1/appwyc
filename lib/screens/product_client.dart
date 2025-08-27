import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wyc/screens/product_cart.dart';
import 'package:wyc/screens/payement_page.dart';

// import 'package:file_picker/file_picker.dart';

// import 'package:google_fonts/google_fonts.dart';

class ProductClient extends StatefulWidget {
  final Map product;

  const ProductClient({super.key, required this.product});

  @override
  _ProductClientState createState() => _ProductClientState();
}

class _ProductClientState extends State<ProductClient> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List cartItems = [];
  bool isLoading = true;

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> addToCheckout(BuildContext context) async {
    String? authToken = await getAuthToken();
    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: Token d\'authentification manquant.')),
      );
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(
          'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/checkout/add',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'product_id': widget.product['id'].toString(),
          'qty': 1,
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Produit ajouté au panier')));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ce produit existe deja dans le panier: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout au panier: $e')),
      );
    }
  }

  Future<void> getCheckoutItems() async {
    String? authToken = await getAuthToken();
    if (authToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(
          'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/checkout',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final checkoutData = json.decode(response.body);
        setState(() {
          cartItems = checkoutData;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateQuantity(String productId, int qty) async {
    String? authToken = await getAuthToken();
    if (authToken == null) return;

    try {
      final response = await http.put(
        Uri.parse(
          'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/checkout/update/$productId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'product_id': productId, 'qty': qty}),
      );
      if (response.statusCode == 200) {
        final item = cartItems.firstWhere(
          (item) => item['id'].toString() == productId,
          orElse: () => null,
        );
        if (item != null) {
          setState(() {
            item['qty'] = qty;
          });
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Quantité mise à jour avec succès')),
          // );
        }
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la quantité: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getCheckoutItems();
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount =
        cartItems.isNotEmpty
            ? (widget.product['price'] as num).toDouble() *
                (cartItems[0]['qty'] as num)
            : (widget.product['price'] as num).toDouble() * 1.0;

    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.product['image'] != null &&
                                    widget.product['image'].isNotEmpty
                                ? widget
                                    .product['image'] // Utiliser l'URL complète si elle existe
                                : 'https://via.placeholder.com/150', // Image par défaut si l'URL est vide ou null
                          ),

                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product['name'] ?? 'Aucune Nom',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.product['description'] ??
                                'Aucune description',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '${widget.product['price']} f',
                            style: TextStyle(
                              fontSize: 20,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFd0b258),
                                      // Couleur de fond pour le bouton "-"
                                      borderRadius: BorderRadius.circular(
                                        4,
                                      ), // Coins carrés
                                      // border: Border.all(
                                      //     color: Colors.black,
                                      //     width: 1), // Bordure noire
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                      ), // Icône blanche pour contraste
                                      onPressed: () {
                                        if (cartItems.isNotEmpty) {
                                          int currentQty = cartItems[0]['qty'];
                                          if (currentQty > 1) {
                                            updateQuantity(
                                              cartItems[0]['id'].toString(),
                                              currentQty - 1,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ), // Espacement entre les boutons
                                    child: Text(
                                      cartItems.isNotEmpty
                                          ? cartItems[0]['qty'].toString()
                                          : '1',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        59,
                                        41,
                                        13,
                                      ), // Couleur de fond pour le bouton "+"
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ), // Icône blanche pour contraste
                                      onPressed: () {
                                        if (cartItems.isNotEmpty) {
                                          int currentQty = cartItems[0]['qty'];
                                          updateQuantity(
                                            cartItems[0]['id'].toString(),
                                            currentQty + 1,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Total: $totalAmount f',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFd0b258),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => addToCheckout(context),
                                icon: Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.white,
                                ),
                                label: Text('Ajouter au panier'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFd0b258),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PaymentPage(
                                            totalAmount: totalAmount,
                                            product: widget.product,
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFd0b258),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text('Acheter'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
