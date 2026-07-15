import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../models/producto.dart';

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

class _ShopPageState extends State<ShopPage> with TickerProviderStateMixin {
  List<Producto> _products = [];
  List<Producto> _filteredProducts = [];
  final Map<String, _CartItem> _cart = {};
  final Set<String> _favorites = {};
  bool _isLoading = true;
  bool _isSearching = false;
  String _selectedCategory = "Todos";
  String _searchQuery = "";
  String _sortBy = "default"; // default, price_asc, price_desc, name
  final List<String> _categories = [
    "Todos",
    "Comida",
    "Salud",
    "Juguetes",
    "Aseo",
    "Accesorios",
    "Hogar"
  ];

  late AnimationController _aurora;
  late AnimationController _listAnim;
  late TextEditingController _searchController;

  // ─── Luxury Aurora Palette ───
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraAccent = Color(0xFF22D3EE);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDeep = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);
  static const Color _surfaceElevated = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _listAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _fetchProducts();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredProducts = _products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.nombre.toLowerCase().contains(_searchQuery) ||
          p.descripcion.toLowerCase().contains(_searchQuery) ||
          p.categoria.toLowerCase().contains(_searchQuery);
      final matchesCategory =
          _selectedCategory == "Todos" || p.categoria == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Aplicar ordenamiento
    switch (_sortBy) {
      case 'price_asc':
        _filteredProducts.sort((a, b) => a.precio.compareTo(b.precio));
        break;
      case 'price_desc':
        _filteredProducts.sort((a, b) => b.precio.compareTo(a.precio));
        break;
      case 'name':
        _filteredProducts.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
    }
  }

  // ─── Lógica de API preservada ───
  Future<void> _fetchProducts() async {
    try {
      final url = _selectedCategory == "Todos"
          ? "${AppConfig.baseUrl}/productos"
          : "${AppConfig.baseUrl}/productos/categoria/$_selectedCategory";

      final res = await http.get(Uri.parse(url));
      if (mounted) {
        setState(() {
          _products = (json.decode(res.body) as List)
              .map((e) => Producto.fromJson(e))
              .toList();
          _applyFilters();
          _isLoading = false;
        });
        _listAnim.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Gestión de carrito mejorada ───
  void _addToCart(Producto p) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_cart.containsKey(p.id)) {
        _cart[p.id]!.cantidad++;
      } else {
        _cart[p.id] = _CartItem(p);
      }
    });

    _showLuxurySnackBar(
      "${p.nombre} añadido",
      Icons.add_shopping_cart_rounded,
      _auroraBase,
    );
  }

  void _removeFromCart(String productId) {
    setState(() {
      _cart.remove(productId);
    });
  }

  void _updateQuantity(String productId, int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      final item = _cart[productId];
      if (item != null) {
        item.cantidad += delta;
        if (item.cantidad <= 0) {
          _cart.remove(productId);
        }
      }
    });
  }

  void _clearCart() {
    setState(() => _cart.clear());
    Navigator.pop(context);
  }

  int get _cartItemCount => _cart.values.fold(0, (sum, item) => sum + item.cantidad);
  double get _cartTotal => _cart.values.fold(
      0, (sum, item) => sum + (item.producto.precio * item.cantidad));

  // ─── Favoritos ───
  void _toggleFavorite(String productId) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_favorites.contains(productId)) {
        _favorites.remove(productId);
      } else {
        _favorites.add(productId);
      }
    });
  }

  bool _isFavorite(String productId) => _favorites.contains(productId);

  // ─── Snackbar Luxury ───
  void _showLuxurySnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: _surfaceElevated.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 0,
      ),
    );
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildCartSheet(),
    );
  }

  Widget _buildCartSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _bgDeep,
                _surfaceDark,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                children: [
                  // ─── Handle ───
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // ─── Header ───
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tu Carrito",
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$_cartItemCount ${_cartItemCount == 1 ? 'producto' : 'productos'}",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (_cart.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              _clearCart();
                            },
                            child: Text(
                              "Vaciar",
                              style: GoogleFonts.outfit(
                                color: Colors.redAccent.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // ─── Cart Items ───
                  Expanded(
                    child: _cart.isEmpty
                        ? _buildEmptyCart()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final entry = _cart.entries.elementAt(index);
                              final item = entry.value;
                              return _buildCartItem(item, setModalState);
                            },
                          ),
                  ),
                  // ─── Total & Checkout ───
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "\$${_cartTotal.toStringAsFixed(2)}",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              if (_cart.isNotEmpty) {
                                HapticFeedback.heavyImpact();
                                _simulatePurchase();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 64,
                              decoration: _cart.isEmpty
                                  ? BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                    )
                                  : BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [_auroraBase, _auroraAccent],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _auroraBase.withOpacity(0.4),
                                          blurRadius: 25,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                              child: Center(
                                child: Text(
                                  "COMPRAR AHORA",
                                  style: GoogleFonts.outfit(
                                    color: _cart.isEmpty
                                        ? Colors.white.withOpacity(0.3)
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white.withOpacity(0.2),
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Tu carrito está vacío",
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.4),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Explora nuestros productos premium",
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.2),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(_CartItem item, StateSetter setModalState) {
    final p = item.producto;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    p.imagenUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.white.withOpacity(0.05),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${p.precio}",
                        style: GoogleFonts.outfit(
                          color: _auroraBase,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // ─── Quantity Controls ───
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
            _buildQuantityButton(
              Icons.remove,
              () {
                setModalState(() => _updateQuantity(p.id, -1));
                setState(() {});
              },
            ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "${item.cantidad}",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
            _buildQuantityButton(
              Icons.add,
              () {
                setModalState(() => _updateQuantity(p.id, 1));
                setState(() {});
              },
            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.6),
          size: 16,
        ),
      ),
    );
  }

  void _simulatePurchase() {
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildProcessingDialog(),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      setState(() => _cart.clear());
      _showSuccessDialog();
    });
  }

  Widget _buildProcessingDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _surfaceDark.withOpacity(0.95),
              _bgDeep.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: _auroraBase.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                color: _auroraBase,
                strokeWidth: 3,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "Procesando pago...",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pasarela de pago segura",
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _surfaceDark.withOpacity(0.95),
                      _bgDeep.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF34D399), Color(0xFF10B981)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF34D399).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      "¡Compra Exitosa!",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tu pedido ha sido procesado. Recibirás un correo con los detalles de envío.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_auroraBase, _auroraAccent],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _auroraBase.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "VOLVER A LA TIENDA",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aurora.dispose();
    _listAnim.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDeep,
      extendBodyBehindAppBar: true,
      floatingActionButton: _cart.isNotEmpty
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: FloatingActionButton.extended(
                    onPressed: _showCart,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    label: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_auroraBase, _auroraAccent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _auroraBase.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_cart_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$_cartItemCount",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "\$${_cartTotal.toStringAsFixed(0)}",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : null,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildCategoryFilter(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchProducts,
                    color: _auroraBase,
                    backgroundColor: _surfaceDark,
                    child: _isLoading
                        ? _buildSkeletonGrid()
                        : _filteredProducts.isEmpty
                            ? _buildEmptyState()
                            : _buildProductGrid(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _aurora,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _bgDeep,
                HSLColor.fromAHSL(1.0, (_aurora.value * 360), 0.5, 0.05)
                    .toColor(),
                _bgDeep,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassIconButton(
            Icons.arrow_back_ios_new_rounded,
            () => Navigator.pop(context),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Luxury Shop",
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Productos Premium para Mascotas",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          _buildGlassIconButton(Icons.history_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSearching
                ? _auroraBase.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: _isSearching ? 1.5 : 1,
          ),
          boxShadow: _isSearching
              ? [
                  BoxShadow(
                    color: _auroraBase.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: TextField(
              controller: _searchController,
              onTap: () => setState(() => _isSearching = true),
              onSubmitted: (_) => setState(() => _isSearching = false),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 22,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _isSearching = false);
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withOpacity(0.3),
                          size: 20,
                        ),
                      )
                    : null,
                hintText: "Buscar productos...",
                hintStyle: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedCategory = cat;
                  _isLoading = true;
                });
                _fetchProducts();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: isSelected
                    ? BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_auroraBase, _auroraAccent],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _auroraBase.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                    : BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                child: Center(
                  child: Text(
                    cat,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.52,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 80)),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: _buildProductCard(product),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(Producto p) {
    final isFav = _isFavorite(p.id!);

    return GestureDetector(
      onTap: () => _showProductDetail(p),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Image ───
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(p.imagenUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // ─── Gradient overlay ───
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                _surfaceDark.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // ─── Category Badge ───
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _auroraBase.withOpacity(0.6),
                                _auroraAccent.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _auroraBase.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            p.categoria,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      // ─── Favorite Button ───
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _toggleFavorite(p.id!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: isFav
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFEF4444),
                                        Color(0xFFF87171),
                                      ],
                                    )
                                  : null,
                              color: isFav
                                  ? null
                                  : Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFav ? Colors.white : Colors.white.withOpacity(0.7),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ─── Info ───
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.nombre,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.descripcion,
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                height: 1.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "\$${p.precio.toStringAsFixed(0)}",
                                  style: GoogleFonts.outfit(
                                    color: _auroraBase,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (p.precio > 50)
                                  Text(
                                    "Envío gratis",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF34D399),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => _addToCart(p),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_auroraBase, _auroraAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _auroraBase.withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  void _showProductDetail(Producto p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _bgDeep,
              _surfaceDark,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            p.imagenUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_auroraBase, _auroraAccent],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                p.categoria,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.nombre,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.descripcion,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${p.precio.toStringAsFixed(2)}",
                              style: GoogleFonts.outfit(
                                color: _auroraBase,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _addToCart(p);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_auroraBase, _auroraAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _auroraBase.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.add_shopping_cart_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Añadir",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    color: Colors.white.withOpacity(0.2),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _searchQuery.isNotEmpty
                      ? "No encontramos resultados"
                      : "No hay productos disponibles",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? "Intenta con otros términos de búsqueda"
                      : "Vuelve pronto para ver nuevas novedades",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}