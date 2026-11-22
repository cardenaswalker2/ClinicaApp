import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/producto.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _CartItem {
  final Producto producto;
  int cantidad;
  _CartItem(this.producto, {this.cantidad = 1});
}

class _ShopPageState extends State<ShopPage> {
  List<Producto> _products = [];
  List<Producto> _filteredProducts = [];
  final Map<String, _CartItem> _cart = {};
  bool _isLoading = true;
  String _selectedCategory = "Todos";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ["Todos", "Comida", "Salud", "Juguetes", "Aseo", "Accesorios", "Hogar"];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final url = _selectedCategory == "Todos"
          ? "${AppConfig.baseUrl}/productos"
          : "${AppConfig.baseUrl}/productos/categoria/$_selectedCategory";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _products = (json.decode(res.body) as List).map((e) => Producto.fromJson(e)).toList();
          _applyFilters();
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final q = _searchQuery.toLowerCase();
    _filteredProducts = _products.where((p) {
      final matchesSearch = q.isEmpty ||
          p.nombre.toLowerCase().contains(q) ||
          p.descripcion.toLowerCase().contains(q);
      final matchesCat = _selectedCategory == "Todos" || p.categoria == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();
  }

  void _addToCart(Producto p) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_cart.containsKey(p.id)) {
        _cart[p.id]!.cantidad++;
      } else {
        _cart[p.id] = _CartItem(p);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${p.nombre} añadido al carrito")),
    );
  }

  double get _cartTotal => _cart.values.fold(0, (sum, item) => sum + item.producto.precio * item.cantidad);
  int get _cartCount => _cart.values.fold(0, (sum, item) => sum + item.cantidad);

  void _showCartSheet() {
    final fmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppleTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tu Carrito ($_cartCount)",
                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppleTheme.textPrimary),
              ),
              const SizedBox(height: 14),
              if (_cart.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text("El carrito está vacío.", style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary)),
                )
              else
                ..._cart.values.map((item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.producto.nombre, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                      subtitle: Text("${fmt.format(item.producto.precio)} x ${item.cantidad}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppleTheme.red),
                        onPressed: () {
                          setState(() => _cart.remove(item.producto.id));
                          setModalState(() {});
                        },
                      ),
                    )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(fmt.format(_cartTotal), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppleTheme.blue)),
                ],
              ),
              const SizedBox(height: 16),
              AppleButton(
                text: "Confirmar Pedido",
                onPressed: _cart.isEmpty
                    ? null
                    : () {
                        setState(() => _cart.clear());
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("¡Pedido confirmado con éxito!")),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Tienda Pet"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppleTheme.textPrimary),
                onPressed: _showCartSheet,
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppleTheme.blue, shape: BoxShape.circle),
                    child: Text(
                      "$_cartCount",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        color: AppleTheme.blue,
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            // Buscador
            Container(
              decoration: BoxDecoration(
                color: AppleTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppleTheme.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                  _applyFilters();
                }),
                decoration: InputDecoration(
                  hintText: "Buscar productos...",
                  hintStyle: GoogleFonts.plusJakartaSans(color: AppleTheme.textTertiary),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppleTheme.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Categorías
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final selected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppleTheme.textSecondary,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppleTheme.blue,
                    backgroundColor: AppleTheme.surface,
                    side: BorderSide(color: selected ? AppleTheme.blue : AppleTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                      _fetchProducts();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppleTheme.blue)))
            else if (_filteredProducts.isEmpty)
              AppleCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("No hay productos disponibles.", style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary)),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final p = _filteredProducts[index];
                  return AppleCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const AppleIconBox(icon: Icons.shopping_bag_rounded, color: AppleTheme.purple, size: 40),
                                AppleBadge(text: p.categoria, color: AppleTheme.blue),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              p.nombre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppleTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fmt.format(p.precio),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppleTheme.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () => _addToCart(p),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppleTheme.blue.withValues(alpha: 0.12),
                                  foregroundColor: AppleTheme.blue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  "Agregar",
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
