import 'package:flutter/material.dart';

class SecretaryPage extends StatefulWidget {
  final List<Map<String, String>> members;
  final List<Map<String, String>> announcements;
  final Function(Map<String, String>) onAddMember;
  final Function(int, Map<String, String>) onUpdateMember;
  final Function(int) onDeleteMember;
  final Function(Map<String, String>) onPostAnnouncement;

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
  final _memberNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _flockSizeController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmNoController = TextEditingController();
  final _announcementController = TextEditingController();

  String _gender = 'Female';
  String _rank = 'Chairperson';
  int? _editingIndex; // Null when registering, holds index when editing

  void _submitMember() {
    if (_memberNoController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Member No, Name, and National ID')),
      );
      return;
    }

    String formattedMemberNo = _memberNoController.text.trim();
    if (formattedMemberNo.length == 1) {
      formattedMemberNo = '0$formattedMemberNo';
    }

    String formattedFarmNo = _farmNoController.text.trim();
    if (formattedFarmNo.length == 1) {
      formattedFarmNo = '0$formattedFarmNo';
    }

    final memberData = {
      'memberNo': formattedMemberNo,
      'name': _nameController.text.trim(),
      'id': _idController.text.trim(),
      'phone': _phoneController.text.trim(),
      'flockSize': _flockSizeController.text.trim().isEmpty ? '0' : _flockSizeController.text.trim(),
      'location': _locationController.text.trim(),
      'farmNo': formattedFarmNo,
      'gender': _gender,
      'rank': _rank,
    };

    if (_editingIndex != null) {
      widget.onUpdateMember(_editingIndex!, memberData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member profile updated successfully!')),
      );
    } else {
      widget.onAddMember(memberData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member registered successfully!')),
      );
    }

    _clearForm();
  }

  void _startEditing(int index) {
    final m = widget.members[index];
    setState(() {
      _editingIndex = index;
      _memberNoController.text = m['memberNo'] ?? '';
      _nameController.text = m['name'] ?? '';
      _idController.text = m['id'] ?? '';
      _phoneController.text = m['phone'] ?? '';
      _flockSizeController.text = m['flockSize'] ?? '';
      _locationController.text = m['location'] ?? '';
      _farmNoController.text = m['farmNo'] ?? '';
      _gender = (m['gender'] == 'Male' || m['gender'] == 'Female') ? m['gender']! : 'Female';
      _rank = ['Chairperson', 'Treasurer', 'Secretary', 'Member'].contains(m['rank'])
          ? m['rank']!
          : 'Member';
    });
  }

  void _confirmDelete(int index) {
    final memberName = widget.members[index]['name'] ?? 'Member';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to remove $memberName from the registry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              widget.onDeleteMember(index);
              Navigator.pop(ctx);
              if (_editingIndex == index) {
                _clearForm();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$memberName removed')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingIndex = null;
      _memberNoController.clear();
      _nameController.clear();
      _idController.clear();
      _phoneController.clear();
      _flockSizeController.clear();
      _locationController.clear();
      _farmNoController.clear();
      _gender = 'Female';
      _rank = 'Chairperson';
    });
  }

  void _submitAnnouncement() {
    if (_announcementController.text.isEmpty) return;
    widget.onPostAnnouncement({
      'title': 'General Announcement',
      'date': DateTime.now().toString().split(' ')[0],
      'content': _announcementController.text.trim(),
    });
    _announcementController.clear();
  }

  @override
  void dispose() {
    _memberNoController.dispose();
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _flockSizeController.dispose();
    _locationController.dispose();
    _farmNoController.dispose();
    _announcementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);
    const Color accentGreen = Color(0xFF2E7D32);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Member Profile Form Panel
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _editingIndex != null ? Icons.edit_note : Icons.person_add_alt_1,
                                  color: primaryGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _editingIndex != null ? 'Edit Member Profile' : 'Tuiymet Member Profile',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  Text(
                                    _editingIndex != null ? 'Updating registered record' : 'Register credentials below',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (_editingIndex != null)
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: _clearForm,
                              tooltip: 'Cancel Edit',
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Member No & Farm No
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _memberNoController,
                              keyboardType: TextInputType.number,
                              maxLength: 2,
                              decoration: _buildInputDecoration('Member No (01-99) *', Icons.numbers, accentGreen),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _farmNoController,
                              keyboardType: TextInputType.number,
                              maxLength: 2,
                              decoration: _buildInputDecoration('Farm No (01-99)', Icons.landscape, accentGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Full Name
                      TextField(
                        controller: _nameController,
                        decoration: _buildInputDecoration('Full Name *', Icons.person_outline, accentGreen),
                      ),
                      const SizedBox(height: 12),

                      // National ID & Phone
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _idController,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration('National ID *', Icons.badge_outlined, accentGreen),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration('Phone Number', Icons.phone_outlined, accentGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Location & Flock Size
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _locationController,
                              decoration: _buildInputDecoration('Location / Sub-County', Icons.location_on_outlined, accentGreen),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _flockSizeController,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration('Flock Size', Icons.pets, accentGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Gender & Group Rank
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _gender,
                              items: ['Female', 'Male'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setState(() => _gender = val!),
                              decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _rank,
                              items: ['Chairperson', 'Treasurer', 'Secretary', 'Member'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setState(() => _rank = val!),
                              decoration: const InputDecoration(labelText: 'Group Rank', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _editingIndex != null ? Colors.orange.shade800 : primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _submitMember,
                          icon: Icon(_editingIndex != null ? Icons.save : Icons.check_circle_outline, color: Colors.white),
                          label: Text(
                            _editingIndex != null ? 'Update Member Record' : 'Register Member',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 2. Members Log Panel
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.people_outline, color: primaryGreen),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Registered Members Log',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.members.length,
                        itemBuilder: (context, index) {
                          final m = widget.members[index];
                          final isEditingThis = _editingIndex == index;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isEditingThis ? Colors.orange.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isEditingThis ? Colors.orange : Colors.grey.shade300,
                                width: isEditingThis ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: primaryGreen,
                                  child: Text(
                                    m['memberNo'] ?? '${index + 1}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            m['name'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: primaryGreen.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              m['rank'] ?? 'Member',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('ID: ${m['id']} • Phone: ${m['phone'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                      Text('Location: ${m['location'] ?? 'N/A'} • Farm #: ${m['farmNo'] ?? 'N/A'} • Flock: ${m['flockSize'] ?? '0'}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                  onPressed: () => _startEditing(index),
                                  tooltip: 'Edit Member',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => _confirmDelete(index),
                                  tooltip: 'Delete Member',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. Noticeboard Section
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Secretary Noticeboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen)),
                const Text('Write updates, meeting notes, or announcements for members.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(
                  controller: _announcementController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Type an announcement or update for group members...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                    onPressed: _submitAnnouncement,
                    icon: const Icon(Icons.send, color: Colors.white, size: 16),
                    label: const Text('Post Announcement', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, Color color) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: color, size: 20),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}