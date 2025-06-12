import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wallet/components/filepicker.dart';

class CreateProduct extends StatefulWidget {
  const CreateProduct({super.key});

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _warrantyController = TextEditingController();
  Uint8List? _image;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _warrantyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    return double.tryParse(v) == null ? 'Invalid' : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _warrantyController,
                  decoration: const InputDecoration(labelText: 'Warranty (months)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    return int.tryParse(v) == null ? 'Invalid' : null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final img = await pickImageSafely();
                        if (img != null) {
                          setState(() {
                            _image = img;
                          });
                        }
                      },
                      child: const Text('Pick Image'),
                    ),
                    const SizedBox(width: 12),
                    if (_image != null)
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.memory(_image!, fit: BoxFit.cover),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context, {
                        'name': _nameController.text,
                        'amount': double.parse(_amountController.text),
                        'warranty': int.parse(_warrantyController.text),
                        'image': _image,
                      });
                    }
                  },
                  child: const Text('Add Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
