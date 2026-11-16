import 'package:flutter/material.dart';

class VetPage extends StatefulWidget {
  final Function(Map<String, String>) onPostAnnouncement;

  const VetPage({super.key, required this.onPostAnnouncement});

  @override
  State<VetPage> createState() => _VetPageState();
}

class _VetPageState extends State<VetPage> {
  // Vet Profile Controllers
  final _vetNameController = TextEditingController(text: 'Dr. Kiptoo');
  final _vetPhoneController = TextEditingController(text: '0711223344');
  final _vetIdController = TextEditingController(text: '28475930');

  // Vaccination Log Controllers & State
  final _vaccineDateController = TextEditingController();
  final _flockSizeController = TextEditingController();
  final _preventiveMeasuresController = TextEditingController();
  String _selectedVaccine = 'PPR';
  int? _editingVaccineIndex;

  final List<String> _vaccineOptions = [
    'PPR',
    'Sheep pox',
    'Enterotoxemia/Pulpy kidney',
    'Tetanus',
    'Anthrax',
    'Foot and Mouth (FMD)',
    'Bluetongue',
  ];

  final List<Map<String, String>> _vaccinationLogs = [
    {
      'vaccine': 'PPR',
      'date': '2026-09-01',
      'flockSize': '45',
      'preventive': 'Annual flock mass vaccination against peste des petits ruminants.',
    },
    {
      'vaccine': 'Enterotoxemia/Pulpy kidney',
      'date': '2026-08-15',
      'flockSize': '38',
      'preventive': 'Booster dose prior to pasture seasonal transition.',
    },
  ];

  // Vet Announcement Controller
  final _announcementController = TextEditingController();

  // Appointment Controllers & State
  final _consultationFeeController = TextEditingController(text: '1500');
  final _farmerNameController = TextEditingController();
  final _appointmentReasonController = TextEditingController();
  final _appointmentDateController = TextEditingController();
  int? _editingAppointmentIndex;

  final List<Map<String, String>> _appointments = [
    {
      'farmer': 'Vincent (Farm #01)',
      'date': '2026-10-25',
      'reason': 'Routine flock pregnancy check & BCS assessment.',
      'fee': '1500',
    },
  ];

  // --- VACCINATION METHODS ---
  void _submitVaccinationRecord() {
    if (_vaccineDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the vaccination date')),
      );
      return;
    }

    final record = {
      'vaccine': _selectedVaccine,
      'date': _vaccineDateController.text.trim(),
      'flockSize': _flockSizeController.text.trim().isEmpty ? '0' : _flockSizeController.text.trim(),
      'preventive': _preventiveMeasuresController.text.trim().isEmpty
          ? 'General immunization session'
          : _preventiveMeasuresController.text.trim(),
    };

    setState(() {
      if (_editingVaccineIndex != null) {
        _vaccinationLogs[_editingVaccineIndex!] = record;
        _editingVaccineIndex = null;
      } else {
        _vaccinationLogs.insert(0, record);
      }
    });

    _clearVaccineForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vaccination record saved successfully!')),
    );
  }

  void _startEditingVaccine(int index) {
    final v = _vaccinationLogs[index];
    setState(() {
      _editingVaccineIndex = index;
      _selectedVaccine = _vaccineOptions.contains(v['vaccine']) ? v['vaccine']! : 'PPR';
      _vaccineDateController.text = v['date'] ?? '';
      _flockSizeController.text = v['flockSize'] ?? '';
      _preventiveMeasuresController.text = v['preventive'] ?? '';
    });
  }

  void _deleteVaccineRecord(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vaccination Record'),
        content: Text('Are you sure you want to remove the log for ${_vaccinationLogs[index]['vaccine']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _vaccinationLogs.removeAt(index);
                if (_editingVaccineIndex == index) _clearVaccineForm();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vaccination record deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearVaccineForm() {
    setState(() {
      _editingVaccineIndex = null;
      _selectedVaccine = 'PPR';
      _vaccineDateController.clear();
      _flockSizeController.clear();
      _preventiveMeasuresController.clear();
    });
  }

  // --- ANNOUNCEMENT METHOD ---
  void _postVetAnnouncement() {
    if (_announcementController.text.trim().isEmpty) return;

    widget.onPostAnnouncement({
      'title': 'Vet Advisory (${_vetNameController.text.trim()})',
      'date': DateTime.now().toString().split(' ')[0],
      'content': _announcementController.text.trim(),
    });

    _announcementController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vet advisory posted to Members View!')),
    );
  }

  // --- APPOINTMENT METHODS ---
  void _submitAppointment() {
    if (_appointmentDateController.text.trim().isEmpty || _appointmentReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter appointment date and reason')),
      );
      return;
    }

    final appt = {
      'farmer': _farmerNameController.text.trim().isEmpty ? 'General Member Visit' : _farmerNameController.text.trim(),
      'date': _appointmentDateController.text.trim(),
      'reason': _appointmentReasonController.text.trim(),
      'fee': _consultationFeeController.text.trim().isEmpty ? '0' : _consultationFeeController.text.trim(),
    };

    setState(() {
      if (_editingAppointmentIndex != null) {
        _appointments[_editingAppointmentIndex!] = appt;
        _editingAppointmentIndex = null;
      } else {
        _appointments.insert(0, appt);
      }
    });

    _clearAppointmentForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment saved successfully!')),
    );
  }

  void _startEditingAppointment(int index) {
    final a = _appointments[index];
    setState(() {
      _editingAppointmentIndex = index;
      _farmerNameController.text = a['farmer'] ?? '';
      _appointmentDateController.text = a['date'] ?? '';
      _appointmentReasonController.text = a['reason'] ?? '';
      _consultationFeeController.text = a['fee'] ?? '1500';
    });
  }

  void _deleteAppointment(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text('Are you sure you want to cancel the booking for ${_appointments[index]['farmer']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _appointments.removeAt(index);
                if (_editingAppointmentIndex == index) _clearAppointmentForm();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearAppointmentForm() {
    setState(() {
      _editingAppointmentIndex = null;
      _farmerNameController.clear();
      _appointmentDateController.clear();
      _appointmentReasonController.clear();
      _consultationFeeController.text = '1500';
    });
  }

  @override
  void dispose() {
    _vetNameController.dispose();
    _vetPhoneController.dispose();
    _vetIdController.dispose();
    _vaccineDateController.dispose();
    _flockSizeController.dispose();
    _preventiveMeasuresController.dispose();
    _announcementController.dispose();
    _consultationFeeController.dispose();
    _farmerNameController.dispose();
    _appointmentReasonController.dispose();
    _appointmentDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);
    const Color accentGreen = Color(0xFF2E7D32);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Solid Signature Green Vet Profile Banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.badge_outlined, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Veterinary Practitioner Profile',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Official practitioner credentials & contacts',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _vetNameController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: _buildGreenProfileDecoration('Vet Name', Icons.person_outline),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _vetPhoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: _buildGreenProfileDecoration('Phone Number', Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _vetIdController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: _buildGreenProfileDecoration('National ID', Icons.card_membership_outlined),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. Fancier Vaccination Schedules & Prevention Panel
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
                          child: Icon(_editingVaccineIndex != null ? Icons.edit : Icons.vaccines_outlined, color: primaryGreen),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _editingVaccineIndex != null ? 'Edit Vaccination Record' : 'Vaccination Schedules & Prevention',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                      ],
                    ),
                    if (_editingVaccineIndex != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: _clearVaccineForm,
                        tooltip: 'Cancel Editing',
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Vaccine Dropdown & Date & Flock Size
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _selectedVaccine,
                        items: _vaccineOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                        onChanged: (val) => setState(() => _selectedVaccine = val!),
                        decoration: const InputDecoration(
                          labelText: 'Vaccine Administered *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _vaccineDateController,
                        decoration: const InputDecoration(
                          labelText: 'Date (YYYY-MM-DD) *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _flockSizeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Flock Size (Heads)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _preventiveMeasuresController,
                  decoration: const InputDecoration(
                    labelText: 'Preventive Measures & Instructions',
                    hintText: 'e.g. Quarantining new stock, pasture transition guidance',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _editingVaccineIndex != null ? Colors.orange.shade800 : primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submitVaccinationRecord,
                    icon: Icon(_editingVaccineIndex != null ? Icons.save : Icons.add_moderator, color: Colors.white),
                    label: Text(
                      _editingVaccineIndex != null ? 'Update Vaccine Record' : 'Log Vaccine Schedule',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),

                const Divider(height: 28),
                const Text('Logged Vaccination Schedules:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryGreen)),
                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _vaccinationLogs.length,
                  itemBuilder: (context, index) {
                    final log = _vaccinationLogs[index];
                    final isEditing = _editingVaccineIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isEditing ? Colors.orange.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isEditing ? Colors.orange : Colors.grey.shade300,
                          width: isEditing ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: primaryGreen.withValues(alpha: 0.1),
                            child: const Icon(Icons.health_and_safety, color: primaryGreen, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      log['vaccine'] ?? '',
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
                                        'Flock: ${log['flockSize'] ?? '0'} Heads',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Date Administered: ${log['date']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                Text('Preventive Note: ${log['preventive']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                            onPressed: () => _startEditingVaccine(index),
                            tooltip: 'Edit Record',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _deleteVaccineRecord(index),
                            tooltip: 'Delete Record',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. Announcements Broadcast & Appointments Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Broadcast Advisory Card
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
                            child: const Icon(Icons.campaign_outlined, color: primaryGreen),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Post Vet Advisory',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('Broadcasts directly to the Members View noticeboard.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _announcementController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Type health alerts, dipping schedules, or emergency notices...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _postVetAnnouncement,
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          label: const Text('Post Advisory to Members', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Book Appointment & Consultation Fee Card
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
                                child: Icon(_editingAppointmentIndex != null ? Icons.edit_calendar : Icons.event_available_outlined, color: primaryGreen),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _editingAppointmentIndex != null ? 'Edit Appointment' : 'Book Vet Appointment',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen),
                              ),
                            ],
                          ),
                          if (_editingAppointmentIndex != null)
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: _clearAppointmentForm,
                              tooltip: 'Cancel Edit',
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _farmerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Farmer Name / Farm No',
                          hintText: 'e.g. Vincent (Farm #01)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _consultationFeeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Fee (KES)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _appointmentDateController,
                              decoration: const InputDecoration(
                                labelText: 'Date (YYYY-MM-DD)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _appointmentReasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason for Consultation',
                          hintText: 'e.g. Deworming session / Illness check',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _editingAppointmentIndex != null ? Colors.orange.shade800 : primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _submitAppointment,
                          icon: Icon(_editingAppointmentIndex != null ? Icons.save : Icons.add_task_outlined, color: Colors.white, size: 18),
                          label: Text(
                            _editingAppointmentIndex != null ? 'Update Appointment' : 'Book Appointment',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 4. Scheduled Appointments Log
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
                const Text('Scheduled Vet Appointments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appt = _appointments[index];
                    final isEditing = _editingAppointmentIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isEditing ? Colors.orange.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isEditing ? Colors.orange : Colors.grey.shade300,
                          width: isEditing ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: primaryGreen.withValues(alpha: 0.1),
                            child: const Icon(Icons.calendar_month, color: primaryGreen, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${appt['farmer']} — ${appt['date']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: primaryGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'KES ${appt['fee']}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Reason: ${appt['reason']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                            onPressed: () => _startEditingAppointment(index),
                            tooltip: 'Edit Appointment',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _deleteAppointment(index),
                            tooltip: 'Delete Appointment',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildGreenProfileDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
    );
  }
}