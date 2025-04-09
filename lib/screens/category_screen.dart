import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories when the screen loads
  }

  // Récupérer les catégories depuis l'API
  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse(
        'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/categories',
      ),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        categories =
            data
                .map(
                  (item) =>
                      Category(id: item['id'].toString(), name: item['name']),
                )
                .toList();
      });
    } else {
      print('Erreur lors de la récupération des catégories');
    }
  }

  // Méthode pour supprimer une catégorie
  Future<void> deleteCategory(String categoryId) async {
    final response = await http.delete(
      Uri.parse(
        'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/categories/delete/$categoryId',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        categories.removeWhere((category) => category.id == categoryId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catégorie supprimée avec succès')),
      );
    } else {
      print('Erreur lors de la suppression de la catégorie');
      print('Code de statut: ${response.statusCode}');
      print('Message: ${response.body}');
    }
  }

  // Méthode pour afficher le formulaire de modification
  void showEditCategoryDialog(Category category) {
    TextEditingController nameController = TextEditingController(
      text: category.name,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier la catégorie'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nom de la catégorie'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.black,
                ), // Texte "Annuler" en noir
              ),
            ),
            ElevatedButton(
              onPressed: () {
                updateCategory(category.id, nameController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(
                  0xFFd0b258,
                ), // Couleur du fond "Sauvegarder"
                foregroundColor: Colors.white, // Couleur du texte "Sauvegarder"
              ),
              child: Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour mettre à jour une catégorie
  Future<void> updateCategory(String categoryId, String newName) async {
    final response = await http.put(
      Uri.parse(
        'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/categories/update/$categoryId',
      ),
      body: {'name': newName},
    );

    if (response.statusCode == 200) {
      setState(() {
        int index = categories.indexWhere(
          (category) => category.id == categoryId,
        );
        if (index != -1) {
          categories[index] = Category(id: categoryId, name: newName);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catégorie mise à jour avec succès')),
      );
    } else {
      print('Erreur lors de la mise à jour de la catégorie');
      print('Code de statut: ${response.statusCode}');
      print('Message: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes Categories',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Couleur du texte
          ),
        ),
        backgroundColor: Color(0xFFd0b258),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index].name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    showEditCategoryDialog(categories[index]);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteCategory(categories[index].id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
