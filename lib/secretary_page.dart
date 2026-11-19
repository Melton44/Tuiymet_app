import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _green = Color(0xFF1B5E20);

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
    );

/// Secretary workspace.
///
/// Members sign up themselves. The Secretary completes their official records
/// (membership no, farm no and details) and posts announcements. The extra
/// constructor callbacks are kept so main.dart does not need to change.
class SecretaryPage extends StatefulWidget {
  final List<Map<String, String>> members;
  final List<Map<String, String>> announcements;
  final ValueChanged<Map<String, dynamic>> onAddMember;
  final void Function(int index, Map<String, dynamic> updated) onUpdateMember;
  final ValueChanged<int> onDeleteMember;
  final ValueChanged<Map<String, String>> onPostAnnouncement;

  const SecretaryPage({
    super.key,
    required this.members,
    required this.announcements,
    required this.onAddMember,
    required this.onUpdateMember,
    required this.onDeleteMember,
    required this.onPostAnnouncement,
  });

  @override
  State<SecretaryPage> createState() => _SecretaryPageState();
}

class _SecretaryPageState extends State<SecretaryPage> {
  final _memberNo = TextEditingController();
  final _farmNo = TextEditingController();
  final _name = TextEditingController();
  final _idNumber = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _flockSize = TextEditingController();
  String _gender = '';
  String? _selectedUid;
  bool _saving = false;

  final _noticeTitle = TextEditingController();
  final _noticeBody = TextEditingController();

  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _memberNo.dispose();
    _farmNo.dispose();
    _name.dispose();
    _idNumber.dispose();
    _phone.dispose();
    _location.dispose();
    _flockSize.dispose();
    _noticeTitle.dispose();
    _noticeBody.dispose();
    _search.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : _green),
    );
  }

  void _select(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    setState(() {
      _selectedUid = doc.id;
      _memberNo.text = (d['memberNo'] ?? '').toString();
      _farmNo.text = (d['farmNo'] ?? '').toString();
      _name.text = (d['name'] ?? '').toString();
      _idNumber.text = (d['idNumber'] ?? '').toString();
      _phone.text = (d['phone'] ?? '').toString();
      _location.text = (d['location'] ?? '').toString();
      _flockSize.text = (d['flockSize'] ?? '').toString();
      _gender = (d['gender'] ?? '').toString();
    });
  }

  void _clearForm() {
    setState(() {
      _selectedUid = null;
      _memberNo.clear();
      _farmNo.clear();
      _name.clear();
      _idNumber.clear();
      _phone.clear();
      _location.clear();
      _flockSize.clear();
      _gender = '';
    });
  }

  /// Returns a two-digit "01"-"99" string, '' for empty, or null if invalid.
  String? _twoDigits(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    final n = int.tryParse(t);
    if (n == null || n < 1 || n > 99) return null;
    return n.toString().padLeft(2, '0');
  }

  Future<void> _save(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    if (_selectedUid == null) {
      _toast('Select a member first.', error: true);
      return;
    }
    if (_name.text.trim().isEmpty) {
      _toast('Full name is required.', error: true);
      return;
    }
    final memberNo = _twoDigits(_memberNo.text);
    final farmNo = _twoDigits(_farmNo.text);
    if (memberNo == null || farmNo == null) {
      _toast('Member No and Farm No must be a number from 01 to 99.', error: true);
      return;
    }
    if (memberNo.isNotEmpty) {
      final taken = docs.any((d) =>
          d.id != _selectedUid && (d.data()['memberNo'] ?? '').toString() == memberNo);
      if (taken) {
        _toast('Member No $memberNo is already used by another member.', error: true);
        return;
      }
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(_selectedUid).update({
        'memberNo': memberNo,
        'farmNo': farmNo,
        'name': _name.text.trim(),
        'idNumber': _idNumber.text.trim(),
        'phone': _phone.text.trim(),
        'location': _location.text.trim(),
        'flockSize': _flockSize.text.trim(),
        'gender': _gender,
      });
      _toast('Member record saved.');
    } catch (e) {
      _toast('Could not save: $e', error: true);
    }
    if (mounted) setState(() => _saving = false);
  }

  void _postNotice() {
    final title = _noticeTitle.text.trim();
    final body = _noticeBody.text.trim();
    if (title.isEmpty || body.isEmpty) {
      _toast('Please add a title and a message.', error: true);
      return;
    }
    final today = DateTime.now().toIso8601String().substring(0, 10);
    widget.onPostAnnouncement({'title': title, 'date': today, 'content': body});
    _noticeTitle.clear();
    _noticeBody.clear();
    _toast('Announcement posted.');
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(),
              child: Text('Could not load members: ${snap.error}'),
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs
            .where((d) => (d.data()['role'] ?? 'Member') != 'Admin')
            .toList()
          ..sort((a, b) => (a.data()['name'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo((b.data()['name'] ?? '').toString().toLowerCase()));

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 900;
            final form = _buildForm(docs);
            final log = _buildLog(docs);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: form),
                      const SizedBox(width: 16),
                      Expanded(flex: 6, child: log),
                    ],
                  )
                else ...[
                  form,
                  const SizedBox(height: 16),
                  log,
                ],
                const SizedBox(height: 16),
                _buildNoticeboard(),
              ],
            );
          },
        );
      },
    );
  }

  // ---- Member record form ----

  Widget _buildForm(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_add_alt_1, color: _green),
              SizedBox(width: 8),
              Text(
                'Tuiymet Member Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _green),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Members sign up themselves. Select one to set their membership and farm number and complete their details.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey('sel$_selectedUid${docs.length}'),
            initialValue: docs.any((d) => d.id == _selectedUid) ? _selectedUid : null,
            isExpanded: true,
            decoration: _decoration('Select Member', Icons.search),
            items: docs
                .map((d) => DropdownMenuItem(
                      value: d.id,
                      child: Text(
                        '${d.data()['name'] ?? ''}  (${d.data()['email'] ?? ''})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (uid) {
              if (uid == null) return;
              _select(docs.firstWhere((d) => d.id == uid));
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _memberNo,
                  keyboardType: TextInputType.number,
                  decoration: _decoration('Member No (01-99)', Icons.tag),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _farmNo,
                  keyboardType: TextInputType.number,
                  decoration: _decoration('Farm No (01-99)', Icons.landscape_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: _name, decoration: _decoration('Full Name *', Icons.person_outline)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _idNumber,
                  decoration: _decoration('National ID', Icons.credit_card_outlined),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: _decoration('Phone Number', Icons.phone_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _location,
                  decoration: _decoration('Location / Sub-County', Icons.location_on_outlined),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _flockSize,
                  keyboardType: TextInputType.number,
                  decoration: _decoration('Flock Size', Icons.pets_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey('gender$_selectedUid$_gender'),
            initialValue: ['Male', 'Female'].contains(_gender) ? _gender : null,
            decoration: _decoration('Gender', Icons.wc_outlined),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
            ],
            onChanged: (v) => setState(() => _gender = v ?? ''),
          ),
          const SizedBox(height: 6),
          const Text(
            'Group rank and portal access are set by the System Administrator.',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saving ? null : () => _save(docs),
                    icon: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Save Member Record'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(onPressed: _clearForm, child: const Text('Clear')),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Registered members log ----

  Widget _buildLog(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty
        ? docs
        : docs.where((d) {
            final m = d.data();
            return (m['name'] ?? '').toString().toLowerCase().contains(q) ||
                (m['phone'] ?? '').toString().toLowerCase().contains(q) ||
                (m['email'] ?? '').toString().toLowerCase().contains(q);
          }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, color: _green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Registered Members Log (${docs.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: _green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search by name, phone or email...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const Divider(height: 24),
          if (shown.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('No members found yet.'),
            )
          else
            ...shown.map((doc) {
              final d = doc.data();
              final bool granted = (d['isGranted'] as bool?) ?? false;
              final String no = (d['memberNo'] ?? '').toString();
              final String farm = (d['farmNo'] ?? '').toString();
              final bool selected = doc.id == _selectedUid;
              return Card(
                color: selected ? const Color(0xFFE8F5E9) : Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => _select(doc),
                  leading: CircleAvatar(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    child: Text(no.isEmpty ? '--' : no),
                  ),
                  title: Text((d['name'] ?? '').toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Farm: ${farm.isEmpty ? '-' : farm}  •  ${d['phone'] ?? ''}\n'
                    '${d['location'] ?? ''}  •  Flock: ${d['flockSize'] ?? ''}  •  ${d['position'] ?? 'Member'}',
                  ),
                  isThreeLine: true,
                  trailing: Chip(
                    label: Text(granted ? 'Active' : 'Pending',
                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                    backgroundColor: granted ? Colors.green : Colors.orange,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ---- Noticeboard ----

  Widget _buildNoticeboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Secretary Noticeboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _green),
          ),
          const Text(
            'Write updates, meeting notes, or announcements for members.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noticeTitle,
            decoration: _decoration('Title', Icons.title),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noticeBody,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _postNotice,
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('Post Announcement'),
            ),
          ),
          if (widget.announcements.isNotEmpty) ...[
            const Divider(height: 28),
            const Text(
              'Recent announcements',
              style: TextStyle(fontWeight: FontWeight.bold, color: _green),
            ),
            const SizedBox(height: 8),
            ...widget.announcements.take(10).map(
                  (a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.campaign, color: _green),
                    title: Text(a['title'] ?? ''),
                    subtitle: Text(
                      '${a['content'] ?? ''}\n${a['by'] ?? ''}  •  ${a['date'] ?? ''}',
                    ),
                    isThreeLine: true,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}