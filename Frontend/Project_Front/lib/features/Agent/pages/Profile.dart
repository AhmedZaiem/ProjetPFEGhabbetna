import 'package:flutter/material.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:authproject/l10n/app_localizations.dart';
import 'package:authproject/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  String? error;

  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final result = await authService.getCurrentUser();
    if (result['success']) {
      setState(() => userData = result['data']);
    } else {
      setState(() => error = result['message']);
    }
  }

  void logout() async {
    await authService.logout();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.supervisor_profile),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) {
              switch (value) {
                case 'en':
                  (mainAppKey.currentState)?.setLocale(
                    const Locale('en', 'US'),
                  );
                  break;
                case 'fr':
                  (mainAppKey.currentState)?.setLocale(
                    const Locale('fr', 'FR'),
                  );
                  break;
                case 'ar':
                  (mainAppKey.currentState)?.setLocale(
                    const Locale('ar', 'AR'),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text("English")),
              const PopupMenuItem(value: 'fr', child: Text("Français")),
              const PopupMenuItem(value: 'ar', child: Text("العربية")),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: userData != null
          ? SingleChildScrollView(
              child: Column(
                children: [
                  // ── Hero header ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1B5E20),
                          const Color.fromARGB(255, 15, 56, 18),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${userData!['firstname']} ${userData!['lastname']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData!['email'] ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Info card ────────────────────────────────────────
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 6,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            children: [
                              _InfoRow(
                                icon: Icons.badge_outlined,
                                label: t.admin_cin,
                                value: userData!['cin']?.toString() ?? '—',
                              ),
                              _Divider(),
                              _InfoRow(
                                icon: Icons.alternate_email_rounded,
                                label: t.admin_username,
                                value: userData!['username']?.toString() ?? '—',
                              ),
                              _Divider(),
                              _InfoRow(
                                icon: Icons.cake_outlined,
                                label: t.admin_age,
                                value: userData!['age']?.toString() ?? '—',
                              ),
                              _Divider(),
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                label: t.admin_region,
                                value: userData!['region']?.toString() ?? '—',
                              ),
                              _Divider(),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                label: t.tel,
                                value: userData!['tel']?.toString() ?? '—',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Logout button ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: Text(
                          t.logout,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.red.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1B5E20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );
  }
}