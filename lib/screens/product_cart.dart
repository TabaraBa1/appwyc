import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wyc/screens/product_client.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wyc/screens/payments_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // late BannerAd _bannerAd;
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

  Future<void> confirmRemoveFromCart(String productId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmer la suppression',
            style: TextStyle(color: Color.fromARGB(255, 14, 13, 13)),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ce produit de votre panier ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: TextStyle(color: Color(0xFFd0b258)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                removeFromCart(productId);
              },
              child: Text(
                'Confirmer',
                style: TextStyle(color: Color(0xFFd0b258)),
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
    // _bannerAd = BannerAd(
    //   adUnitId: 'ca-app-pub-3617476928520921/4470968717', // ID réel ou test
    //   size: AdSize.banner,
    //   request: AdRequest(),
    //   listener: BannerAdListener(
    //     onAdLoaded: (Ad ad) {
    //       setState(() {
    //         _isBannerAdReady = true;
    //       });
    //     },
    //     onAdFailedToLoad: (Ad ad, LoadAdError error) {
    //       print('Failed to load a banner ad: ${error.message}');
    //       ad.dispose();
    //     },
    //   ),
    // )..load();
  }

  // @override
  // void dispose() {
  //   _bannerAd.dispose();
  //   super.dispose();
  // }

  double getTotalAmount() {
    double total = 0;
    for (var item in cartItems) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Panier',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFFd0b258),
        centerTitle: true,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : cartItems.isEmpty
              ? Center(
                child: Text(
                  'Votre panier est vide.',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading:
                                item['image'] != null
                                    ? Image.network(
                                      item['image'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                    : Icon(Icons.image_not_supported),
                            title: Text(item['name'] ?? 'Produit'),
                            subtitle: Text(
                              ' ${(item['price'] * (item['quantity'] ?? 1))} f',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if ((item['quantity'] ?? 1) > 1) {
                                        item['quantity'] =
                                            (item['quantity'] ?? 1) - 1;
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  '${item['quantity'] ?? 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      item['quantity'] =
                                          (item['quantity'] ?? 1) + 1;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    confirmRemoveFromCart(
                                      item['id'].toString(),
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductClient(product: item),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFd0b258),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () {
                        if (cartItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Le panier est vide.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        double totalAmount = getTotalAmount();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PaymentsPage(
                                  totalAmount: totalAmount,
                                  products:
                                      cartItems, // au lieu de product: cartItems
                                ),
                          ),
                        );
                      },
                      child: Text(
                        'Passer au paiement',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  // if (_isBannerAdReady)
                  //   Container(
                  //     height: _bannerAd.size.height.toDouble(),
                  //     width: _bannerAd.size.width.toDouble(),
                  //     child: AdWidget(ad: _bannerAd),
                  //   ),
                ],
              ),
    );
  }
}
