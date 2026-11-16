import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'I. Routine Management Practices',
      'icon': Icons.medical_services_outlined,
      'items': [
        {
          'heading': '1. Identification & Marking',
          'content': '• Ear Tagging: Primary method for individual identification, records, parentage, and health tracking.\n• Site: Place the tag securely in the middle third of the ear, avoiding major blood vessels.'
        },
        {
          'heading': '2. Tail Docking',
          'content': '• Purpose: Prevents flystrike (myiasis) caused by manure accumulation on hindquarters.\n• Timing: Performed during the first 1 to 2 weeks of life.\n• Method: Joint just below the caudal fold, leaving sufficient tail length to cover the vulva.'
        },
        {
          'heading': '3. Wool Trimming & Crutching',
          'content': '• Crutching: Trimming dirty wool around the tail, breech, and inner thighs to prevent maggot infestation.\n• Dagging: Removal of manure-encrusted wool.\n• Shearing: Done annually before warm weather or prior to lambing.'
        },
        {
          'heading': '4. Parasite Control (Deworming & Spraying)',
          'content': '• Deworming: Conducted every 2 to 3 months interval, or strategically timed around seasonal rain shifts. Rotate anthelmintic classes.\n• Spraying / Dipping: Frequency depends on tick, mite, or fly infestation levels and local vector density.'
        },
        {
          'heading': '5. Castration & Fattening',
          'content': '• Castration: Performed on young male lambs not intended for breeding to control unwanted mating and reduce aggression.\n• Selective Application: Not necessary for breeding rams.\n• Fattening Strategy: Market-bound sheep undergo targeted high-energy nutritional regimes 6-8 weeks prior to sale.'
        },
        {
          'heading': '6. Biosecurity: Quarantine & Isolation',
          'content': '• Quarantine: Hold newly introduced or returning animals in a dedicated quarantine facility for 21 to 30 days.\n• Isolation: Immediate separation of sheep showing clinical signs of contagious diseases with dedicated tools and footwear.'
        },
        {
          'heading': '7. House Sanitation & Disinfection',
          'content': '• Daily removal of manure and soiled bedding.\n• Periodic deep cleaning using approved broad-spectrum disinfectants after dry scraping and washing.'
        },
      ]
    },
    {
      'title': 'II. Newborn Lamb Management',
      'icon': Icons.child_care_outlined,
      'items': [
        {
          'heading': '1. Airway Clearance',
          'content': 'Immediately clear mucus and amniotic membranes from the newborn lamb’s nose and mouth.'
        },
        {
          'heading': '2. Colostrum Ingestion',
          'content': 'Ensure the lamb receives high-quality colostrum within the 1st to 2 hours of birth (minimum 10% of body weight in the first 24 hours).'
        },
        {
          'heading': '3. Navel Disinfection',
          'content': 'Dip or spray the umbilical cord stump immediately with 7% Tincture of Iodine or chlorhexidine.'
        },
        {
          'heading': '4. Navel Care & Clean Water',
          'content': 'Keep the navel clean and dry, inspecting daily for swelling. Provide clean, accessible drinking water at all times.'
        },
        {
          'heading': '5. Birth Recording',
          'content': 'Log birth weight, sex, dam ID, sire ID, date, and any delivery complications in the flock register.'
        },
      ]
    },
    {
      'title': 'III. Stage-Based Feeding, Flushing & Steaming Up',
      'icon': Icons.grass_outlined,
      'items': [
        {
          'heading': '1. Flushing Protocol (2 - 3 Weeks Before Mating)',
          'content': '• Timing: 2 - 3 weeks before mating.\n• Objective: Increase energy and nutrient intake to boost ovulation rate, multiple births, and conception percentages.\n• Recommended Feeds: Boma Rhodes, quality pasture, maize bran, sunflower seed cake, lucerne, and pellet concentrates.'
        },
        {
          'heading': '2. Steaming Up Protocol (4 - 6 Weeks Before Lambing)',
          'content': '• Timing: 4 - 6 weeks before lambing.\n• Objective: Increase feed quality and grain/protein supplementation to develop robust birth weights, stimulate strong colostrum and milk production, and prevent pregnancy toxemia (ketosis).\n• Recommended Feeds: Boma Rhodes, pasture, maize bran, sunflower seed cake, lucerne, and pellet concentrates.'
        },
        {
          'heading': '3. Newborn Lambs (0 - 2 Months)',
          'content': '• Essential Colostrum: Must access within the 1st to 2 hours of birth.\n• Hydration: Clean, fresh drinking water available daily.\n• Nutrition: Mother’s milk supplemented with starter creep feed.'
        },
        {
          'heading': '4. Weaners (2 - 4 Months)',
          'content': '• Forage & Roughage: Boma Rhodes hay, Napier grass, and Lucerne.\n• Concentrates: Specialized sheep pellets.\n• Hydration & Minerals: Constant fresh water and tailored mineral supplements.'
        },
        {
          'heading': '5. Growing Stage (4 - 6 Months Post-Weaning)',
          'content': '• Forage: Boma Rhodes hay and Napier grass.\n• Legumes & Energy: Lucerne, wheat bran, and maize germ (meal).\n• Minerals: Mineral pellets to support bone and muscle frame development.'
        },
        {
          'heading': '6. Finishers / Market Stage (6+ Months)',
          'content': '• High Energy Rations: Rhodes grass hay, commercial sheep finisher pellets, and energy concentrates (e.g., wheat bran).\n• Mineral Blocks & Supplements: Maclic mineral bricks, CKL, Maclic beef, and Anphos Bimeda molar blocks (red or white variants) for rapid weight gain and condition scoring.'
        },
      ]
    },
    {
      'title': 'IV. Housing & Facility Specifications',
      'icon': Icons.other_houses_outlined,
      'items': [
        {
          'heading': '1. Structural Design & Roof',
          'content': '• Roof Type: Slanted / Mono-pitch roof to direct rainwater runoff away.\n• Height: 2 to 3 meters clearance for adequate ventilation and heat dissipation.'
        },
        {
          'heading': '2. Flooring & Bedding',
          'content': '• Floor: Slatted or smooth concrete with a 2-3% slope for drainage.\n• Bedding: Dry straw, wood shavings, or sawdust for thermal insulation.'
        },
        {
          'heading': '3. Ventilation & Walls',
          'content': '• Windward Wall: One-sided solid wall built against prevailing wind direction.\n• Leeward Wall: Opposite side louvered or mesh-ventilated for steady airflow.'
        },
        {
          'heading': '4. Pens, Troughs & Fencing',
          'content': '• Separate Pens: Dedicated lambing, mating, isolation, and fattening pens.\n• Troughs: Elevated feed troughs (15-20 cm) and clean automated water troughs.\n• Predator Fencing: Secure perimeter fencing to safeguard against stray dogs and predators.'
        },
      ]
    },
    {
      'title': 'V. Supplementary Health Protocols & Water Requirements',
      'icon': Icons.health_and_safety_outlined,
      'items': [
        {
          'heading': '1. Daily Water Requirements',
          'content': 'Sheep require 2 to 4 liters of clean water daily per head, with increased intake during hot weather, late gestation, and heavy lactation.'
        },
        {
          'heading': '2. Hoof Care & Footbaths',
          'content': 'Inspect and trim hooves every 3 to 6 months. Use 10% Zinc Sulfate footbaths during wet seasons to prevent foot rot.'
        },
        {
          'heading': '3. Vaccination Schedule',
          'content': 'Administer multivalent clostridial vaccines (Pulpy Kidney, Tetanus). Booster pregnant ewes 4 weeks prior to lambing.'
        },
        {
          'heading': '4. Body Condition Scoring (BCS 1-5)',
          'content': '• Flushing/Breeding: BCS 3.0\n• Pregnancy: BCS 2.5 - 3.0\n• Lambing: BCS 3.0 - 3.5\n• Weaning: BCS 2.0 - 2.5'
        },
      ]
    },
  ];

  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Tuiymet Ecofarmers - Master Sheep Management Guide',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                  ),
                  pw.Text('Official Manual', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            ..._sections.map((section) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    color: PdfColors.green50,
                    child: pw.Text(
                      section['title'],
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  ...List<pw.Widget>.from((section['items'] as List).map((item) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            item['heading'],
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.black),
                          ),
                          pw.Text(item['content'], style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                        ],
                      ),
                    );
                  })),
                ],
              );
            }),
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('Master Feed Intake Reference Table (kg/day)', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 6),
            pw.Table.fromTextArray(
              headers: ['Feed Category / Item', '20 kg Sheep', '30 kg Sheep', '40 kg Sheep', '50 kg Sheep'],
              data: [
                ['Roughages & Fodder', '', '', '', ''],
                ['   Napier Grass', '3.0 – 3.5 kg', '4.5 – 5.0 kg', '6.0 – 6.5 kg', '7.5 – 8.0 kg'],
                ['   Boma Rhodes (Fresh)', '2.5 – 3.0 kg', '4.0 – 4.5 kg', '5.0 – 6.0 kg', '6.5 – 7.5 kg'],
                ['   Natural Pasture (Grazing)', 'Free grazing', 'Free grazing', 'Free grazing', 'Free grazing'],
                ['   Rhodes Grass Hay', '0.7 – 0.8 kg', '1.0 – 1.2 kg', '1.4 – 1.6 kg', '1.7 – 2.0 kg'],
                ['   Maize Stovers (Dry stalks/leaves)', '0.7 – 0.9 kg', '1.1 – 1.3 kg', '1.5 – 1.7 kg', '1.8 – 2.1 kg'],
                ['   Sorghum Stover', '0.7 – 0.9 kg', '1.1 – 1.3 kg', '1.5 – 1.7 kg', '1.8 – 2.1 kg'],
                ['   Lucerne / Alfalfa (Fresh)', '2.5 – 3.0 kg', '4.0 – 4.5 kg', '5.5 – 6.0 kg', '7.0 – 7.5 kg'],
                ['   Desmodium (Fresh)', '2.5 – 3.0 kg', '3.5 – 4.0 kg', '5.0 – 5.5 kg', '6.5 – 7.0 kg'],
                ['   Sweet Potato Vines (Fresh)', '3.0 – 3.5 kg', '4.5 – 5.0 kg', '6.0 – 6.5 kg', '7.5 – 8.0 kg'],
                ['Protein-Rich Feeds', '', '', '', ''],
                ['   Lucerne Hay', '0.6 – 0.8 kg', '1.0 – 1.1 kg', '1.3 – 1.5 kg', '1.6 – 1.8 kg'],
                ['   Desmodium (Dry Hay)', '0.6 – 0.8 kg', '0.9 – 1.1 kg', '1.2 – 1.4 kg', '1.5 – 1.7 kg'],
                ['   Calliandra Leaves (Fresh/Dry)', '0.3 – 0.5 kg', '0.5 – 0.8 kg', '0.7 – 1.0 kg', '0.9 – 1.2 kg'],
                ['   Sunflower Seedcake', '0.05 – 0.10 kg', '0.10 – 0.15 kg', '0.15 – 0.20 kg', '0.20 – 0.25 kg'],
                ['   Soyabean Meal', '0.05 – 0.10 kg', '0.10 – 0.15 kg', '0.15 – 0.20 kg', '0.20 – 0.25 kg'],
                ['   Canola Meal', '0.05 – 0.10 kg', '0.10 – 0.15 kg', '0.15 – 0.20 kg', '0.20 – 0.25 kg'],
                ['   Dairy Meal', '0.15 – 0.25 kg', '0.25 – 0.35 kg', '0.35 – 0.50 kg', '0.45 – 0.60 kg'],
                ['Energy-Rich & Concentrates', '', '', '', ''],
                ['   Crushed Maize', '0.15 – 0.25 kg', '0.20 – 0.35 kg', '0.30 – 0.50 kg', '0.40 – 0.60 kg'],
                ['   Maize Germ', '0.15 – 0.25 kg', '0.25 – 0.35 kg', '0.35 – 0.50 kg', '0.45 – 0.60 kg'],
                ['   Wheat Bran', '0.15 – 0.25 kg', '0.25 – 0.35 kg', '0.35 – 0.50 kg', '0.45 – 0.60 kg'],
                ['   Wheat Pollard', '0.15 – 0.25 kg', '0.20 – 0.35 kg', '0.30 – 0.45 kg', '0.40 – 0.55 kg'],
                ['   Rice Bran', '0.10 – 0.20 kg', '0.20 – 0.30 kg', '0.30 – 0.45 kg', '0.40 – 0.55 kg'],
                ['   Barley Grain', '0.10 – 0.20 kg', '0.20 – 0.30 kg', '0.30 – 0.45 kg', '0.40 – 0.55 kg'],
                ['   Sorghum Grain', '0.10 – 0.20 kg', '0.20 – 0.30 kg', '0.30 – 0.45 kg', '0.40 – 0.55 kg'],
                ['   Commercial Pellets', '0.20 – 0.30 kg', '0.30 – 0.45 kg', '0.40 – 0.60 kg', '0.50 – 0.75 kg'],
                ['Commercial Pellets', '', '', '', ''],
                ['   Commercial Lamb Grower Pellets', '0.20 – 0.35 kg', '0.35 – 0.50 kg', '0.50 – 0.65 kg', 'N/A (growing)'],
                ['   Sheep Pellets', '0.20 – 0.30 kg', '0.30 – 0.45 kg', '0.40 – 0.60 kg', '0.50 – 0.75 kg'],
                ['   Sheep Finisher Pellets', '0.20 – 0.30 kg', '0.30 – 0.45 kg', '0.40 – 0.60 kg', '0.50 – 0.75 kg'],
                ['Crop By-Products', '', '', '', ''],
                ['   Bean Haulm', '0.6 – 0.8 kg', '1.0 – 1.2 kg', '1.3 – 1.6 kg', '1.7 – 1.9 kg'],
                ['   Wheat Straw', '0.6 – 0.8 kg', '1.0 – 1.2 kg', '1.3 – 1.6 kg', '1.7 – 1.9 kg'],
                ['   Sunflower Residue', '0.5 – 0.7 kg', '0.8 – 1.0 kg', '1.1 – 1.4 kg', '1.4 – 1.7 kg'],
                ['   Vegetable Trimmings (Clean)', '2.5 – 3.0 kg', '4.0 – 4.5 kg', '5.5 – 6.0 kg', '7.0 – 7.5 kg'],
                ['   Maize Milling By-Products', '0.15 – 0.25 kg', '0.25 – 0.35 kg', '0.35 – 0.50 kg', '0.45 – 0.60 kg'],
                ['Mineral Supplements', '', '', '', ''],
                ['   Mineral Lick / Bone DCP', '10 – 15 g/day', '10 – 15 g/day', '15 – 20 g/day', '15 – 20 g/day'],
                ['   Salt Lick', 'Free choice block', 'Free choice block', 'Free choice block', 'Free choice block'],
                ['   Sheep Mineral Premix', '10 – 15 g/day', '10 – 15 g/day', '15 – 20 g/day', '15 – 20 g/day'],
                ['   Urea-Molasses Block', 'Max 50 g/day', 'Max 75 g/day', 'Max 100 g/day', 'Max 100 g/day'],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
              cellStyle: const pw.TextStyle(fontSize: 7),
              cellHeight: 16,
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
              },
            ),
          ];
        },
      ),
    );

    try {
      final bytes = await pdf.save();
      Directory? directory;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory.path}/Sheep_Management_Practices_Tuiymet.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded successfully to: $filePath'),
            backgroundColor: const Color(0xFF1B5E20),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header Action Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.menu_book_rounded, color: primaryGreen, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Management Notes & Feeding Guide',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                      label: const Text('Download PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
                  decoration: InputDecoration(
                    hintText: 'Search topic (e.g. flushing, steaming up, newborn, deworming)...',
                    prefixIcon: const Icon(Icons.search, color: primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),

          // Notes Accordion Sections & Feed Intake Table Viewer
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ..._sections.map((section) {
                  final List items = section['items'];
                  final filteredItems = items.where((item) {
                    final h = (item['heading'] ?? '').toString().toLowerCase();
                    final c = (item['content'] ?? '').toString().toLowerCase();
                    return h.contains(_searchQuery) || c.contains(_searchQuery);
                  }).toList();

                  if (_searchQuery.isNotEmpty && filteredItems.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: _searchQuery.isNotEmpty,
                      leading: CircleAvatar(
                        backgroundColor: primaryGreen.withValues(alpha: 0.12),
                        child: Icon(section['icon'], color: primaryGreen),
                      ),
                      title: Text(
                        section['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 16),
                      ),
                      children: (filteredItems.isEmpty ? items : filteredItems).map((item) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['heading'],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['content'],
                                style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),

                // Interactive Fancy Master Feed Intake Table Card inside App
                Container(
                  margin: const EdgeInsets.only(bottom: 24, top: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: primaryGreen.withValues(alpha: 0.12),
                            child: const Icon(Icons.table_chart_rounded, color: primaryGreen),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Master Feed Intake Reference Table',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Daily intake quantities organized by weight category and feed type (3%-4% body weight dry matter requirement):',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(primaryGreen.withValues(alpha: 0.1)),
                          columns: const [
                            DataColumn(label: Text('Feed Category / Item', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))),
                            DataColumn(label: Text('20 kg', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))),
                            DataColumn(label: Text('30 kg', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))),
                            DataColumn(label: Text('40 kg', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))),
                            DataColumn(label: Text('50 kg', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))),
                          ],
                          rows: const [
                            // Roughages & Fodder
                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Roughages & Fodder', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Napier Grass'))), DataCell(Text('3.0 – 3.5 kg')), DataCell(Text('4.5 – 5.0 kg')), DataCell(Text('6.0 – 6.5 kg')), DataCell(Text('7.5 – 8.0 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Boma Rhodes (Fresh)'))), DataCell(Text('2.5 – 3.0 kg')), DataCell(Text('4.0 – 4.5 kg')), DataCell(Text('5.0 – 6.0 kg')), DataCell(Text('6.5 – 7.5 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Natural Pasture (Grazing)'))), DataCell(Text('Free grazing')), DataCell(Text('Free grazing')), DataCell(Text('Free grazing')), DataCell(Text('Free grazing'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Rhodes Grass Hay'))), DataCell(Text('0.7 – 0.8 kg')), DataCell(Text('1.0 – 1.2 kg')), DataCell(Text('1.4 – 1.6 kg')), DataCell(Text('1.7 – 2.0 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Maize Stovers (Dry stalks/leaves)'))), DataCell(Text('0.7 – 0.9 kg')), DataCell(Text('1.1 – 1.3 kg')), DataCell(Text('1.5 – 1.7 kg')), DataCell(Text('1.8 – 2.1 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sorghum Stover'))), DataCell(Text('0.7 – 0.9 kg')), DataCell(Text('1.1 – 1.3 kg')), DataCell(Text('1.5 – 1.7 kg')), DataCell(Text('1.8 – 2.1 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Lucerne / Alfalfa (Fresh)'))), DataCell(Text('2.5 – 3.0 kg')), DataCell(Text('4.0 – 4.5 kg')), DataCell(Text('5.5 – 6.0 kg')), DataCell(Text('7.0 – 7.5 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Desmodium (Fresh)'))), DataCell(Text('2.5 – 3.0 kg')), DataCell(Text('3.5 – 4.0 kg')), DataCell(Text('5.0 – 5.5 kg')), DataCell(Text('6.5 – 7.0 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sweet Potato Vines (Fresh)'))), DataCell(Text('3.0 – 3.5 kg')), DataCell(Text('4.5 – 5.0 kg')), DataCell(Text('6.0 – 6.5 kg')), DataCell(Text('7.5 – 8.0 kg'))]),
                            
                            // Protein-Rich Feeds
                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Protein-Rich Feeds', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Lucerne Hay'))), DataCell(Text('0.6 – 0.8 kg')), DataCell(Text('1.0 – 1.1 kg')), DataCell(Text('1.3 – 1.5 kg')), DataCell(Text('1.6 – 1.8 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Desmodium (Dry Hay)'))), DataCell(Text('0.6 – 0.8 kg')), DataCell(Text('0.9 – 1.1 kg')), DataCell(Text('1.2 – 1.4 kg')), DataCell(Text('1.5 – 1.7 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Calliandra Leaves (Fresh/Dry)'))), DataCell(Text('0.3 – 0.5 kg')), DataCell(Text('0.5 – 0.8 kg')), DataCell(Text('0.7 – 1.0 kg')), DataCell(Text('0.9 – 1.2 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sunflower Seedcake'))), DataCell(Text('0.05 – 0.10 kg')), DataCell(Text('0.10 – 0.15 kg')), DataCell(Text('0.15 – 0.20 kg')), DataCell(Text('0.20 – 0.25 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Soyabean Meal'))), DataCell(Text('0.05 – 0.10 kg')), DataCell(Text('0.10 – 0.15 kg')), DataCell(Text('0.15 – 0.20 kg')), DataCell(Text('0.20 – 0.25 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Canola Meal'))), DataCell(Text('0.05 – 0.10 kg')), DataCell(Text('0.10 – 0.15 kg')), DataCell(Text('0.15 – 0.20 kg')), DataCell(Text('0.20 – 0.25 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Dairy Meal'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.25 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.45 – 0.60 kg'))]),

                            // Energy-Rich & Concentrates
                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Energy-Rich & Concentrates', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Crushed Maize'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.20 – 0.35 kg')), DataCell(Text('0.30 – 0.50 kg')), DataCell(Text('0.40 – 0.60 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Maize Germ'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.25 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.45 – 0.60 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Wheat Bran'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.25 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.45 – 0.60 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Wheat Pollard'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.20 – 0.35 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.55 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Rice Bran'))), DataCell(Text('0.10 – 0.20 kg')), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.55 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Barley Grain'))), DataCell(Text('0.10 – 0.20 kg')), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.55 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sorghum Grain'))), DataCell(Text('0.10 – 0.20 kg')), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.55 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Commercial Pellets'))), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.60 kg')), DataCell(Text('0.50 – 0.75 kg'))]),

                            // Commercial Pellets
                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Commercial Pellets', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Commercial Lamb Grower Pellets'))), DataCell(Text('0.20 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.50 – 0.65 kg')), DataCell(Text('N/A (growing)'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sheep Pellets'))), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.60 kg')), DataCell(Text('0.50 – 0.75 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sheep Finisher Pellets'))), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.60 kg')), DataCell(Text('0.50 – 0.75 kg'))]),

                            // Crop By-Products
                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Crop By-Products', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Bean Haulm'))), DataCell(Text('0.6 – 0.8 kg')), DataCell(Text('1.0 – 1.2 kg')), DataCell(Text('1.3 – 1.6 kg')), DataCell(Text('1.7 – 1.9 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Wheat Straw'))), DataCell(Text('0.6 – 0.8 kg')), DataCell(Text('1.0 – 1.2 kg')), DataCell(Text('1.3 – 1.6 kg')), DataCell(Text('1.7 – 1.9 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sunflower Residue'))), DataCell(Text('0.5 – 0.7 kg')), DataCell(Text('0.8 – 1.0 kg')), DataCell(Text('1.1 – 1.4 kg')), DataCell(Text('1.4 – 1.7 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Vegetable Trimmings (Clean)'))), DataCell(Text('2.5 – 3.0 kg')), DataCell(Text('4.0 – 4.5 kg')), DataCell(Text('5.5 – 6.0 kg')), DataCell(Text('7.0 – 7.5 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Maize Milling By-Products'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.25 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.45 – 0.60 kg'))]),

                            // Mineral Supplements
                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Mineral Supplements', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Mineral Lick / Bone DCP'))), DataCell(Text('10 – 15 g/day')), DataCell(Text('10 – 15 g/day')), DataCell(Text('15 – 20 g/day')), DataCell(Text('15 – 20 g/day'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Salt Lick'))), DataCell(Text('Free choice block')), DataCell(Text('Free choice block')), DataCell(Text('Free choice block')), DataCell(Text('Free choice block'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sheep Mineral Premix'))), DataCell(Text('10 – 15 g/day')), DataCell(Text('10 – 15 g/day')), DataCell(Text('15 – 20 g/day')), DataCell(Text('15 – 20 g/day'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Urea-Molasses Block'))), DataCell(Text('Max 50 g/day')), DataCell(Text('Max 75 g/day')), DataCell(Text('Max 100 g/day')), DataCell(Text('Max 100 g/day'))]),
                          ],
                        ),
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