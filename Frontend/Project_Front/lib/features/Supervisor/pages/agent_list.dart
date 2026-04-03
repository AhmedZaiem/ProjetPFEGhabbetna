import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:authproject/features/Supervisor/models/parcelleWithAgent.dart';
import 'package:authproject/features/Supervisor/services/supervisor_services.dart';
import 'package:authproject/features/Supervisor/models/agent.dart';

class AgentList extends StatefulWidget {
  const AgentList({super.key});

  @override
  State<AgentList> createState() => _AgentListState();
}

class _AgentListState extends State<AgentList> {
  List<Parcellewithagent> parcellesWithAgents = [];
  final SupervisorServices supervisorServices = SupervisorServices();
  final AuthService authService = AuthService();
  List<Agent> agents = [];
  List<Forest>? forests;
  String? error;
  Map<String, dynamic>? userData;

  Future<void> fetch() async {
    try {
      List<Parcellewithagent> fetchedParcellesWithAgents =
          await supervisorServices.getParcellesByForestIds([1, 2, 3]);
      setState(() {
        parcellesWithAgents = fetchedParcellesWithAgents;
        agents = fetchedParcellesWithAgents
            .where((p) => p.agent != null)
            .map((p) => p.agent!)
            .toList();
      });
    } catch (e) {
      print('Error fetching parcelles with agents: $e');
    }
  }

  Future<void> initData() async {
    final result = await authService.getCurrentUser();
    print('getCurrentUser result: $result');
    if (!result['success']) {
      setState(() => error = result['message']);
      return;
    }

    final user = result['data'];
    final supervisorId = user['id'];

    try {
      final fetchedForests = await supervisorServices.getforestsbySupervisorId(
        supervisorId,
      );
      print('Fetched forests: $fetchedForests');
      if (fetchedForests.isEmpty) {
        setState(() => error = 'No forests assigned to this supervisor.');
        return;
      }

      final forestIds = fetchedForests.map((f) => f.id).toList();
      final fetchedParcelles = await supervisorServices.getParcellesByForestIds(
        forestIds,
      );
      print('Fetched parcelles with agents: $fetchedParcelles');
      setState(() {
        userData = user;
        forests = fetchedForests;
        parcellesWithAgents = fetchedParcelles;
        agents = fetchedParcelles
            .where((p) => p.agent != null)
            .map((p) => p.agent!)
            .toList();
      });

      print('User Data: $userData');
      print('Forests: $forests');
    } catch (e) {
      setState(() => error = 'Failed to fetch forests: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agents List')),
      body: parcellesWithAgents.isEmpty && error == null
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : agents.isEmpty
          ? const Center(child: Text("No agents found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(2), // ID
                  1: FlexColumnWidth(3), // Name
                  2: FlexColumnWidth(4), // Email
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // 🔹 Header
                  const TableRow(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 212, 198, 198),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "ID",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Email",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // 🔹 Rows
                  ...agents.map<TableRow>((agent) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(agent.id.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(agent.name),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(agent.email),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
