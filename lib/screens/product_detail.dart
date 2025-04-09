import 'package:flutter/material.dart';
import 'package:wyc/screens/edit_product.dart'; // Assurez-vous que le chemin est correct
import 'package:google_fonts/google_fonts.dart';

class ProductDetail extends StatefulWidget {
  final Map product;

  const ProductDetail({super.key, required this.product});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Details du Produits',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white, // Couleur du texte
          ),
        ),
        backgroundColor: Color(0xFFd0b258),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
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
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product['name'] ?? 'Nom du produit',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${widget.product['price']?.toString() ?? '0.00'} f',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.product['description'] ??
                        'Aucune description disponible.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      EditProduct(product: widget.product),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit, color: Colors.white),
                        label: Text(
                          'Modifier',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFd0b258),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _confirmDelete(
                            context,
                            widget.product['id'].toString(),
                          );
                        },
                        icon: Icon(Icons.delete, color: Colors.white),
                        label: Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                  Navigator.of(context).pop(); // Ferme la boîte de dialogue
                  Navigator.of(context).pop(); // Retourne à la page précédente
                });
              },
              child: Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProduct(String productId) async {
    // Implémentez ici la logique de suppression du produit
    // Exemple : Appel API ou suppression locale
    await Future.delayed(
      Duration(seconds: 1),
    ); // Simule un délai pour la démonstration
  }
}
