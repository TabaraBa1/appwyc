import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wyc/screens/product_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List cartItems = [];
  bool isLoading = true;

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
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

  // Fonction pour afficher la boîte de dialogue de confirmation avant de supprimer un produit
  Future<void> confirmRemoveFromCart(String productId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmer la suppression',
            style: TextStyle(
              color: Color.fromARGB(255, 14, 13, 13), // Couleur du titre
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ce produit de votre panier ?',
            style: TextStyle(
              // Couleur du titre
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(); // Ferme la boîte de dialogue sans rien faire
              },
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Color(0xFFd0b258), // Couleur du titre
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                removeFromCart(
                  productId,
                ); // Effectue la suppression si confirmé
              },
              child: Text(
                'Confirmer',
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

  Future<void> removeFromCart(String productId) async {
    String? authToken = await getAuthToken();
    if (authToken == null) {
      print('Erreur: Aucun token d\'authentification trouvé.');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(
          'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/checkout/remove/$productId',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        // Vérifie que le produit est supprimé de la liste cartItems
        setState(() {
          cartItems.removeWhere((item) => item['id'].toString() == productId);
        });
        print('Produit supprimé du panier');
      } else {
        print(
          'Erreur lors de la suppression du produit: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erreur lors de la suppression du produit: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getCheckoutItems();
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3617476928520921/4470968717', // ID de test bannières
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Failed to load a banner ad: ${error.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd.dispose(); // 👈 ici on libère la ressource pub
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Panier',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Couleur du texte
          ),
        ),
      ),
      body: Column(
        children: [
          // Affichage des éléments du panier
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            // Redirige vers la page ProductClient
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductClient(
                                      product: cartItems[index],
                                    ),
                              ),
                            );
                          },
                          child: Image.network(
                            cartItems[index]['image'] != null &&
                                    cartItems[index]['image'].isNotEmpty
                                ? cartItems[index]['image']
                                : 'https://via.placeholder.com/150',
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                'https://via.placeholder.com/150',
                                width: 50,
                                height: 50,
                              );
                            },
                          ),
                        ),
                        title: Text(cartItems[index]['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Prix: ${(cartItems[index]['price'] * cartItems[index]['qty']).toStringAsFixed(2)} FCF',
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            confirmRemoveFromCart(
                              cartItems[index]['id'].toString(),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

          // Affichage de la bannière si elle est prête
          if (_isBannerAdReady)
            Container(
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }
}
