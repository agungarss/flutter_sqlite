import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/item_model.dart';
import '../widgets/add_product_modal.dart';
import '../fragment/detail.dart';

class HomeFragment extends StatefulWidget {
  final String username;
  final int userId;

  const HomeFragment({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Fungsi untuk me-refresh state dan membangun ulang UI
  Future<void> _refreshProducts() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Item>>(
              future: _dbHelper.getItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No products available',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  );
                }

                final filteredItems = snapshot.data!.where((item) {
                  return item.name.toLowerCase().contains(_searchQuery) ||
                      item.description.toLowerCase().contains(_searchQuery) ||
                      item.category.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No products match your search',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // Tampilan utama jika ada data
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ProductCard(
                      item: item,
                      onRefresh: _refreshProducts,
                      userId: widget.userId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Menampilkan modal untuk TAMBAH produk
          showDialog(
            context: context,
            builder: (context) => AddProductModal(
              onProductAdded: _refreshProducts,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// WIDGET UNTUK KARTU PRODUK (now Stateful)
class ProductCard extends StatefulWidget {
  final Item item;
  final VoidCallback onRefresh;
  final int userId; // Add this line

  const ProductCard({
    super.key,
    required this.item,
    required this.onRefresh,
    required this.userId, // Add this line
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.edit, color: Colors.white),
              ),
              title: const Text('Edit Product'),
              subtitle: Text(widget.item.name),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                showDialog(
                  context: context,
                  builder: (context) => AddProductModal(
                    item: widget.item,
                    onProductAdded: widget.onRefresh,
                  ),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              title: const Text('Delete Product'),
              subtitle: const Text('This action cannot be undone'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                _handleDelete(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteItem(widget.item.id!);
        widget.onRefresh();
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showProductDetails(context),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: Image.network(
                      widget.item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: const Color.fromARGB(255, 0, 0, 0),
                        onPressed: () => _showMoreOptions(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Detail Produk
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${widget.item.stock}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menampilkan dialog detail produk
  void _showProductDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          item: widget.item,
          userId: widget.userId, // Now we can use the userId
        ),
      ),
    );
  }
}
