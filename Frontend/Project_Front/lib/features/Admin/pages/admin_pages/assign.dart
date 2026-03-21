import 'package:flutter/material.dart';


import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/models/parcelle_model.dart';
import 'package:authproject/features/Admin/services/forest_service.dart';
import 'package:authproject/features/Admin/services/parcelle_service.dart';
import 'package:authproject/features/Admin/services/user_service.dart';

class Assign extends StatefulWidget {
  const Assign({super.key});

  @override
  State<Assign> createState() => _AssignState();
}

class _AssignState extends State<Assign> {
  final ForestService forestService = ForestService();
  final ParcelService parcelService = ParcelService();
  final UserService userService = UserService();

  List<Forest> forests = [];
  List<Parcel> parcels = [];
  List<UserModel> unassignedSupervisor = [];
  List<UserModel> unassignedAgents = [];

  Forest? selectedForest;
  Parcel? selectedParcel;
  UserModel? selectedUserForForest;
  UserModel? selectedUserForParcel;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final allForests = await forestService.getForests();
      final fetchedForests = allForests
          .where((f) => f.supervisorId == null)
          .toList();
      print(
        'Unassigned forests: ${fetchedForests.map((f) => f.name).toList()}',
      );

      final allParcels = await parcelService.getParcels();
      final fetchedParcels = allParcels
          .where((p) => p.agentId == null)
          .toList();
      print(
        'Unassigned parcels: ${fetchedParcels.map((p) => p.name).toList()}',
      );



      final funassignedSupervisor = await userService.getSupervisors();
      print(
        'Unassigned supervisors: ${funassignedSupervisor.map((u) => u.username).toList()}',
      );

      final fetchedUnassignedAgents = await userService.getUnassignedAgents();
      print(
        'Unassigned agents: ${fetchedUnassignedAgents.map((u) => u.username).toList()}',
      );

      setState(() {
        forests = fetchedForests;
        parcels = fetchedParcels;
        unassignedSupervisor = funassignedSupervisor;
        unassignedAgents = fetchedUnassignedAgents;

        selectedForest = null;
        selectedParcel = null;
        selectedUserForForest = null;
        selectedUserForParcel = null;

        loading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => loading = false);
    }
  }

  Future<void> assignSupervisor() async {
    if (selectedForest == null || selectedUserForForest == null) return;

    try {
      await forestService.assignSupervisor(
        selectedForest!.id,
        selectedUserForForest!.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Supervisor assigned successfully")),
      );
      await loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> assignAgent() async {
    if (selectedParcel == null || selectedUserForParcel == null) return;

    try {
      await parcelService.assignAgent(
        selectedParcel!.id,
        selectedUserForParcel!.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agent assigned successfully")),
      );
      await loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      
    );
  }
}





