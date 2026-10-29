import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Services/API_Aebloom.dart';
import 'login_page.dart';
import 'package:ae_bloom/model/aebloom_items.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _pinkColor = Color(0xFFD4778B);
  static const _greenColor = Color(0xFF2E4036);

  int _selectedBottomNavIndex = 0;
  late Future<List<ProductDatum>> _productsFuture;
  List<ProductDatum> _allProducts = [];
  List<ProductDatum> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  final List<FlowerOrder> _orders = [
    FlowerOrder(
      productName: 'Red Rose Bouquet',
      customerName: 'Sarah M.',
      quantity: 12,
      total: 1800,
      status: OrderStatus.preparing,
      createdAt: DateTime.now(),
    ),
    FlowerOrder(
      productName: 'Sunflower Bright Box',
      customerName: 'Mark T.',
      quantity: 1,
      total: 2400,
      status: OrderStatus.ready,
      createdAt: DateTime.now(),
    ),
    FlowerOrder(
      productName: 'Pink Tulip Arrangement',
      customerName: 'Anna K.',
      quantity: 1,
      total: 1950,
      status: OrderStatus.delivered,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<List<ProductDatum>> _loadProducts() async {
    final products = (await AEBloomApi().getProducts()).data;
    setState(() {
      _allProducts = products;
      _filteredProducts = products;
    });
    return products;
  }

  void _retryLoadingProducts() {
    setState(() => _productsFuture = _loadProducts());
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final nameMatch =
              product.productName.toLowerCase().contains(query.toLowerCase());
          final typeMatch =
              product.flowerType.toLowerCase().contains(query.toLowerCase());
          return nameMatch || typeMatch;
        }).toList();
      }
    });
  }

  Future<void> _openNewOrderForm([ProductDatum? initialProduct]) async {
    List<ProductDatum> products;
    try {
      products = await _productsFuture;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load products before creating an order.')),
      );
      return;
    }

    final inStockProducts = products.where((product) => product.inStock).toList();
    if (inStockProducts.isEmpty) return;
    final ProductDatum selectedProduct =
        initialProduct != null && initialProduct.inStock
            ? initialProduct
            : inStockProducts.first;

    final newOrder = await showDialog<FlowerOrder>(
      context: context,
      builder: (context) => _NewOrderDialog(
        products: inStockProducts,
        initialProduct: selectedProduct,
      ),
    );

    if (newOrder == null || !mounted) return;
    setState(() {
      _orders.insert(0, newOrder);
      _selectedBottomNavIndex = 2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order for ${newOrder.productName} was created.')),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AEBLOOM DASHBOARD',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        backgroundColor: _pinkColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new store notifications')),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: _pinkColor),
              accountName: const Text('AEBloom Manager'),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? 'admin@aebloom.com',
              ),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.local_florist, color: _pinkColor),
              ),
            ),
            _drawerItem(Icons.dashboard_outlined, 'Dashboard', 0),
            _drawerItem(Icons.local_florist_outlined, 'Products & Flowers', 1),
            _drawerItem(Icons.receipt_long_outlined, 'Order Management', 2),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: switch (_selectedBottomNavIndex) {
        0 => _buildDashboardView(),
        1 => _buildProductsView(),
        2 => _buildOrdersView(),
        _ => _buildAnalyticsView(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedBottomNavIndex,
        onDestinationSelected: (index) => setState(() => _selectedBottomNavIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.local_florist_outlined), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Sales'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewOrderForm,
        backgroundColor: _pinkColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int destination) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedBottomNavIndex == destination,
      onTap: () {
        Navigator.pop(context);
        setState(() => _selectedBottomNavIndex = destination);
      },
    );
  }

  Widget _buildDashboardView() {
    final pendingOrders = _orders.where((order) => order.status != OrderStatus.delivered).length;
    final sales = _orders.fold<double>(0, (total, order) => total + order.total);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Store Metrics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _greenColor)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _metricCard(Icons.monetization_on, 'Sales Total', _peso(sales))),
            const SizedBox(width: 12),
            Expanded(child: _metricCard(Icons.shopping_basket, 'Active Orders', '$pendingOrders Pending')),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Recent Flower Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _greenColor)),
        const SizedBox(height: 12),
        ..._orders.take(3).map(_orderCard),
      ],
    );
  }

  Widget _metricCard(IconData icon, String label, String value) {
    return Card(
      color: _pinkColor.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Icon(icon, color: _pinkColor, size: 30),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  // Service Catalog View with Search Filtering & Product List Mapping
  Widget _buildProductsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterProducts,
            decoration: InputDecoration(
              labelText: 'Search Flowers',
              hintText: 'e.g. Rose, Sunflower, Tulip...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterProducts('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ProductDatum>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: ElevatedButton.icon(
                    onPressed: _retryLoadingProducts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry loading products'),
                  ),
                );
              }
              if (_filteredProducts.isEmpty) {
                return const Center(
                  child: Text('No flower products matched your search.'),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filteredProducts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.productImage,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox(
                            width: 64,
                            child: Icon(Icons.local_florist, color: _pinkColor),
                          ),
                        ),
                      ),
                      title: Text(
                        product.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${product.flowerType}\n${_peso(product.price)}'),
                      trailing: product.inStock
                          ? FilledButton(
                              onPressed: () => _openNewOrderForm(product),
                              child: const Text('Order'),
                            )
                          : const Chip(label: Text('Out of stock')),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersView() {
    if (_orders.isEmpty) {
      return const Center(
        child: Text('No orders yet. Create your first flower order.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _orderCard(_orders[index]),
    );
  }

  Widget _orderCard(FlowerOrder order) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _pinkColor.withValues(alpha: 0.18),
          child: const Icon(Icons.local_florist, color: _pinkColor),
        ),
        title: Text('${order.productName} (${order.quantity} pcs)'),
        subtitle: Text('Customer: ${order.customerName}\n${_peso(order.total)}'),
        trailing: Chip(
          label: Text(order.status.label),
          backgroundColor: order.status.color,
        ),
      ),
    );
  }

  Widget _buildAnalyticsView() => const Center(child: Text('Sales & Analytics View'));

  String _peso(double amount) => '₱${amount.toStringAsFixed(2)}';
}

enum OrderStatus {
  preparing('Preparing', Colors.amberAccent),
  ready('Ready', Colors.lightGreenAccent),
  delivered('Delivered', Colors.black12);

  const OrderStatus(this.label, this.color);
  final String label;
  final Color color;
}

class FlowerOrder {
  const FlowerOrder({
    required this.productName,
    required this.customerName,
    required this.quantity,
    required this.total,
    required this.status,
    required this.createdAt,
  });
  final String productName;
  final String customerName;
  final int quantity;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
}

class _NewOrderDialog extends StatefulWidget {
  const _NewOrderDialog({
    required this.products,
    required this.initialProduct,
  });
  final List<ProductDatum> products;
  final ProductDatum initialProduct;

  @override
  State<_NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends State<_NewOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  late ProductDatum _selectedProduct;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.initialProduct;
  }

  @override
  void dispose() {
    _customerController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String _peso(double amount) => '₱${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final quantityInput = int.tryParse(_quantityController.text) ?? 0;
    final totalAmount = _selectedProduct.price * quantityInput;

    return AlertDialog(
      title: const Text('Create New Order'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductDatum>(
                value: _selectedProduct,
                decoration: const InputDecoration(labelText: 'Flower product'),
                items: widget.products
                    .map((product) => DropdownMenuItem(
                          value: product,
                          child: Text(product.productName),
                        ))
                    .toList(),
                onChanged: (product) => setState(() => _selectedProduct = product!),
              ),
              TextFormField(
                controller: _customerController,
                decoration: const InputDecoration(labelText: 'Customer name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the customer name.'
                    : null,
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                onChanged: (_) => setState(() {}),
                validator: (value) =>
                    int.tryParse(value ?? '') == null || int.parse(value!) < 1
                        ? 'Enter a quantity of at least 1.'
                        : null,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Order total: ${_peso(totalAmount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final quantity = int.parse(_quantityController.text);
            Navigator.pop(
              context,
              FlowerOrder(
                productName: _selectedProduct.productName,
                customerName: _customerController.text.trim(),
                quantity: quantity,
                total: _selectedProduct.price * quantity,
                status: OrderStatus.preparing,
                createdAt: DateTime.now(),
              ),
            );
          },
          child: const Text('Create order'),
        ),
      ],
    );
  }
}