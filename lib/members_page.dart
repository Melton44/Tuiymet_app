import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _green = Color(0xFF1B5E20);

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(16),
    );

class MembersViewPage extends StatelessWidget {
  const MembersViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: _cardDecoration(),
            child: const TabBar(
              labelColor: _green,
              unselectedLabelColor: Colors.black54,
              indicatorColor: _green,
              tabs: [
                Tab(icon: Icon(Icons.campaign_outlined), text: 'Announcements'),
                Tab(icon: Icon(Icons.person_outline), text: 'My Profile'),
                Tab(icon: Icon(Icons.medical_services_outlined), text: 'Vet Appointments'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _AnnouncementsTab(),
                _ProfileTab(),
                _VetBookingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Announcements (read only)
// ---------------------------------------------------------------------------

class _AnnouncementsTab extends StatelessWidget {
  const _AnnouncementsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _message('Could not load announcements: ${snap.error}');
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return _message('No announcements yet.');
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign, color: _green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (d['title'] ?? '').toString(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: _green),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text((d['content'] ?? '').toString()),
                  const SizedBox(height: 8),
                  Text(
                    '${d['by'] ?? ''}  •  ${d['date'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Widget _message(String text) => Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );

// ---------------------------------------------------------------------------
// My profile (name and details editable; member no, farm no, rank locked)
// ---------------------------------------------------------------------------

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _name = TextEditingController();
  final _idNumber = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _flockSize = TextEditingController();
  String _gender = '';

  String _email = '';
  String _memberNo = '';
  String _farmNo = '';
  String _position = 'Member';

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _idNumber.dispose();
    _phone.dispose();
    _location.dispose();
    _flockSize.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Not signed in';
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final d = snap.data() ?? {};
      _name.text = (d['name'] ?? '').toString();
      _idNumber.text = (d['idNumber'] ?? '').toString();
      _phone.text = (d['phone'] ?? '').toString();
      _location.text = (d['location'] ?? '').toString();
      _flockSize.text = (d['flockSize'] ?? '').toString();
      _gender = (d['gender'] ?? '').toString();
      _email = (d['email'] ?? user.email ?? '').toString();
      _memberNo = (d['memberNo'] ?? '').toString();
      _farmNo = (d['farmNo'] ?? '').toString();
      _position = (d['position'] ?? 'Member').toString();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      _toast('Please enter your name.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _name.text.trim(),
        'idNumber': _idNumber.text.trim(),
        'phone': _phone.text.trim(),
        'location': _location.text.trim(),
        'flockSize': _flockSize.text.trim(),
        'gender': _gender,
      });
      _toast('Profile saved.');
    } catch (e) {
      _toast('Could not save profile: $e', error: true);
    }
    if (mounted) setState(() => _saving = false);
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : _green,
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      );

  Widget _locked(String label, String value, IconData icon) {
    return TextFormField(
      key: ValueKey('$label$value'),
      initialValue: value.isEmpty ? 'Not assigned yet' : value,
      enabled: false,
      style: const TextStyle(color: Colors.black54),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _message('Could not load your profile: $_error');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _green),
              ),
              const SizedBox(height: 4),
              const Text(
                'Greyed fields are set by the group officials and cannot be changed here.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _locked('Membership No', _memberNo, Icons.tag),
              const SizedBox(height: 12),
              _locked('Farm No', _farmNo, Icons.landscape_outlined),
              const SizedBox(height: 12),
              _locked('Group Rank', _position, Icons.badge_outlined),
              const SizedBox(height: 12),
              _locked('Email', _email, Icons.email_outlined),
              const SizedBox(height: 20),
              TextField(controller: _name, decoration: _decoration('Full Name', Icons.person_outline)),
              const SizedBox(height: 12),
              TextField(
                controller: _idNumber,
                decoration: _decoration('National ID', Icons.credit_card_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: _decoration('Phone Number', Icons.phone_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _location,
                decoration: _decoration('Location / Sub-County', Icons.location_on_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _flockSize,
                keyboardType: TextInputType.number,
                decoration: _decoration('Flock Size', Icons.pets_outlined),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey('gender$_gender'),
                initialValue: ['Male', 'Female'].contains(_gender) ? _gender : null,
                decoration: _decoration('Gender', Icons.wc_outlined),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? ''),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Book the vet
// ---------------------------------------------------------------------------

class _VetBookingTab extends StatefulWidget {
  const _VetBookingTab();

  @override
  State<_VetBookingTab> createState() => _VetBookingTabState();
}

class _VetBookingTabState extends State<_VetBookingTab> {
  final _farmer = TextEditingController();
  final _reason = TextEditingController();
  DateTime? _date;
  String _memberName = '';
  String _memberEmail = '';
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  @override
  void dispose() {
    _farmer.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _loadMember() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final d = snap.data() ?? {};
      _memberName = (d['name'] ?? '').toString();
      _memberEmail = (d['email'] ?? user.email ?? '').toString();
      final farmNo = (d['farmNo'] ?? '').toString();
      if (_farmer.text.isEmpty && _memberName.isNotEmpty) {
        _farmer.text = farmNo.isEmpty ? _memberName : '$_memberName / Farm $farmNo';
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : _green),
    );
  }

  Future<void> _book() async {
    if (_farmer.text.trim().isEmpty || _date == null || _reason.text.trim().isEmpty) {
      _toast('Please fill in your name / farm no, the date and the reason.', error: true);
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _booking = true);
    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'uid': user.uid,
        'memberName': _memberName.isNotEmpty ? _memberName : (user.email ?? ''),
        'memberEmail': _memberEmail,
        'farmerName': _farmer.text.trim(),
        'date': _fmt(_date!),
        'reason': _reason.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _reason.clear();
      setState(() => _date = null);
      _toast('Appointment requested. The vet has been notified.');
    } catch (e) {
      _toast('Could not book appointment: $e', error: true);
    }
    if (mounted) setState(() => _booking = false);
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'Confirmed':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Declined':
        return Colors.red;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.event_available, color: _green),
                  SizedBox(width: 8),
                  Text(
                    'Book Vet Appointment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _green),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(controller: _farmer, decoration: _decoration('Farmer Name / Farm No')),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _decoration('Preferred Date'),
                  child: Text(_date == null ? 'Pick a date' : _fmt(_date!)),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'The vet will review your request and set the consultation fee when approving.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reason,
                maxLines: 2,
                decoration: _decoration('Reason for Consultation'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _booking ? null : _book,
                  icon: _booking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Book Appointment'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Appointments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _green),
              ),
              const SizedBox(height: 8),
              if (uid == null)
                const Text('Please sign in.')
              else
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .where('uid', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Text('Could not load appointments: ${snap.error}');
                    }
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      );
                    }
                    final docs = snap.data!.docs.toList();
                    if (docs.isEmpty) {
                      return const Text('You have not booked any appointments yet.');
                    }
                    int stamp(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                        (d.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                        DateTime.now().millisecondsSinceEpoch;
                    docs.sort((a, b) => stamp(b).compareTo(stamp(a)));
                    return Column(
                      children: docs.map((doc) {
                        final d = doc.data();
                        final status = (d['status'] ?? 'Pending').toString();
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_note, color: _green),
                          title: Text('${d['date'] ?? ''}  •  ${d['reason'] ?? ''}'),
                          subtitle: Text(
                            d['fee'] == null
                                ? 'Fee: to be set by the vet'
                                : 'Fee: KES ${d['fee']}',
                          ),
                          trailing: Chip(
                            label: Text(status,
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: _statusColor(status),
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}