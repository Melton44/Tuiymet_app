import 'package:flutter/material.dart';
import 'pending_requests.dart';

class AdminPage extends StatefulWidget {
  final List<Map<String, dynamic>> memberRoles;
  final Map<String, List<int>> roleModuleAccess;
  final Function(int index, Map<String, dynamic> updated) onUpdateMemberRole;
  final Function(String role, List<int> updatedModules) onUpdateRoleModules;
  final Function(String newRole) onAddRole;

  const AdminPage({
    super.key,
    required this.memberRoles,
    required this.roleModuleAccess,
    required this.onUpdateMemberRole,
    required this.onUpdateRoleModules,
    required this.onAddRole,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newRoleController = TextEditingController();
  String _roleFilter = 'All';

  String _selectedExecutiveRole = 'Chairperson';
  String? _selectedMemberName;

  String _targetConfigRole = 'Chairperson';

  final List<Map<String, dynamic>> _allSystemModules = [
    {'index': 2, 'title': 'Secretary Desk', 'icon': Icons.edit_note},
    {'index': 3, 'title': 'Treasury Ledger', 'icon': Icons.account_balance_wallet},
    {'index': 4, 'title': 'Members View', 'icon': Icons.people_alt_outlined},
    {'index': 5, 'title': 'Sheep Livestock', 'icon': Icons.pets},
    {'index': 6, 'title': 'Vet Services', 'icon': Icons.medical_services_outlined},
    {'index': 7, 'title': 'Health Records', 'icon': Icons.health_and_safety_outlined},
    {'index': 8, 'title': 'Breeding Management', 'icon': Icons.family_restroom},
    {'index': 9, 'title': 'Management Notes', 'icon': Icons.menu_book_outlined},
    {'index': 10, 'title': 'Nutrition & Feeds', 'icon': Icons.set_meal_outlined},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _newRoleController.dispose();
    super.dispose();
  }

  void _handleDirectRoleAssignment() {
    if (_selectedMemberName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a member to assign the role.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final targetIndex = widget.memberRoles.indexWhere((m) => m['name'] == _selectedMemberName);

    if (targetIndex != -1) {
      final updated = Map<String, dynamic>.from(widget.memberRoles[targetIndex]);
      updated['rank'] = _selectedExecutiveRole;
      updated['isGranted'] = true;
      updated['hasPendingRequest'] = false;

      widget.onUpdateMemberRole(targetIndex, updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assigned $_selectedMemberName as $_selectedExecutiveRole'),
          backgroundColor: const Color(0xFF1B5E20),
        ),
      );

      setState(() {
        _selectedMemberName = null;
      });
    }
  }

  void _addNewRolePrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Custom Role'),
        content: TextField(
          controller: _newRoleController,
          decoration: const InputDecoration(labelText: 'Role Name (e.g., Farm Manager)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
            onPressed: () {
              final roleName = _newRoleController.text.trim();
              if (roleName.isNotEmpty) {
                widget.onAddRole(roleName);
                setState(() {
                  _targetConfigRole = roleName;
                  _selectedExecutiveRole = roleName;
                  _newRoleController.clear();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Created new role: $roleName'), backgroundColor: const Color(0xFF1B5E20)),
                );
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleModuleForRole(String role, int moduleIndex) {
    final currentModules = List<int>.from(widget.roleModuleAccess[role] ?? []);
    if (currentModules.contains(moduleIndex)) {
      currentModules.remove(moduleIndex);
    } else {
      currentModules.add(moduleIndex);
    }
    widget.onUpdateRoleModules(role, currentModules);
  }

  void _showRoleAssignmentModal(int index, Map<String, dynamic> member) {
    List<String> dynamicRoles = widget.roleModuleAccess.keys.toList();
    String currentRole = member['rank'] ?? 'Member';
    if (!dynamicRoles.contains(currentRole)) dynamicRoles.add(currentRole);

    bool currentAccess = member['isGranted'] ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          const primaryGreen = Color(0xFF1B5E20);

          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings, color: primaryGreen, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Access: ${member['name']}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                        Text(
                          'Membership No: ${member['memberNo']} | Farm No: ${member['farmNo']}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  initialValue: dynamicRoles.contains(currentRole) ? currentRole : dynamicRoles.first,
                  items: dynamicRoles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontWeight: FontWeight.bold))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => currentRole = val);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Assign Official Group Position',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text('Grant Portal Access Permission', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    currentAccess ? 'User can log in and view assigned modules.' : 'User access is LOCKED.',
                    style: TextStyle(fontSize: 12, color: currentAccess ? primaryGreen : Colors.redAccent),
                  ),
                  activeThumbColor: primaryGreen,
                  value: currentAccess,
                  onChanged: (val) {
                    setModalState(() => currentAccess = val);
                  },
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final updated = Map<String, dynamic>.from(member);
                      updated['rank'] = currentRole;
                      updated['isGranted'] = currentAccess;
                      updated['hasPendingRequest'] = false;

                      widget.onUpdateMemberRole(index, updated);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text('Save Permission & Role', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);
    final List<String> dynamicRoles = widget.roleModuleAccess.keys.toList();
    if (!dynamicRoles.contains(_selectedExecutiveRole)) {
      _selectedExecutiveRole = dynamicRoles.first;
    }
    if (!dynamicRoles.contains(_targetConfigRole)) {
      _targetConfigRole = dynamicRoles.first;
    }

    final filteredMembers = widget.memberRoles.where((m) {
      final query = _searchController.text.toLowerCase().trim();
      final nameMatches = (m['name'] ?? '').toLowerCase().contains(query);
      final phoneMatches = (m['phone'] ?? '').contains(query);
      final roleMatches = _roleFilter == 'All' || m['rank'] == _roleFilter;

      return (nameMatches || phoneMatches) && roleMatches;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings_outlined, color: primaryGreen, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Admin Control Panel',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Manage roles, assign positions, and configure dashboard tiles dynamically',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                  onPressed: _addNewRolePrompt,
                  icon: const Icon(Icons.add_moderator, color: Colors.white, size: 16),
                  label: const Text('Add New Role', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pending Access Requests (hidden when there are none)
          PendingRequestsCard(
            memberRoles: widget.memberRoles,
            onUpdateMemberRole: widget.onUpdateMemberRole,
          ),

          // Position Assignment Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.assignment_ind_outlined, color: primaryGreen),
                    SizedBox(width: 8),
                    Text(
                      'Assign Position to Member',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;
                    return Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(
                          flex: isMobile ? 0 : 4,
                          child: DropdownButtonFormField<String>(
                            value: _selectedExecutiveRole,
                            items: dynamicRoles
                                .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontWeight: FontWeight.bold))))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedExecutiveRole = val!),
                            decoration: const InputDecoration(
                              labelText: 'Target Position',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12, height: 12),
                        Expanded(
                          flex: isMobile ? 0 : 5,
                          child: DropdownButtonFormField<String>(
                            value: _selectedMemberName,
                            hint: const Text('Select a Member...'),
                            items: widget.memberRoles
                                .map((m) => DropdownMenuItem<String>(
                                      value: m['name'],
                                      child: Text('${m['name']} (Current: ${m['rank']})'),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedMemberName = val),
                            decoration: const InputDecoration(
                              labelText: 'Select Member',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12, height: 12),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _handleDirectRoleAssignment,
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Assign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Configure Dashboard Tiles Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.dashboard_customize, color: primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'Configure Dashboard Tiles per Role',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: _targetConfigRole,
                      items: dynamicRoles
                          .map((r) => DropdownMenuItem(value: r, child: Text('Role: $r', style: const TextStyle(fontWeight: FontWeight.bold))))
                          .toList(),
                      onChanged: (val) => setState(() => _targetConfigRole = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Select or deselect tiles below to add/remove them from the $_targetConfigRole dashboard:',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _allSystemModules.map((mod) {
                    final int idx = mod['index'];
                    final String title = mod['title'];
                    final List<int> currentActiveTiles = widget.roleModuleAccess[_targetConfigRole] ?? [];
                    final bool isEnabled = currentActiveTiles.contains(idx);

                    return FilterChip(
                      selected: isEnabled,
                      avatar: Icon(mod['icon'], size: 16, color: isEnabled ? Colors.white : primaryGreen),
                      label: Text(title, style: TextStyle(color: isEnabled ? Colors.white : primaryGreen, fontWeight: FontWeight.bold)),
                      selectedColor: primaryGreen,
                      checkmarkColor: Colors.white,
                      onSelected: (_) {
                        setState(() {
                          _toggleModuleForRole(_targetConfigRole, idx);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search member by name or phone...',
                      prefixIcon: Icon(Icons.search, color: primaryGreen),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _roleFilter,
                  items: ['All', ...dynamicRoles]
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setState(() => _roleFilter = val!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Member List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredMembers.length,
            itemBuilder: (context, index) {
              final member = filteredMembers[index];
              final bool isGranted = member['isGranted'] ?? false;
              final originalIndex = widget.memberRoles.indexOf(member);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isGranted ? primaryGreen.withValues(alpha: 0.3) : Colors.redAccent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isGranted ? primaryGreen.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                      child: Icon(
                        isGranted ? Icons.check_circle : Icons.lock,
                        color: isGranted ? primaryGreen : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                member['name'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(
                                  member['rank'] ?? 'Member',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                backgroundColor: primaryGreen,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Phone: ${member['phone']} | Farm No: ${member['farmNo']}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showRoleAssignmentModal(originalIndex, member),
                      icon: const Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                      label: const Text('Manage Access', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}