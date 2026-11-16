import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme.dart';

import 'sheep_page.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'secretary_page.dart';
import 'treasurer_page.dart';
import 'members_page.dart';
import 'vet_page.dart';
import 'health_records_page.dart';
import 'breeding_page.dart';
import 'admin_page.dart';
import 'notes_page.dart';
import 'nutrition_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TuiymetApp());
}

class TuiymetApp extends StatelessWidget {
  const TuiymetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuiymet Farmers Group',
      debugShowCheckedModeBanner: false,
      theme: toiwetTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.hasData
              ? const MainNavigationScreen()
              : const LoginPage();
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainNavigationScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _members = [
    {
      'memberNo': '01',
      'name': 'Vincent',
      'email': 'vincent@gmail.com',
      'id': '1087426',
      'phone': '0712345678',
      'flockSize': '24',
      'location': 'Tuiymet',
      'farmNo': '01',
      'gender': 'Male',
      'rank': 'Chairperson',
      'isGranted': true,
      'hasPendingRequest': false,
    },
    {
      'memberNo': '02',
      'name': 'Stacey',
      'email': 'stacey@gmail.com',
      'id': '4532172',
      'phone': '0723456789',
      'flockSize': '18',
      'location': 'Tuiymet',
      'farmNo': '03',
      'gender': 'Female',
      'rank': 'Treasurer',
      'isGranted': true,
      'hasPendingRequest': false,
    },
    {
      'memberNo': '03',
      'name': 'Melton',
      'email': 'melton@gmail.com',
      'id': '65376728',
      'phone': '0734567890',
      'flockSize': '30',
      'location': 'Tuiymet',
      'farmNo': '05',
      'gender': 'Male',
      'rank': 'Secretary',
      'isGranted': true,
      'hasPendingRequest': false,
    },
    {
      'memberNo': '04',
      'name': 'Kiprono',
      'email': 'kiprono@gmail.com',
      'id': '54321098',
      'phone': '0745678901',
      'flockSize': '12',
      'location': 'Tuiymet',
      'farmNo': '08',
      'gender': 'Male',
      'rank': 'Member',
      'isGranted': true,
      'hasPendingRequest': false,
    },
  ];

  final Map<String, List<int>> _roleModuleAccess = {
    'Chairperson': [],
    'Secretary': [],
    'Treasurer': [],
    'Vet': [],
    'Member': [],
  };

  final List<Map<String, dynamic>> _transactions = [
    {'title': 'bought a goat', 'date': '2026-09-21', 'amount': 54000.0, 'isCredit': true},
    {'title': 'Monthly Member Dues Collect', 'date': '2026-09-18', 'amount': 25000.0, 'isCredit': true},
    {'title': 'Veterinary Supplies Purchase', 'date': '2026-09-15', 'amount': 5000.0, 'isCredit': false},
  ];

  final List<Map<String, String>> _announcements = [
    {
      'title': 'Monthly Group Meeting',
      'date': '2026-09-20',
      'content': 'Please remember our monthly meeting is scheduled for this Saturday at 10 AM.',
    },
  ];

  double get _totalFunds {
    double total = 0;
    for (final tx in _transactions) {
      final double amount = (tx['amount'] as num).toDouble();
      if (tx['isCredit'] == true) {
        total += amount;
      } else {
        total -= amount;
      }
    }
    return total;
  }

  List<Map<String, String>> get _formattedMembersList {
    return _members.map<Map<String, String>>((m) {
      return {
        'memberNo': m['memberNo']?.toString() ?? '',
        'name': m['name']?.toString() ?? '',
        'id': m['id']?.toString() ?? '',
        'phone': m['phone']?.toString() ?? '',
        'flockSize': m['flockSize']?.toString() ?? '',
        'location': m['location']?.toString() ?? '',
        'farmNo': m['farmNo']?.toString() ?? '',
        'gender': m['gender']?.toString() ?? '',
        'rank': m['rank']?.toString() ?? 'Member',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    String loginType = 'Member';
    String userQuery = '';

    if (routeArgs is Map<String, dynamic>) {
      loginType = routeArgs['loginType'] ?? 'Member';
      userQuery = (routeArgs['email'] ?? '').toString().toLowerCase().trim();
    } else if (routeArgs is String) {
      loginType = routeArgs;
    }

    // After a page refresh there are no route arguments, so use the
    // signed-in Firebase account instead.
    if (userQuery.isEmpty) {
      userQuery =
          (FirebaseAuth.instance.currentUser?.email ?? '').toLowerCase().trim();
    }

    String activeRole = 'Member';
    bool isGranted = true;

    if (loginType == 'Admin') {
      activeRole = 'Admin';
      isGranted = true;
    } else if (userQuery.isNotEmpty) {
      final Map<String, dynamic> matchedUser = _members.firstWhere(
        (m) {
          final name = (m['name'] ?? '').toString().toLowerCase();
          final email = (m['email'] ?? '').toString().toLowerCase();
          final rank = (m['rank'] ?? '').toString().toLowerCase();
          return name.contains(userQuery) ||
              email.contains(userQuery) ||
              rank.contains(userQuery);
        },
        orElse: () => _members.firstWhere(
          (m) => m['rank'] == 'Member',
          orElse: () => _members.last,
        ),
      );

      activeRole = matchedUser['rank'] as String? ?? 'Member';
      isGranted = matchedUser['isGranted'] as bool? ?? true;
    } else {
      final Map<String, dynamic> defaultUser = _members.firstWhere(
        (m) => m['rank'] == 'Member',
        orElse: () => _members.last,
      );
      activeRole = defaultUser['rank'] as String? ?? 'Member';
      isGranted = defaultUser['isGranted'] as bool? ?? true;
    }

    final List<int> currentActiveIndexes =
        _roleModuleAccess[activeRole] ?? <int>[];

    final pages = <Widget>[
      DashboardPage(
        memberCount: _members.length,
        totalFunds: _totalFunds,
        userRole: activeRole,
        isGranted: isGranted,
        onSelectModule: (index) => setState(() => _currentIndex = index),
        membersList: _formattedMembersList,
        announcementsList: _announcements,
        activeModuleIndexes: currentActiveIndexes,
      ),
      AdminPage(
        memberRoles: _members,
        roleModuleAccess: _roleModuleAccess,
        onUpdateMemberRole: (index, updated) {
          setState(() => _members[index] = updated);
        },
        onUpdateRoleModules: (role, updatedModules) {
          setState(() {
            _roleModuleAccess[role] = List<int>.from(updatedModules);
          });
        },
        onAddRole: (newRole) {
          setState(() {
            _roleModuleAccess.putIfAbsent(newRole, () => <int>[]);
          });
        },
      ),
      SecretaryPage(
        members: _formattedMembersList,
        announcements: _announcements,
        onAddMember: (member) => setState(() => _members.add(member)),
        onUpdateMember: (index, updatedMember) =>
            setState(() => _members[index] = updatedMember),
        onDeleteMember: (index) => setState(() => _members.removeAt(index)),
        onPostAnnouncement: (announcement) =>
            setState(() => _announcements.insert(0, announcement)),
      ),
      TreasurerPage(
        transactions: _transactions,
        totalFunds: _totalFunds,
        onAddTransaction: (tx) => setState(() => _transactions.insert(0, tx)),
      ),
      const MembersViewPage(),
      SheepPage(),
      VetPage(
        onPostAnnouncement: (announcement) =>
            setState(() => _announcements.insert(0, announcement)),
      ),
      const healthRecordsPage(),
      const BreedingPage(),
      const NotesPage(),
      const NutritionPage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/sheep.jpeg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.18)),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (_currentIndex != 0) ...[
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
                              onPressed: () => setState(() => _currentIndex = 0),
                              tooltip: 'Back to Dashboard',
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            const Icon(Icons.eco, color: Color(0xFF1B5E20), size: 28),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _getScreenTitle(_currentIndex),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              activeRole,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color(0xFF1B5E20).withValues(alpha: 0.12),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (!context.mounted) return;
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            tooltip: 'Logout',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(child: pages[_currentIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard Workspace';
      case 1:
        return 'Admin Control Panel';
      case 2:
        return 'Secretary Workspace';
      case 3:
        return 'Treasurer Workspace';
      case 4:
        return 'Members View';
      case 5:
        return 'Sheep Management';
      case 6:
        return 'Vet Services';
      case 7:
        return 'Health Records';
      case 8:
        return 'Breeding Management';
      case 9:
        return 'Management Notes';
      case 10:
        return 'Nutrition and Feeds';
      default:
        return 'Dashboard';
    }
  }
}