import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:wyc/screens/home_page.dart';
import 'package:image_picker/image_picker.dart';

// Classe Category pour représenter une catégorie
class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

// Méthode pour construire un champ de texte
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFd0b258)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFd0b258), width: 2),
      ),
    ),
    validator: validator,
  );
}

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitsController = TextEditingController();
  final _priceController = TextEditingController();
  String? selectedCategoryId;
  String? _imageName;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool isLoading = false; // Ajout de la variable isLoading
  // Liste des catégories récupérées depuis l'API
  List<Category> categories = [];

  // Fonction pour récupérer les catégories depuis l'API
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

  void _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        // _imageName = pickedFile.name; // Récupère le nom du fichier
      });

      // Après avoir sélectionné l'image, vous pouvez afficher le nom directement
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('image selectionne : $_imageName')),
      // );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Vérifier si une image a été sélectionnée
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner une image.')),
        );
        return;
      }

      // Préparer les données pour Cloudinary
      final uploadUrl = Uri.parse(
        'https://api.cloudinary.com/v1_1/dqdyq5zyd/image/upload',
      );

      var request = http.MultipartRequest('POST', uploadUrl);

      // Ajouter le preset d'upload Unsigned
      request.fields['upload_preset'] =
          'tabou_shop'; // Remplace par ton upload preset

      // Ajouter le fichier image
      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedImage!.path),
      );

      // Envoyer la requête pour télécharger l'image
      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final data = json.decode(responseData);

          // L'URL de l'image téléchargée sur Cloudinary
          final imageUrl = data['secure_url'];

          // Afficher l'URL de l'image téléchargée (pour validation)
          print('Image URL: $imageUrl');

          // Préparer la requête pour enregistrer le produit
          final productUri = Uri.parse(
            'https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/products/store',
          );
          var productRequest = http.MultipartRequest('POST', productUri);

          // Ajouter les champs du produit à la requête
          productRequest.fields['name'] = _nameController.text;
          productRequest.fields['description'] = _descriptionController.text;
          productRequest.fields['units'] = _unitsController.text;
          productRequest.fields['price'] = _priceController.text;
          productRequest.fields['category_id'] =
              selectedCategoryId
                  .toString(); // Assure-toi que c'est une chaîne valide
          productRequest.fields['image_url'] =
              imageUrl; // Change 'image' to 'image_url'

          // Envoyer la requête pour enregistrer le produit
          final productResponse = await productRequest.send();
          if (productResponse.statusCode == 200 ||
              productResponse.statusCode == 201) {
            final responseString = await productResponse.stream.bytesToString();
            print(
              'Réponse du serveur : $responseString',
            ); // Log de la réponse complète
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produit enregistré avec succès!')),
            );
            // Rediriger vers HomePage après le succès
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            final responseString = await productResponse.stream.bytesToString();
            print(
              'Erreur lors de l\'enregistrement du produit: $responseString',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Échec de l\'enregistrement du produit.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du téléchargement de l\'image.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      } finally {
        setState(() {
          isLoading = false; // Arrête le chargement
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Charger les catégories lors du démarrage
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter un produit',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFd0b258),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _selectImage,
                      icon: Icon(Icons.camera_alt), // L'icône
                      label: Text('Sélectionnez une image'), // Le texte

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFd0b258,
                        ), // Personnalisation de la couleur
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    if (_imageName != null) Text(_imageName!),
                  ],
                ),

                SizedBox(height: 32),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nom du produit',

                  icon: Icons.shopping_cart,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Veuillez entrer un nom'
                              : null,
                ),
                const SizedBox(height: 16),
                // Champ Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Veuillez entrer une description'
                              : null,
                ),
                const SizedBox(height: 16),

                // Champ Unité
                // Champ Unité
                _buildTextField(
                  controller: _unitsController, // Correction ici
                  label: 'Unité',
                  icon: Icons.format_list_numbered,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Veuillez entrer l\'unité'
                              : null,
                ),

                const SizedBox(height: 16),

                // Champ Prix
                _buildTextField(
                  controller: _priceController,
                  label: 'Prix',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Veuillez entrer le prix'
                              : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Categorie',

                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items:
                      categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(
                            category.name,
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'veuillez entrer la categorie';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFd0b258,
                      ), // Couleur de fond
                      foregroundColor: Colors.white, // Couleur du texte
                      minimumSize: Size(327, 56), // Taille minimale du bouton
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20.0,
                        ), // Coins arrondis
                      ),
                    ),

                    child:
                        isLoading
                            ? CircularProgressIndicator(
                              color: Colors.white,
                            ) // Affiche un indicateur de chargement
                            : Text(
                              'Enregistrer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
