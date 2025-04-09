import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wyc/screens/category_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();

  // Méthode pour sauvegarder une nouvelle catégorie
  Future<void> saveCategory() async {
    final response = await http.post(
      Uri.parse(
        "https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/categories",
      ),
      body: {"name": _categoryNameController.text},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Catégorie ajoutée avec succès');

      // Naviguer vers CategoryListScreen après l'ajout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CategoryListScreen()),
      );
    } else {
      print('Erreur lors de l\'ajout de la catégorie');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter une Categorie',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Couleur du texte
          ),
        ),
        backgroundColor: Color(0xFFd0b258),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryNameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la catégorie',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ), // Contour normal
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFd0b258),
                      width: 2.0,
                    ), // Contour quand sélectionné
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom de la catégorie';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveCategory();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Catégorie ajoutée avec succès')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(230, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Color(0xFFd0b258),
                  foregroundColor: Colors.white,
                ),
                child: Text('Ajouter la catégorie'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Naviguer vers la liste des catégories
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryListScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(230, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Color(0xFFd0b258),
                  foregroundColor: Colors.white,
                ),
                child: Text('Liste Catégories'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
