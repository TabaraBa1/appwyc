import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wyc/screens/product_client.dart';
import 'package:wyc/screens/product_cart.dart';
import 'package:wyc/screens/homecliente.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// import 'package:site/screens/profile.dart';
// import 'package:site/screens/api_service.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name']);
  }
}

class Homeclient extends StatefulWidget {
  final String userName;
  const Homeclient({super.key, required this.userName});

  @override
  State<Homeclient> createState() => _HomeclientState();
}

class _HomeclientState extends State<Homeclient> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  final String productsUrl =
      'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/products';
  final String categoriesUrl =
      'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/categories';
  List products = [];
  List filteredProducts = [];
  List<Category> categories = [];
  List recentProducts = [];

  @override
  void initState() {
    super.initState();
    getProducts();
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



  Future<void> getProducts() async {
    var response = await http.get(Uri.parse(productsUrl));
    setState(() {
      products = json.decode(response.body)['data'];
      filteredProducts = products; // Initially show all products
      recentProducts = products.take(10).toList(); // Get the first 10 products
    });
  }

  void filterProducts(String query) {
    final filtered =
        products.where((product) {
          final productName = product['name'].toLowerCase();
          return productName.contains(query.toLowerCase());
        }).toList();

    setState(() {
      filteredProducts = filtered;
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose(); // 👈 ici on libère la ressource pub
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: Color(
                  0xFFd0b258,
                ), // Couleur du fond, ajustez-la selon vos besoins
                borderRadius: BorderRadius.circular(20), // Arrondi des coins
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bienvenue ${widget.userName} !',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ), // Espacement entre le texte et l'icône

                        IconButton(
                          icon: Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: filterProducts,
                      decoration: InputDecoration(
                        hintText: 'Rechercher des produits...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ), // Couleur orange
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            Row(
              children: [
                SizedBox(width: 270),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Homeclient(userName: widget.userName),
                      ),
                    );
                  },
                  child: Icon(Icons.grid_view, color: Colors.black, size: 35.0),
                ),
                SizedBox(width: 2),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Homecliente(userName: widget.userName),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.splitscreen,
                    color: Colors.grey,
                    size: 35.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Container(
              width: 400, // Largeur du container
              height: 220, // Hauteur du container
              decoration: BoxDecoration(
                color: Color(0xFFd0b258), // Couleur de fond
                borderRadius: BorderRadius.circular(20), // Rayon des coins
              ),
              child: Center(
                child: SizedBox(
                  width: 190, // Largeur de l'image
                  height: 190, // Hauteur de l'image
                  child: Image.asset(
                    'assets/images/102.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ListView horizontale des 10 derniers produits
            SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ), // Espace à gauche et à droite
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      0.65, // Diminue le ratio pour augmenter la hauteur
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  var product = filteredProducts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductClient(product: product),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Définir l'URL de l'image en vérifiant si l'image existe
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    // Vérification si 'product['image']' est une URL complète
                                    product['image'] != null &&
                                            product['image'].isNotEmpty
                                        ? product['image'] // Utiliser l'URL complète si elle existe
                                        : 'https://via.placeholder.com/120', // Image par défaut
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? 'No Name',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${product['price'].toString()} f',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFd0b258),
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Commenté si tu veux ajouter la description
                                // Text(
                                //   product['description'] ?? 'No Description',
                                //   style: TextStyle(fontSize: 14),
                                //   maxLines: 4,
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if (_isBannerAdReady)
              Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
          ],
        ),
      ),
    );
  }
}
