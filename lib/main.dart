import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Fixes "Unable to establish connection on channel" on web
  FirebaseFirestore.instance.settings = const Settings(
    webExperimentalForceLongPolling: true,
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

  // ---- Live data from Firestore ----
  String _storedRole = 'Member'; // 'Admin' or 'Member' (access type)
  String _position = 'Member'; // Chairperson, Secretary, Treasurer, Vet, Member
  bool _isGranted = false; // set by the admin
  bool _roleLoaded = false;

  // ---- New member notifications ----
  final Set<String> _knownPendingUids = {};
  bool _usersInitialized = false;

  bool get _canSeeNotifications =>
      _storedRole == 'Admin' || _position == 'Secretary';

  /// Everyone who signed up (admins excluded). Filled from users/{uid}.
  List<Map<String, dynamic>> _members = [];

  /// role -> list of dashboard tile indexes. Saved in config/roleAccess.
  final Map<String, List<int>> _roleModuleAccess = {
    'Chairperson': [],
    'Secretary': [],
    'Treasurer': [],
    'Vet': [],
    'Member': [],
  };

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _ownSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _accessSub;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _ownSub?.cancel();
    _usersSub?.cancel();
    _accessSub?.cancel();
    super.dispose();
  }

  void _startListening() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _roleLoaded = true;
      return;
    }
    final db = FirebaseFirestore.instance;

    // 1. This account's own record (role, position, access granted)
    _ownSub = db.collection('users').doc(user.uid).snapshots().listen(
      (snap) {
        final d = snap.data();
        if (!mounted) return;
        setState(() {
          _storedRole = (d?['role'] as String?) ?? 'Member';
          _position = (d?['position'] as String?) ?? 'Member';
          _isGranted = (d?['isGranted'] as bool?) ?? false;
          _roleLoaded = true;
        });
      },
      onError: (_) {
        if (mounted) setState(() => _roleLoaded = true);
      },
    );

    // 2. Everyone who has signed up
    _usersSub = db.collection('users').snapshots().listen(
      (snap) {
        final list = <Map<String, dynamic>>[];
        for (final doc in snap.docs) {
          final d = doc.data();
          if ((d['role'] ?? 'Member') == 'Admin') continue;
          final email = (d['email'] ?? '').toString();
          final granted = (d['isGranted'] as bool?) ?? false;
          list.add({
            'uid': doc.id,
            'name': (d['name'] ??
                    (email.contains('@') ? email.split('@').first : 'Member'))
                .toString(),
            'email': email,
            'id': (d['idNumber'] ?? '').toString(),
            'phone': (d['phone'] ?? '').toString(),
            'flockSize': (d['flockSize'] ?? '').toString(),
            'location': (d['location'] ?? '').toString(),
            'farmNo': (d['farmNo'] ?? '').toString(),
            'gender': (d['gender'] ?? '').toString(),
            'rank': (d['position'] ?? 'Member').toString(),
            'isGranted': granted,
            'hasPendingRequest': !granted,
          });
        }
        list.sort((a, b) => (a['name'] as String)
            .toLowerCase()
            .compareTo((b['name'] as String).toLowerCase()));
        for (int i = 0; i < list.length; i++) {
          list[i]['memberNo'] = (i + 1).toString().padLeft(2, '0');
        }
        final pendingNow = list
            .where((m) => m['hasPendingRequest'] == true)
            .map((m) => m['uid'] as String)
            .toSet();

        // Toast for members who signed up while this screen is open
        if (_usersInitialized && _canSeeNotifications) {
          for (final m in list) {
            final uid = m['uid'] as String;
            if (pendingNow.contains(uid) && !_knownPendingUids.contains(uid)) {
              _showNewMemberToast(m['name'].toString());
            }
          }
        }
        _knownPendingUids
          ..clear()
          ..addAll(pendingNow);
        _usersInitialized = true;

        if (mounted) setState(() => _members = list);
      },
      onError: (_) {},
    );

    // 3. Which dashboard tiles each role can see
    _accessSub = db.collection('config').doc('roleAccess').snapshots().listen(
      (snap) {
        final d = snap.data();
        if (d == null || !mounted) return;
        setState(() {
          d.forEach((role, value) {
            if (value is List) {
              _roleModuleAccess[role] =
                  value.map<int>((e) => (e as num).toInt()).toList();
            }
          });
        });
      },
      onError: (_) {},
    );
  }

  // ---- Saving admin changes ----

  Future<void> _saveMember(String? uid, Map<String, dynamic> updated) async {
    if (uid == null || uid.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'position': updated['rank'] ?? 'Member',
        'isGranted': updated['isGranted'] ?? false,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save changes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveRoleAccess(String role, List<int> modules) async {
    try {
      await FirebaseFirestore.instance
          .collection('config')
          .doc('roleAccess')
          .set({role: modules}, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save tile access: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
    if (!_roleLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isAdmin = _storedRole == 'Admin';
    final String activeRole = isAdmin ? 'Admin' : _position;
    final bool isGranted = isAdmin ? true : _isGranted;
    final List<Map<String, dynamic>> pendingMembers =
        _members.where((m) => m['hasPendingRequest'] == true).toList();

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
          final String? uid =
              (updated['uid'] ?? _members[index]['uid'])?.toString();
          setState(() => _members[index] = {..._members[index], ...updated});
          _saveMember(uid, updated);
        },
        onUpdateRoleModules: (role, updatedModules) {
          final modules = List<int>.from(updatedModules);
          setState(() => _roleModuleAccess[role] = modules);
          _saveRoleAccess(role, modules);
        },
        onAddRole: (newRole) {
          setState(() {
            _roleModuleAccess.putIfAbsent(newRole, () => <int>[]);
          });
          _saveRoleAccess(newRole, _roleModuleAccess[newRole] ?? <int>[]);
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
                          if (_canSeeNotifications) ...[
                            Badge(
                              isLabelVisible: pendingMembers.isNotEmpty,
                              label: Text('${pendingMembers.length}'),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_outlined,
                                    color: Color(0xFF1B5E20)),
                                tooltip: 'New members',
                                onPressed: () => _showPendingDialog(pendingMembers),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
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

  void _showNewMemberToast(String name) {
    if (!mounted) return;
    final bool isAdmin = _storedRole == 'Admin';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New member signed up: $name'),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => setState(() => _currentIndex = isAdmin ? 1 : 2),
        ),
      ),
    );
  }

  void _showPendingDialog(List<Map<String, dynamic>> pending) {
    final bool isAdmin = _storedRole == 'Admin';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New members awaiting access'),
        content: SizedBox(
          width: 360,
          child: pending.isEmpty
              ? const Text('No new members right now.')
              : ListView(
                  shrinkWrap: true,
                  children: pending
                      .map(
                        (m) => ListTile(
                          leading: const Icon(Icons.person_add_alt_1,
                              color: Color(0xFF1B5E20)),
                          title: Text(m['name'].toString()),
                          subtitle: Text(m['email'].toString()),
                        ),
                      )
                      .toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          if (pending.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _currentIndex = isAdmin ? 1 : 2);
              },
              child: Text(isAdmin ? 'Open Admin Panel' : 'Open Secretary Desk'),
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