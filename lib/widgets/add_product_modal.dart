import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../database/database_helper.dart';

class AddProductModal extends StatefulWidget {
  final Function onProductAdded;
  final Item? item; // Add this line to accept existing item for editing

  const AddProductModal({
    Key? key,
    required this.onProductAdded,
    this.item, // Add this parameter
  }) : super(key: key);

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _animation;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing item data if editing
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _priceController.text = widget.item!.price.toString();
      _descriptionController.text = widget.item!.description;
      _stockController.text = widget.item!.stock.toString();
      _imageUrlController.text = widget.item!.imageUrl;
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final item = Item(
        id: widget.item?.id, // Include id if editing
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        stock: int.parse(_stockController.text),
        imageUrl: _imageUrlController.text,
        category: 'default',
      );

      try {
        if (widget.item == null) {
          await DatabaseHelper().insertItem(item);
        } else {
          await DatabaseHelper().updateItem(item);
        }
        if (mounted) {
          widget.onProductAdded();
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to ${widget.item == null ? 'add' : 'update'} product')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.add_shopping_cart, color: Colors.blue),
            const SizedBox(width: 10),
            const Text('Add New Product'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Product Name',
                    icon: Icons.shopping_bag,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _priceController,
                    label: 'Price',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _stockController,
                    label: 'Stock',
                    icon: Icons.inventory,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _imageUrlController,
                    label: 'Image URL',
                    icon: Icons.image,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
    );
  }
}
