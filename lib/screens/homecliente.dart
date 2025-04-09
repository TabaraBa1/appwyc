import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wyc/screens/product_client.dart';
import 'package:wyc/screens/product_cart.dart';
import 'package:wyc/screens/homeclient.dart';
// import 'package:site/screens/profile.dart';
import 'package:wyc/screens/api_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Homecliente extends StatefulWidget {
  const Homecliente({super.key, required this.userName});
  final String userName;
  @override
  State<Homecliente> createState() => _HomeclienteState();
}

class _HomeclienteState extends State<Homecliente> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  final String productsUrl =
      'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/products';
  List products = [];
  List filteredProducts = [];
  List recentProducts = []; // Liste des 10 derniers produits
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    getProducts();
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3617476928520921/4470968717', // ID de test bannières
      size: AdSize.largeBanner, // Utilisez une taille plus grande
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

  // Récupération des produits depuis l'API
  Future<void> getProducts() async {
    var response = await http.get(Uri.parse(productsUrl));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['data'];
        filteredProducts = products; // Affiche tous les produits initialement
        getLastTenProducts(); // Récupère les 10 derniers produits
      });
    } else {
      print('Erreur lors de la récupération des produits');
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Déconnexion",
            style: TextStyle(
              // Couleur du titre
            ),
          ),
          content: Text("Voulez-vous vraiment vous déconnecter ?"),

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

  // Récupérer les 10 derniers produits
  void getLastTenProducts() {
    setState(() {
      recentProducts = products.take(10).toList();
    });
  }

  // Filtrer les produits avec une barre de recherche
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton de déconnexion
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      _logout(context); // Fonction de déconnexion
                    },
                  ),
                  // Bouton pour accéder au panier
                  IconButton(
                    icon: Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(),
                        ), // Navigation vers CartPage
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
                      color: Color(0xFFd0b258),
                      width: 2.0,
                    ), // Couleur orange
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
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
                  child: Icon(Icons.grid_view, color: Colors.grey, size: 35.0),
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
                    color: Colors.black,
                    size: 35.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(
                right: 220,
              ), // Marges autour du texte
              child: Text(
                "Populaires  ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),
            // ListView horizontale des 10 derniers produits
            SizedBox(
              height: 240, // Hauteur des cartes
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentProducts.length,
                itemBuilder: (context, index) {
                  var product = recentProducts[index];
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
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      width: 150, // Largeur des cartes

                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(10),
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
                          Container(
                            height: 170, // Hauteur de l'image
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? 'No Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${product['price'].toString()} f',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFd0b258),
                                  ),
                                ),
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
                width:
                    MediaQuery.of(
                      context,
                    ).size.width, // Largeur complète de l'écran
                height: 100.0, // Ajustez la hauteur selon vos besoins
                child: AdWidget(ad: _bannerAd),
              ),

            SizedBox(height: 5),
            // Liste verticale des produits filtrés
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
              ), // Ajoute de l'espace en haut et en bas
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(), // Désactiver le scroll
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
                      margin: EdgeInsets.symmetric(
                        vertical: 8.0,
                      ), // Espacement entre les éléments
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 150, // Hauteur fixe
                            child: AspectRatio(
                              aspectRatio: 1, // Ratio 1:1 pour l'image
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(10),
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
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    product['name'] ?? 'No Name',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    product['description'] ?? 'No Description',
                                    style: TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 0,
      //   selectedItemColor: Color(0xFFdf8600),
      //   unselectedItemColor: Colors.grey,
      //   showUnselectedLabels: true,
      //   onTap: (index) {
      //     if (index == 3) {
      //       // Redirection vers la page de profil
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => ProfilePage(
      //             email: emailController.text,
      //             name: nameController.text,
      //             password: passwordController.text,
      //           ),
      //         ),
      //       );
      //     }
      //   },
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.explore),
      //       label: 'Explore',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.bookmark),
      //       label: 'Wishlist',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
    );
  }
}
