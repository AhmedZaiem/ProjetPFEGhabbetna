import 'package:flutter/material.dart';

import 'package:authproject/features/Admin/models/service_model.dart';
import 'package:authproject/features/Admin/services/service_methodes.dart';

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
      print(e);
      setState(() => loading = false);
    }
  }

  Future<void> createService() async {
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
      ).showSnackBar(const SnackBar(content: Text("Service created")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> updateService() async {
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
      ).showSnackBar(const SnackBar(content: Text("Service updated")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> deleteService(int id) async {
    try {
      await serviceService.deleteService(id);
      await loadServices();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Service deleted")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            const Text("Manage Services"),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1000,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      /// FORM
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
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
                              decoration: const InputDecoration(
                                labelText: "Name",
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: typeController,
                              decoration: const InputDecoration(
                                labelText: "Type",
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: descController,
                              decoration: const InputDecoration(
                                labelText: "Description",
                              ),
                            ),
                            const SizedBox(height: 24),

                            /// BUTTONS
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: createService,
                                    child: const Text("Create"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: updateService,
                                    child: const Text("Update"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: clearFields,
                                    child: const Text("Clear"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// LIST
                      Expanded(
                        child: ListView.builder(
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20, 
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                title: Text(service.name),
                                subtitle: Text(
                                  "${service.type} - ${service.description ?? ''}",
                                ),
                                onTap: () => fillFields(service),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteService(service.id),
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
