import 'dart:convert';
import 'package:wyc/screens/category.dart';
import 'package:wyc/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class EditProduct extends StatefulWidget {
  final Map product;

  const EditProduct({super.key, required this.product});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  List<Category> categories = [];
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitController;
  late TextEditingController _priceController;

  String selectedCategoryId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _descriptionController = TextEditingController(
      text: widget.product['description'],
    );
    _unitController = TextEditingController(
      text: widget.product['units'].toString(),
    );
    _priceController = TextEditingController(
      text: widget.product['price'].toString(),
    );
    selectedCategoryId = widget.product['category_id'].toString();
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse(
        "https://floating-sea-30778-fbe8564bd579.herokuapp.com/public/api/categories",
      ),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data
          .map((e) => Category(id: e['id'].toString(), name: e['name']))
          .toList();
    } else {
      throw Exception('Erreur lors du chargement des catégories');
    }
  }

  Future<void> updateProduct() async {
    final response = await http.put(
      Uri.parse(
        "https://floating-sea-30778-fbe8564bd579.herokuapp.com/api/products/update/${widget.product['id']}",
      ),
      body: {
        'category_id': selectedCategoryId,
        "name": _nameController.text,
        "description": _descriptionController.text,
        "units": _unitController.text,
        "price": _priceController.text,
      },
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier le Produit',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Couleur du texte
          ),
        ),
        backgroundColor: const Color(0xFFd0b258),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              _buildTextField(
                controller: _unitController,
                label: 'Unité',
                icon: Icons.format_list_numbered,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Veuillez entrer l\'unité'
                            : null,
              ),
              const SizedBox(height: 16),
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
              FutureBuilder<List<Category>>(
                future: fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    categories = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Sélectionnez une catégorie',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items:
                          categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value!;
                        });
                      },
                      hint: const Text('Aucune catégorie sélectionnée'),
                    );
                  } else {
                    return const Text('Aucune catégorie disponible.');
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateProduct().then((value) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Produit modifié avec succès !'),
                        ),
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFd0b258),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  'Modifier',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
