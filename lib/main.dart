import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Katalog Pink Pastel Full CRUD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB6C1),
          primary: const Color(0xFFE8A5B8),
          secondary: const Color(0xFFFCE4EC),
          surface: const Color(0xFFFFF5F7),
        ),
        useMaterial3: true,
      ),
      home: const ProductCatalogScreen(),
    );
  }
}

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  List allProducts = [];
  List filteredProducts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // 1. READ: Mengambil data dari API
  Future<void> fetchProducts() async {
    try {
      final url = Uri.parse('https://dummyjson.com/products');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allProducts = data['products'];
          filteredProducts = allProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 2. CREATE: Menambah produk baru ke API
  Future<void> addProduct(String title, String price) async {
    try {
      final url = Uri.parse('https://dummyjson.com/products/add');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'price': double.parse(price),
          'category': 'beauty',
          'thumbnail': 'https://i.dummyjson.com/data/products/1/thumbnail.jpg',
          'rating': 5.0,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newProduct = json.decode(response.body);
        setState(() {
          allProducts.insert(0, newProduct);
          filteredProducts = allProducts;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menambah produk!')),
        );
      }
    } catch (e) {
      print('Error Add: $e');
    }
  }

  // 3. UPDATE: Mengubah/Edit produk yang sudah ada ke API
  Future<void> updateProduct(int id, String title, String price) async {
    try {
      final url = Uri.parse('https://dummyjson.com/products/$id');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'price': double.parse(price)}),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Update data secara lokal di list
          final index = allProducts.indexWhere((item) => item['id'] == id);
          if (index != -1) {
            allProducts[index]['title'] = title;
            allProducts[index]['price'] = double.parse(price);
          }
          filteredProducts = allProducts;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil memperbarui produk!')),
        );
      }
    } catch (e) {
      print('Error Update: $e');
    }
  }

  // 4. DELETE: Menghapus produk dari API
  Future<void> deleteProduct(int id) async {
    try {
      final url = Uri.parse('https://dummyjson.com/products/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          filteredProducts.removeWhere((item) => item['id'] == id);
          allProducts.removeWhere((item) => item['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus!')),
        );
      }
    } catch (e) {
      print('Error Delete: $e');
    }
  }

  // Dialog Form Tambah Produk
  void showAddDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Produk Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga (\$)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8A5B8),
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  addProduct(titleController.text, priceController.text);
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Dialog Form Edit/Update Produk
  void showEditDialog(Map product) {
    final titleController = TextEditingController(text: product['title']);
    final priceController = TextEditingController(
      text: product['price'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga (\$)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8A5B8),
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  updateProduct(
                    product['id'],
                    titleController.text,
                    priceController.text,
                  );
                }
              },
              child: const Text(
                'Perbarui',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredProducts = allProducts
          .where(
            (item) =>
                item['title'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                item['category'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE8A5B8),
        foregroundColor: Colors.white,
        title: const Text(
          'Katalog Pink Pastel (Full CRUD)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE8A5B8),
        onPressed: showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8A5B8)),
            )
          : Column(
              children: [
                Container(
                  color: const Color(0xFFE8A5B8),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterSearchResults,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFE8A5B8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text('Produk tidak ditemukan.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                          child: Image.network(
                                            product['thumbnail'] ?? '',
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        // Tombol Hapus (Delete) & Edit (Update) di pojok kanan atas gambar
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Tombol Edit
                                              GestureDetector(
                                                onTap: () =>
                                                    showEditDialog(product),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withOpacity(0.8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.edit_outlined,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              // Tombol Hapus
                                              GestureDetector(
                                                onTap: () => deleteProduct(
                                                  product['id'],
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withOpacity(0.8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['title'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '\$${product['price']}',
                                          style: const TextStyle(
                                            color: Color(0xFFB0687E),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
