import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/service_controller.dart';
import '../../models/service.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen>
    with SingleTickerProviderStateMixin {
  late List<Service> _allServices;
  late List<Service> _filteredServices;
  String _query = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _allServices = [];
    _filteredServices = [];
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServices();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    final ctrl = context.read<ServiceController>();
    await ctrl.fetchServices();
    setState(() {
      _allServices = List.from(ctrl.services);
      _filteredServices = List.from(_allServices);
    });
  }

  void _filterServices(String query) {
    setState(() {
      _query = query;
      _filteredServices = _allServices
          .where((service) =>
              service.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _confirmDelete(Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final serviceController = context.read<ServiceController>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await serviceController.deleteService(service.id!);
      if (!mounted) return;
      setState(() {
        _allServices.removeWhere((item) => item.id == service.id);
        _filteredServices.removeWhere((item) => item.id == service.id);
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Service deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildServiceTile(Service service) {
    final initials = service.name.isNotEmpty
        ? service.name.trim().split(' ').map((e) => e[0]).join().substring(0, 1).toUpperCase()
        : 'S';

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.deepPurple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            service.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            service.description ?? 'No description',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                tooltip: 'Edit',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditServiceScreen(service: service),
                    ),
                  );
                  _loadServices();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(service),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Services',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: _loadServices,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterServices,
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Service'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddServiceScreen()),
                    );
                    _loadServices();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ServiceController>(
              builder: (context, controller, _) {
                if (controller.isLoading && _allServices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage != null && _allServices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 78, color: Colors.red.shade300),
                        const SizedBox(height: 18),
                        Text(
                          'Error: ${controller.errorMessage}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: _loadServices,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredServices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _query.isEmpty ? 'No services yet' : 'No services found',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (_query.isNotEmpty)
                          Text(
                            'Try another search term',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  itemCount: _filteredServices.length,
                  itemBuilder: (context, index) {
                    return _buildServiceTile(_filteredServices[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
