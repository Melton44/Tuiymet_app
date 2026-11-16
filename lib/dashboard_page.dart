import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final int memberCount;
  final double totalFunds;
  final String userRole;
  final bool isGranted;
  final Function(int) onSelectModule;
  final List<Map<String, String>> membersList;
  final List<Map<String, String>> announcementsList;
  final List<int> activeModuleIndexes;

  const DashboardPage({
    super.key,
    required this.memberCount,
    required this.totalFunds,
    required this.userRole,
    required this.isGranted,
    required this.onSelectModule,
    required this.membersList,
    required this.announcementsList,
    required this.activeModuleIndexes,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);

    // Master list of all system modules
    final List<Map<String, dynamic>> allModules = [
      {
        'index': 1,
        'title': 'Admin Control Panel',
        'subtitle': 'Assign official positions and grant portal permissions.',
        'icon': Icons.admin_panel_settings,
        'color': const Color(0xFF1B5E20),
      },
      {
        'index': 2,
        'title': 'Secretary Desk',
        'subtitle': 'Manage member profiles and post official advisories.',
        'icon': Icons.edit_note,
        'color': const Color(0xFF2E7D32),
      },
      {
        'index': 3,
        'title': 'Treasury Ledger',
        'subtitle': 'Record transactions, dues, and monitor group cash flow.',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFF388E3C),
      },
      {
        'index': 4,
        'title': 'Members View',
        'subtitle': 'Read-only updates on advisories and group directory.',
        'icon': Icons.people_alt_outlined,
        'color': const Color(0xFF1B5E20),
      },
      {
        'index': 5,
        'title': 'Sheep Livestock',
        'subtitle': 'Track personal flock registry, breeding, and farm inventory.',
        'icon': Icons.pets,
        'color': const Color(0xFF43A047),
      },
      {
        'index': 6,
        'title': 'Vet Services',
        'subtitle': 'Vaccination schedules, consultations, and advisories.',
        'icon': Icons.medical_services_outlined,
        'color': const Color(0xFF2E7D32),
      },
      {
        'index': 7,
        'title': 'Health Records',
        'subtitle': 'Log treatments, symptoms, drugs, dosages, and follow-ups.',
        'icon': Icons.health_and_safety_outlined,
        'color': const Color(0xFF1B5E20),
      },
      {
  'index': 8,
  'title': 'Breeding Management',
  'subtitle': 'Manage ewe/ram mating, gestation alerts, and pedigree records.',
  'icon': Icons.family_restroom,
  'color': const Color(0xFF2E7D32),
      },
      {
  'index': 9,
  'title': 'Management Notes',
  'subtitle': 'Downloadable guides on housing, newborn care, and disease protocols.',
  'icon': Icons.menu_book_outlined,
  'color': const Color(0xFF1B5E20),
},
{
      'index': 10,
      'title': 'Nutrition & Feeds',
      'subtitle': 'Interactive DMI calculator and daily feed intake guides.',
      'icon': Icons.set_meal_outlined,
      'color': const Color(0xFF2E7D32),
    },
    ];

    // Filter tiles strictly matching the Admin's selected indexes for this role
    final visibleModules = userRole == 'Admin'
        ? allModules
        : allModules.where((m) => activeModuleIndexes.contains(m['index'])).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tuiymet Ecofarmers Hub',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Position: $userRole — Select an accessible workspace tile below.',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    Chip(
                      avatar: Icon(isGranted ? Icons.verified_user : Icons.lock, color: Colors.white, size: 16),
                      label: Text(userRole, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: isGranted ? primaryGreen : Colors.redAccent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Overview Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: primaryGreen.withValues(alpha: 0.12),
                            child: const Icon(Icons.group, color: primaryGreen),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Registered Members', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(
                                '$memberCount Active',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
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

              const SizedBox(height: 24),

              // Dynamic Tiles Dashboard Grid
              if (visibleModules.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.dashboard_customize_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No Workspace Modules Assigned',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'The System Administrator has not assigned any workspace tiles to this role yet.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleModules.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (context, index) {
                    final item = visibleModules[index];
                    return InkWell(
                      onTap: isGranted ? () => onSelectModule(item['index']) : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: isGranted ? 0.90 : 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  backgroundColor: (item['color'] as Color).withValues(alpha: 0.15),
                                  child: Icon(item['icon'], color: item['color']),
                                ),
                                Icon(isGranted ? Icons.arrow_forward_ios : Icons.lock, size: 16, color: Colors.grey),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['subtitle'],
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        if (!isGranted)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock_clock_outlined, size: 56, color: Colors.redAccent),
                      SizedBox(height: 16),
                      Text(
                        'Access Pending Admin Approval',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your portal access is currently restricted. Please ask the System Administrator to grant permissions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}