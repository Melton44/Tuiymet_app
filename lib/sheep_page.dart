import 'package:flutter/material.dart';

class SheepPage extends StatefulWidget {
  const SheepPage({super.key});

  @override
  State<SheepPage> createState() => _SheepPageState();
}

class _SheepPageState extends State<SheepPage> {
  final List<Map<String, dynamic>> _flockList = [
    {
      'tagNo': '089',
      'source': 'Birth',
      'breed': 'Dorper',
      'ageMonths': 14,
      'weight': 45.0,
      'damTag': 'TW-SH-012',
      'sireTag': 'TW-SH-004',
      'gender': 'Female',
      'status': 'Active',
      'dob': '2025-08-10',
      'lastUpdated': '2026-06-15',
    },
    {
      'tagNo': '090',
      'source': 'Purchase',
      'breed': 'Merino',
      'ageMonths': 8,
      'weight': 32.5,
      'damTag': 'TW-SH-005',
      'sireTag': 'N/A',
      'gender': 'Male',
      'status': 'Active',
      'dob': '2026-02-15',
      'lastUpdated': '2026-07-01',
    },
  ];

  String _calculateRecommendedFeed(int ageMonths) {
    if (ageMonths <= 3) {
      return 'Mother Milk & Starter Creep Feed';
    } else if (ageMonths <= 6) {
      return 'Alfalfa Hay';
    } else if (ageMonths <= 12) {
      return 'Rhodes Grass & Legume Hay';
    } else {
      return 'Rhodes Grass';
    }
  }

  // --- 1. FULL DETAILS DIALOG (Clicking Tile) ---
  void _showSheepDetails(Map<String, dynamic> sheep) {
    const primaryGreen = Color(0xFF1B5E20);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.pets, color: primaryGreen),
            const SizedBox(width: 8),
            Text('Sheep Profile: #TW-SH-${sheep['tagNo']}', style: const TextStyle(color: primaryGreen, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Tag Number', 'TW-SH-${sheep['tagNo']}'),
              _detailRow('Acquisition Source', sheep['source'] ?? 'N/A'),
              _detailRow('Breed', sheep['breed']),
              _detailRow('Age', '${sheep['ageMonths']} Months'),
              _detailRow('Current Weight', '${sheep['weight']} kg'),
              _detailRow('Gender', sheep['gender']),
              _detailRow('Status', sheep['status'] ?? 'Active'),
              _detailRow('Date of Birth', sheep['dob']?.isNotEmpty == true ? sheep['dob'] : 'N/A'),
              _detailRow('Dam Tag (Mother)', sheep['damTag']),
              _detailRow('Sire Tag (Father)', sheep['sireTag']),
              _detailRow('Place of Purchase', sheep['purchasePlace']?.isNotEmpty == true ? sheep['purchasePlace'] : 'N/A'),
              _detailRow('Body Condition Score', sheep['bcs'] != null ? 'Score ${sheep['bcs']}' : 'N/A'),
              _detailRow('Last Updated', sheep['lastUpdated'] ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  // --- 2. UPDATE DIALOG (Weight & Date Only - Rest Greyed Out) ---
  void _showUpdateWeightDialog(int index) {
    final sheep = _flockList[index];
    final weightController = TextEditingController(text: sheep['weight'].toString());
    final dateController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Update: Weight & Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 4),
            const Text(
              'All other fields are locked for this quick update.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Greyed out fields
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Tag Number (Locked)',
                hintText: 'TW-SH-${sheep['tagNo']}',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Breed (Locked)',
                hintText: sheep['breed'],
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 12),

            // Active editable fields
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Weight (kg) *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Update Date (YYYY-MM-DD) *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
                onPressed: () {
                  setState(() {
                    _flockList[index]['weight'] = double.tryParse(weightController.text.trim()) ?? sheep['weight'];
                    _flockList[index]['lastUpdated'] = dateController.text.trim();
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Weight updated and saved successfully!'), backgroundColor: Color(0xFF1B5E20)),
                  );
                },
                child: const Text('Save Weight Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. EDIT DIALOG (Full Edit of Everything) ---
  void _showEditSheepDialog(int index) {
    final sheep = _flockList[index];
    final tagController = TextEditingController(text: sheep['tagNo']);
    final breedController = TextEditingController(text: sheep['breed']);
    final ageController = TextEditingController(text: sheep['ageMonths'].toString());
    final weightController = TextEditingController(text: sheep['weight'].toString());
    final damController = TextEditingController(text: sheep['damTag']);
    final sireController = TextEditingController(text: sheep['sireTag']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Complete Sheep Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 16),
              TextField(controller: tagController, decoration: const InputDecoration(labelText: 'Tag Number', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: breedController, decoration: const InputDecoration(labelText: 'Breed', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age (Months)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: damController, decoration: const InputDecoration(labelText: 'Dam Tag', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: sireController, decoration: const InputDecoration(labelText: 'Sire Tag', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
                  onPressed: () {
                    setState(() {
                      _flockList[index] = {
                        ...sheep,
                        'tagNo': tagController.text.trim(),
                        'breed': breedController.text.trim(),
                        'ageMonths': int.tryParse(ageController.text.trim()) ?? sheep['ageMonths'],
                        'weight': double.tryParse(weightController.text.trim()) ?? sheep['weight'],
                        'damTag': damController.text.trim(),
                        'sireTag': sireController.text.trim(),
                        'lastUpdated': DateTime.now().toIso8601String().split('T')[0],
                      };
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sheep profile updated successfully!'), backgroundColor: Color(0xFF1B5E20)),
                    );
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddSheepModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddSheepBottomSheet(),
    ).then((newSheep) {
      if (newSheep != null && newSheep is Map<String, dynamic>) {
        setState(() {
          _flockList.add(newSheep);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag #TW-SH-${newSheep['tagNo']} registered successfully!'),
            backgroundColor: const Color(0xFF1B5E20),
          ),
        );
      }
    });
  }

  void _deleteSheep(int index) {
    setState(() => _flockList.removeAt(index));
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
            // Header Banner Card
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
                    child: const Icon(Icons.pets, color: primaryGreen, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tuiymet Ecofarmers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Livestock & Sheep Registry',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sheep Flock List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _flockList.length,
              itemBuilder: (context, index) {
                final item = _flockList[index];
                final String feed = _calculateRecommendedFeed(item['ageMonths'] ?? 12);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showSheepDetails(item), // Click tile to view ALL info
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tag #TW-SH-${item['tagNo']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: primaryGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Feed: $feed',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: primaryGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Update Button (Weight & Date Only)
                                    IconButton(
                                      icon: const Icon(Icons.update, color: Colors.blueAccent, size: 20),
                                      tooltip: 'Update Weight & Date',
                                      onPressed: () => _showUpdateWeightDialog(index),
                                    ),
                                    // Edit Button (Full Edit)
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: primaryGreen, size: 20),
                                      tooltip: 'Edit Profile',
                                      onPressed: () => _showEditSheepDialog(index),
                                    ),
                                    // Delete Button
                                    InkWell(
                                      onTap: () => _deleteSheep(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Breed: ${item['breed']}  |  Age: ${item['ageMonths']} Months  |  Weight: ${item['weight']}kg',
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mother Tag: ${item['damTag']} | Last Updated: ${item['lastUpdated'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        onPressed: () => _openAddSheepModal(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Sheep',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

// Modal Form Widget
class _AddSheepBottomSheet extends StatefulWidget {
  const _AddSheepBottomSheet();

  @override
  State<_AddSheepBottomSheet> createState() => _AddSheepBottomSheetState();
}

class _AddSheepBottomSheetState extends State<_AddSheepBottomSheet> {
  final _tagNoController = TextEditingController();
  final _weightController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _damController = TextEditingController();
  final _sireController = TextEditingController();
  final _purchasePlaceController = TextEditingController();

  String _selectedSource = 'Birth';
  String _selectedBreed = 'Dorper';
  String _selectedGender = 'Female';
  String _selectedStatus = 'Active';
  int _bodyConditionScore = 3;

  final List<String> _sources = ['Birth', 'Farm', 'Purchase', 'Transfer', 'Donation'];
  final List<String> _breeds = ['Dorper', 'Blackhead', 'Red Maasai', 'Merino', 'Other'];
  final List<String> _statuses = ['Active', 'Sold', 'Culled', 'Missing', 'Dead', 'Transferred'];

  void _submitForm() {
    if (_tagNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the Tag Number')),
      );
      return;
    }

    String formattedTag = _tagNoController.text.trim().padLeft(3, '0');
    int parsedAge = int.tryParse(_ageController.text.trim()) ?? 12;
    double parsedWeight = double.tryParse(_weightController.text.trim()) ?? 35.0;

    String dam = _damController.text.trim().isEmpty
        ? 'N/A'
        : 'TW-SH-${_damController.text.trim().padLeft(3, '0')}';
    String sire = _sireController.text.trim().isEmpty
        ? 'N/A'
        : 'TW-SH-${_sireController.text.trim().padLeft(3, '0')}';

    Navigator.pop(context, {
      'tagNo': formattedTag,
      'source': _selectedSource,
      'breed': _selectedBreed,
      'ageMonths': parsedAge,
      'weight': parsedWeight,
      'damTag': dam,
      'sireTag': sire,
      'gender': _selectedGender,
      'status': _selectedStatus,
      'dob': _dobController.text.trim(),
      'purchasePlace': _purchasePlaceController.text.trim(),
      'bcs': _bodyConditionScore,
      'lastUpdated': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  @override
  void dispose() {
    _tagNoController.dispose();
    _weightController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _damController.dispose();
    _sireController.dispose();
    _purchasePlaceController.dispose();
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
                  child: const Icon(Icons.pets, color: primaryGreen),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Register Livestock Sheep Record',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Acquisition Source Dropdown
            DropdownButtonFormField<String>(
              value: _selectedSource,
              items: _sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSource = val!),
              decoration: const InputDecoration(
                labelText: 'Acquisition Source *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.alt_route, color: primaryGreen),
              ),
            ),
            const SizedBox(height: 12),

            // Tag No & Breed
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagNoController,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    decoration: const InputDecoration(
                      hintText: '000 - 999',
                      labelText: 'Tag Number *',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBreed,
                    items: _breeds.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (val) => setState(() => _selectedBreed = val!),
                    decoration: const InputDecoration(labelText: 'Breed', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Weight & Gender
            Row(
              children: [
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
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: ['Female', 'Male'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setState(() => _selectedGender = val!),
                    decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dynamic Inputs
            if (_selectedSource == 'Birth') ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Months',
                        labelText: 'Age (Months)',
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
                      controller: _damController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      decoration: const InputDecoration(
                        hintText: '001 - 999',
                        labelText: 'Dam Tag (Mother)',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _sireController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      decoration: const InputDecoration(
                        hintText: '001 - 999',
                        labelText: 'Sire Tag (Father)',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_selectedSource == 'Purchase') ...[
              TextField(
                controller: _purchasePlaceController,
                decoration: const InputDecoration(
                  hintText: 'Market / Farm Name / Previous Owner',
                  labelText: 'Place of Purchase',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _bodyConditionScore,
                      items: [1, 2, 3, 4, 5].map((score) => DropdownMenuItem(value: score, child: Text('Score $score'))).toList(),
                      onChanged: (val) => setState(() => _bodyConditionScore = val!),
                      decoration: const InputDecoration(labelText: 'Body Condition (1-5)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: _statuses.map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Months',
                        labelText: 'Age in Months',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: _statuses.map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ],

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
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text(
                  'Add Sheep Record',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}