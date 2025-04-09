import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeliveryForm extends StatefulWidget {
  final int? deliveryId; // Optional for update, null for new delivery
  const DeliveryForm({super.key, this.deliveryId});

  @override
  _DeliveryFormState createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  final _formKey = GlobalKey<FormState>();
  String? _ville;
  DateTime? _dateLivraison;
  double? _fraisLivraison;
  String _statut = 'en attente';

  @override
  void initState() {
    super.initState();
    if (widget.deliveryId != null) {
      _fetchDeliveryData(widget.deliveryId!);
    }
  }

  // Fetch delivery details for editing
  Future<void> _fetchDeliveryData(int deliveryId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/deliveries/$deliveryId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _ville = data['ville'];
        _dateLivraison = DateTime.parse(data['date_livraison']);
        _fraisLivraison = double.tryParse(data['frais_livraison'].toString());
        _statut = data['statut'];
      });
    }
  }

  // Save or update the delivery
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Map<String, dynamic> deliveryData = {
        'ville': _ville,
        // 'date_livraison': DateFormat('yyyy-MM-dd').format(_dateLivraison!),
        'frais_livraison': _fraisLivraison,
        'statut': _statut,
      };

      final url =
          widget.deliveryId == null
              ? 'http://localhost:8000/api/deliveries'
              : 'http://localhost:8000/api/deliveries/${widget.deliveryId}';

      final response =
          widget.deliveryId == null
              ? await http.post(
                Uri.parse(url),
                body: jsonEncode(deliveryData),
                headers: {"Content-Type": "application/json"},
              )
              : await http.put(
                Uri.parse(url),
                body: jsonEncode(deliveryData),
                headers: {"Content-Type": "application/json"},
              );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success handling
        Navigator.pop(context, 'Delivery saved successfully!');
      } else {
        // Error handling
        print('Failed to save delivery');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.deliveryId == null ? 'New Delivery' : 'Edit Delivery',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Ville'),
                initialValue: _ville,
                validator: (value) => value!.isEmpty ? 'Enter ville' : null,
                onSaved: (value) => _ville = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Frais Livraison'),
                keyboardType: TextInputType.number,
                initialValue: _fraisLivraison?.toString(),
                validator:
                    (value) => value!.isEmpty ? 'Enter frais livraison' : null,
                onSaved: (value) => _fraisLivraison = double.tryParse(value!),
              ),
              DropdownButtonFormField<String>(
                value: _statut,
                items:
                    ['en attente', 'livré', 'annulé'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                onChanged: (newValue) => setState(() => _statut = newValue!),
                decoration: InputDecoration(labelText: 'Statut'),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  widget.deliveryId == null
                      ? 'Create Delivery'
                      : 'Update Delivery',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
