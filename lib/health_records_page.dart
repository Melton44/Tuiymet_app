import 'package:flutter/material.dart';

class healthRecordsPage extends StatefulWidget {
  const healthRecordsPage({super.key});

  @override
  State<healthRecordsPage> createState() => _healthRecordsState();
}

class _healthRecordsState extends State<healthRecordsPage> {
  // Initial sample health logs matching your image style
  final List<Map<String, dynamic>> _healthLogs = [
    {
      'tagNo': 'TW-SH-089',
      'weight': '45.0',
      'symptomsDate': '2026-09-16',
      'clinicalSigns': 'Coughing & mild nasal discharge',
      'diagnosis': 'Pneumonia / Respiratory Infection',
      'drug': 'Oxytetracycline 20%',
      'dosage': '5ml',
      'route': 'Intramuscular',
      'withdrawalPeriod': '14 Days',
      'response': 'Good',
      'followUpDate': '2026-09-25',
      'vetName': 'Dr. Kiptoo',
      'vetPhone': '0711223344',
      'logDate': '18/09/2026',
    },
    {
      'tagNo': 'TW-SH-090',
      'weight': '32.5',
      'symptomsDate': '2026-09-10',
      'clinicalSigns': 'Lethargy & pale mucous membranes',
      'diagnosis': 'Haemonchosis (Barber pole worm)',
      'drug': 'Albendazole 10%',
      'dosage': '7.5ml',
      'route': 'Oral Drench',
      'withdrawalPeriod': '10 Days',
      'response': 'Better',
      'followUpDate': '2026-09-20',
      'vetName': 'Dr. Sarah',
      'vetPhone': '0722334455',
      'logDate': '12/09/2026',
    },
  ];

  void _openHealthLogModal({Map<String, dynamic>? initialData, int? editIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _HealthLogBottomSheet(initialData: initialData),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          if (editIndex != null) {
            _healthLogs[editIndex] = result;
          } else {
            _healthLogs.insert(0, result);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editIndex != null ? 'Health log updated!' : 'New health log recorded successfully!',
            ),
            backgroundColor: const Color(0xFF1B5E20),
          ),
        );
      }
    });
  }

  void _deleteLog(int index) {
    final log = _healthLogs[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medical Record'),
        content: Text('Are you sure you want to remove the log for ${log['drug']} (${log['tagNo']})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _healthLogs.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Health log removed')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services_outlined, color: primaryGreen, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Veterinary Services & Health Records',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Track animal treatments, dosages, and vet visits.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Health Log Cards List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _healthLogs.length,
              itemBuilder: (context, index) {
                final log = _healthLogs[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medical_information, color: primaryGreen, size: 24),
                    ),
                    title: Text(
                      '${log['drug']} (${log['tagNo']})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Dosage: ${log['dosage']} ${log['route']}',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Logged: ${log['logDate']}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                          onPressed: () => _openHealthLogModal(initialData: log, editIndex: index),
                          tooltip: 'Edit Log',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteLog(index),
                          tooltip: 'Delete Log',
                        ),
                      ],
                    ),
                    children: [
                      const Divider(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Weight', '${log['weight']} kg'),
                            _buildDetailRow('Symptoms Started', log['symptomsDate']),
                            _buildDetailRow('Clinical Signs', log['clinicalSigns']),
                            _buildDetailRow('Diagnosis', log['diagnosis']),
                            _buildDetailRow('Withdrawal Period', log['withdrawalPeriod']),
                            _buildDetailRow('Response to Meds', log['response']),
                            _buildDetailRow('Follow-up Date', log['followUpDate']),
                            _buildDetailRow('Veterinarian', '${log['vetName']} (${log['vetPhone']})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // Floating Add Medical Log Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        onPressed: () => _openHealthLogModal(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Log Health Record',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value == null || value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// Modal Sheet Form Widget
class _HealthLogBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const _HealthLogBottomSheet({this.initialData});

  @override
  State<_HealthLogBottomSheet> createState() => _HealthLogBottomSheetState();
}

class _HealthLogBottomSheetState extends State<_HealthLogBottomSheet> {
  final _tagNoController = TextEditingController();
  final _weightController = TextEditingController();
  final _symptomsDateController = TextEditingController();
  final _clinicalSignsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _drugController = TextEditingController();
  final _dosageController = TextEditingController();
  final _routeController = TextEditingController();
  final _withdrawalController = TextEditingController();
  final _followUpController = TextEditingController();
  final _vetNameController = TextEditingController();
  final _vetPhoneController = TextEditingController();

  String _response = 'Good';
  final List<String> _responseOptions = ['Good', 'Better', 'Poor'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _tagNoController.text = d['tagNo'] ?? '';
      _weightController.text = d['weight'] ?? '';
      _symptomsDateController.text = d['symptomsDate'] ?? '';
      _clinicalSignsController.text = d['clinicalSigns'] ?? '';
      _diagnosisController.text = d['diagnosis'] ?? '';
      _drugController.text = d['drug'] ?? '';
      _dosageController.text = d['dosage'] ?? '';
      _routeController.text = d['route'] ?? '';
      _withdrawalController.text = d['withdrawalPeriod'] ?? '';
      _followUpController.text = d['followUpDate'] ?? '';
      _vetNameController.text = d['vetName'] ?? '';
      _vetPhoneController.text = d['vetPhone'] ?? '';
      if (_responseOptions.contains(d['response'])) {
        _response = d['response'];
      }
    }
  }

  void _submitForm() {
    if (_tagNoController.text.isEmpty || _drugController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the Tag Number and Drug Administered')),
      );
      return;
    }

    String tag = _tagNoController.text.trim();
    if (!tag.startsWith('TW-SH-')) {
      tag = 'TW-SH-${tag.padLeft(3, '0')}';
    }

    final String todayDate = DateTime.now().toString().split(' ')[0].split('-').reversed.join('/');

    Navigator.pop(context, {
      'tagNo': tag,
      'weight': _weightController.text.trim(),
      'symptomsDate': _symptomsDateController.text.trim(),
      'clinicalSigns': _clinicalSignsController.text.trim(),
      'diagnosis': _diagnosisController.text.trim(),
      'drug': _drugController.text.trim(),
      'dosage': _dosageController.text.trim(),
      'route': _routeController.text.trim(),
      'withdrawalPeriod': _withdrawalController.text.trim(),
      'response': _response,
      'followUpDate': _followUpController.text.trim(),
      'vetName': _vetNameController.text.trim(),
      'vetPhone': _vetPhoneController.text.trim(),
      'logDate': widget.initialData?['logDate'] ?? todayDate,
    });
  }

  @override
  void dispose() {
    _tagNoController.dispose();
    _weightController.dispose();
    _symptomsDateController.dispose();
    _clinicalSignsController.dispose();
    _diagnosisController.dispose();
    _drugController.dispose();
    _dosageController.dispose();
    _routeController.dispose();
    _withdrawalController.dispose();
    _followUpController.dispose();
    _vetNameController.dispose();
    _vetPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medical_services, color: primaryGreen),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.initialData != null ? 'Edit Veterinary Health Record' : 'Log Veterinary Health Record',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Row 1: Tag No & Weight
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagNoController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 089 or TW-SH-089',
                      labelText: 'Animal Tag No *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 45.0',
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Symptoms Date & Clinical Signs
            TextField(
              controller: _symptomsDateController,
              decoration: const InputDecoration(
                hintText: 'YYYY-MM-DD',
                labelText: 'Date Symptoms Started',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clinicalSignsController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. Coughing, fever, nasal discharge',
                labelText: 'Clinical Signs Observed',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Diagnosis & Drug Administered
            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                hintText: 'e.g. Pneumonia',
                labelText: 'Diagnosis',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _drugController,
              decoration: const InputDecoration(
                hintText: 'e.g. Oxytetracycline 20% *',
                labelText: 'Drug Administered *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Dosage, Route, Withdrawal
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 5ml',
                      labelText: 'Dosage',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _routeController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Intramuscular',
                      labelText: 'Route',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _withdrawalController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 14 Days',
                      labelText: 'Withdrawal Period',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _response,
                    items: _responseOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                    onChanged: (val) => setState(() => _response = val!),
                    decoration: const InputDecoration(
                      labelText: 'Response to Meds',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Follow-up Date & Vet Details
            TextField(
              controller: _followUpController,
              decoration: const InputDecoration(
                hintText: 'YYYY-MM-DD',
                labelText: 'Follow-up Date',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _vetNameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Dr. Kiptoo',
                      labelText: 'Veterinary Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _vetPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 0711223344',
                      labelText: 'Vet Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submitForm,
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: Text(
                  widget.initialData != null ? 'Update Health Record' : 'Save Health Record',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}