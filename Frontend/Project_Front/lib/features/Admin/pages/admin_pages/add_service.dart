import 'package:flutter/material.dart';
import 'package:authproject/features/Admin/models/service_model.dart';
import 'package:authproject/features/Admin/services/service_methodes.dart';
import 'package:authproject/l10n/app_localizations.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final ServiceService serviceService = ServiceService();

  List<ServiceModel> services = [];
  bool loading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  ServiceModel? selectedService;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    setState(() => loading = true);

    try {
      final data = await serviceService.getServices();

      setState(() {
        services = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> createService() async {
    final loc = AppLocalizations.of(context)!;

    try {
      await serviceService.createService(
        name: nameController.text,
        type: typeController.text,
        description: descController.text,
      );

      clearFields();
      await loadServices();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.success_service_created)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.error_service)));
    }
  }

  Future<void> updateService() async {
    final loc = AppLocalizations.of(context)!;

    if (selectedService == null) return;

    try {
      await serviceService.updateService(
        selectedService!.id,
        name: nameController.text,
        type: typeController.text,
        description: descController.text,
      );

      clearFields();
      await loadServices();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.success_service_updated)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.error_service)));
    }
  }

  Future<void> deleteService(int id) async {
    final loc = AppLocalizations.of(context)!;

    try {
      await serviceService.deleteService(id);
      await loadServices();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.success_service_deleted)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.error_service)));
    }
  }

  void clearFields() {
    nameController.clear();
    typeController.clear();
    descController.clear();
    selectedService = null;
  }

  void fillFields(ServiceModel service) {
    setState(() {
      selectedService = service;
      nameController.text = service.name;
      typeController.text = service.type;
      descController.text = service.description ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/logoApp.jpeg', height: 36),
            ),
            const SizedBox(width: 12),
            Text(
              loc.admin_services,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: loc.admin_name,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: typeController,
                              decoration: InputDecoration(
                                labelText: loc.admin_type,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: descController,
                              decoration: InputDecoration(
                                labelText: loc.admin_description,
                              ),
                            ),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: createService,
                                    child: Text(loc.admin_create),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: updateService,
                                    child: Text(loc.admin_update),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: clearFields,
                                    child: Text(loc.admin_clear),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Expanded(
                        child: ListView.builder(
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.label, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${loc.admin_name} : ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(service.name),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        const Icon(Icons.category, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${loc.admin_type} : ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(service.type),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.description, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${loc.admin_description} : ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            service.description ?? '',
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () => fillFields(service),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              deleteService(service.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
