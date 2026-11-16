import 'package:flutter/material.dart';

class BreedingPage extends StatefulWidget {
  const BreedingPage({super.key});

  @override
  State<BreedingPage> createState() => _BreedingPageState();
}

class _BreedingPageState extends State<BreedingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample Ewe Breeding Records
  final List<Map<String, dynamic>> _eweRecords = [
    {
      'eweId': 'EWE-012',
      'ramId': 'RAM-005',
      'matingDate': '2026-05-20',
      'matingMethod': 'Natural',
      'age': '2 Years',
      'pregnancies': '2',
      'lambings': '1',
      'lambsBorn': 'Twins',
      'matingAttempts': '1',
      'heatDate': '2026-05-18',
      'pregnancyDiagnosis': 'Yes',
      'lastLambingDate': '2025-09-10',
      'reproductiveProblem': 'No',
      'pregnancyStatus': 'Yes',
    },
  ];

  // Sample Ram Breeding Records
  final List<Map<String, dynamic>> _ramRecords = [
    {
      'ramId': 'RAM-005',
      'age': '3 Years',
      'breed': 'Dorper',
      'bodyWeight': '78 kg',
      'bcs': '3.5 / 5',
      'breedingPerformance': 'Good',
      'ewesServed': '14',
      'sire': 'RAM-001',
      'dam': 'EWE-004',
      'dateIntroduced': '2025-01-15',
      'source': 'Farm',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- EWE MODAL FORM ---
  void _showAddEweDialog() {
    final eweIdController = TextEditingController();
    final ramIdController = TextEditingController();
    final matingDateController = TextEditingController();
    final ageController = TextEditingController();
    final pregnanciesController = TextEditingController();
    final lambingsController = TextEditingController();
    final attemptsController = TextEditingController();
    final heatDateController = TextEditingController();
    final lastLambingDateController = TextEditingController();

    String matingMethod = 'Natural';
    String lambsBorn = 'Single';
    String pregnancyDiagnosis = 'Yes';
    String reproductiveProblem = 'No';
    String pregnancyStatus = 'Yes';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          const primaryGreen = Color(0xFF1B5E20);

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                    'Record Ewe Breeding Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: eweIdController,
                          decoration: const InputDecoration(labelText: 'Ewe ID', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: ramIdController,
                          decoration: const InputDecoration(labelText: 'Ram ID', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: matingDateController,
                          decoration: const InputDecoration(
                            labelText: 'Mating Date (YYYY-MM-DD)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: matingMethod,
                          items: ['Natural', 'AI']
                              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (v) => setModalState(() => matingMethod = v!),
                          decoration: const InputDecoration(labelText: 'Mating Method', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ageController,
                          decoration: const InputDecoration(labelText: 'Age (e.g. 2 Yrs)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: pregnanciesController,
                          decoration: const InputDecoration(labelText: 'No. of Pregnancies', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lambingsController,
                          decoration: const InputDecoration(labelText: 'No. of Lambings', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: lambsBorn,
                          items: ['Single', 'Twins', 'Triplets']
                              .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                              .toList(),
                          onChanged: (v) => setModalState(() => lambsBorn = v!),
                          decoration: const InputDecoration(labelText: 'Lambs Born', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: attemptsController,
                          decoration: const InputDecoration(labelText: 'Mating Attempts', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: heatDateController,
                          decoration: const InputDecoration(labelText: 'Observed Heat Date', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: pregnancyDiagnosis,
                          items: ['Yes', 'No']
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (v) => setModalState(() => pregnancyDiagnosis = v!),
                          decoration: const InputDecoration(labelText: 'Pregnancy Diagnosis', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: pregnancyStatus,
                          items: ['Yes', 'No']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setModalState(() => pregnancyStatus = v!),
                          decoration: const InputDecoration(labelText: 'Pregnancy Status', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lastLambingDateController,
                          decoration: const InputDecoration(labelText: 'Last Lambing Date', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: reproductiveProblem,
                          items: ['Yes', 'No']
                              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) => setModalState(() => reproductiveProblem = v!),
                          decoration: const InputDecoration(labelText: 'Reproductive Problem', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                      onPressed: () {
                        setState(() {
                          _eweRecords.add({
                            'eweId': eweIdController.text.isEmpty ? 'EWE-NEW' : eweIdController.text,
                            'ramId': ramIdController.text.isEmpty ? 'RAM-NEW' : ramIdController.text,
                            'matingDate': matingDateController.text.isEmpty ? '2026-10-01' : matingDateController.text,
                            'matingMethod': matingMethod,
                            'age': ageController.text,
                            'pregnancies': pregnanciesController.text,
                            'lambings': lambingsController.text,
                            'lambsBorn': lambsBorn,
                            'matingAttempts': attemptsController.text,
                            'heatDate': heatDateController.text,
                            'pregnancyDiagnosis': pregnancyDiagnosis,
                            'lastLambingDate': lastLambingDateController.text,
                            'reproductiveProblem': reproductiveProblem,
                            'pregnancyStatus': pregnancyStatus,
                          });
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save Ewe Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- RAM MODAL FORM ---
  void _showAddRamDialog() {
    final ramIdController = TextEditingController();
    final ageController = TextEditingController();
    final breedController = TextEditingController();
    final weightController = TextEditingController();
    final bcsController = TextEditingController();
    final servedController = TextEditingController();
    final sireController = TextEditingController();
    final damController = TextEditingController();
    final introDateController = TextEditingController();

    String breedingPerformance = 'Good';
    String source = 'Farm';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          const primaryGreen = Color(0xFF1B5E20);

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                    'Record Ram Profile Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ramIdController,
                          decoration: const InputDecoration(labelText: 'Ram ID', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: ageController,
                          decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: breedController,
                          decoration: const InputDecoration(labelText: 'Breed', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          decoration: const InputDecoration(labelText: 'Body Weight (kg)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: bcsController,
                          decoration: const InputDecoration(labelText: 'Body Condition Score (1-5)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: breedingPerformance,
                          items: ['Good', 'Poor']
                              .map((bp) => DropdownMenuItem(value: bp, child: Text(bp)))
                              .toList(),
                          onChanged: (v) => setModalState(() => breedingPerformance = v!),
                          decoration: const InputDecoration(labelText: 'Breeding Performance', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: servedController,
                          decoration: const InputDecoration(labelText: 'No. of Ewes Served', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: source,
                          items: ['Farm', 'Borrowed', 'Transfer']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setModalState(() => source = v!),
                          decoration: const InputDecoration(labelText: 'Source', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: sireController,
                          decoration: const InputDecoration(labelText: 'Sire ID', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: damController,
                          decoration: const InputDecoration(labelText: 'Dam ID', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: introDateController,
                    decoration: const InputDecoration(labelText: 'Date Introduced (YYYY-MM-DD)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                      onPressed: () {
                        setState(() {
                          _ramRecords.add({
                            'ramId': ramIdController.text.isEmpty ? 'RAM-NEW' : ramIdController.text,
                            'age': ageController.text,
                            'breed': breedController.text,
                            'bodyWeight': weightController.text,
                            'bcs': bcsController.text,
                            'breedingPerformance': breedingPerformance,
                            'ewesServed': servedController.text,
                            'sire': sireController.text,
                            'dam': damController.text,
                            'dateIntroduced': introDateController.text,
                            'source': source,
                          });
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save Ram Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Calculate delivery date 5 months after mating
  String _calculateDeliveryDate(String matingDateStr) {
    try {
      final date = DateTime.parse(matingDateStr);
      final delivery = DateTime(date.year, date.month + 5, date.day);
      return '${delivery.year}-${delivery.month.toString().padLeft(2, '0')}-${delivery.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '5 Months Post-Mating';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: primaryGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: primaryGreen,
              tabs: const [
                Tab(icon: Icon(Icons.female), text: 'Ewe Registry'),
                Tab(icon: Icon(Icons.male), text: 'Ram Registry'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // EWE TAB
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ewe Breeding Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                            onPressed: _showAddEweDialog,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Add Ewe Record', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _eweRecords.length,
                        itemBuilder: (context, index) {
                          final ewe = _eweRecords[index];
                          final bool isPregnant = ewe['pregnancyDiagnosis'] == 'Yes' && ewe['pregnancyStatus'] == 'Yes';
                          final String expectedDelivery = _calculateDeliveryDate(ewe['matingDate']);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Ewe ID: ${ewe['eweId']} | Ram Served: ${ewe['ramId']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Chip(
                                      label: Text(
                                        isPregnant ? 'Pregnant' : 'Not Pregnant',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                      backgroundColor: isPregnant ? primaryGreen : Colors.grey,
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Text('Mating Method: ${ewe['matingMethod']} | Attempts: ${ewe['matingAttempts']} | Mating Date: ${ewe['matingDate']}'),
                                Text('Age: ${ewe['age']} | Pregnancies: ${ewe['pregnancies']} | Lambings: ${ewe['lambings']} | Lambs: ${ewe['lambsBorn']}'),
                                Text('Observed Heat: ${ewe['heatDate']} | Last Lambing: ${ewe['lastLambingDate']}'),
                                Text('Reproductive Issues: ${ewe['reproductiveProblem']}'),
                                if (isPregnant) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.amber.shade600),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.notifications_active, color: Colors.amber),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Delivery Alert: Expected Delivery on $expectedDelivery (5 Months Post-Mating)',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // RAM TAB
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ram Registry Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                            onPressed: _showAddRamDialog,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Add Ram Record', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _ramRecords.length,
                        itemBuilder: (context, index) {
                          final ram = _ramRecords[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Ram ID: ${ram['ramId']} (${ram['breed']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Chip(
                                      label: Text('Performance: ${ram['breedingPerformance']}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                      backgroundColor: ram['breedingPerformance'] == 'Good' ? primaryGreen : Colors.redAccent,
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Text('Age: ${ram['age']} | Weight: ${ram['bodyWeight']} | BCS: ${ram['bcs']}'),
                                Text('Ewes Served: ${ram['ewesServed']} | Source: ${ram['source']} | Date Intro: ${ram['dateIntroduced']}'),
                                Text('Pedigree: Sire (${ram['sire']}) x Dam (${ram['dam']})'),
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
          ),
        ],
      ),
    );
  }
}