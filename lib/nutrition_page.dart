import 'package:flutter/material.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  // Interactive Nutrition Calculator State
  double _selectedSheepWeight = 30.0; // Default 30 kg
  final Map<String, bool> _selectedFeeds = {};
  
  final List<Map<String, dynamic>> _feedDatabase = [
    // Roughages & Fodder
    {'name': 'Napier Grass', 'category': 'Roughages & Fodder', 'min20': 3.0, 'max20': 3.5, 'min30': 4.5, 'max30': 5.0, 'min40': 6.0, 'max40': 6.5, 'min50': 7.5, 'max50': 8.0, 'unit': 'kg'},
    {'name': 'Boma Rhodes (Fresh)', 'category': 'Roughages & Fodder', 'min20': 2.5, 'max20': 3.0, 'min30': 4.0, 'max30': 4.5, 'min40': 5.0, 'max40': 6.0, 'min50': 6.5, 'max50': 7.5, 'unit': 'kg'},
    {'name': 'Natural Pasture (Grazing)', 'category': 'Roughages & Fodder', 'min20': 1.0, 'max20': 1.2, 'min30': 1.5, 'max30': 1.8, 'min40': 2.0, 'max40': 2.4, 'min50': 2.5, 'max50': 3.0, 'unit': 'kg'},
    {'name': 'Rhodes Grass Hay', 'category': 'Roughages & Fodder', 'min20': 0.7, 'max20': 0.8, 'min30': 1.0, 'max30': 1.2, 'min40': 1.4, 'max40': 1.6, 'min50': 1.7, 'max50': 2.0, 'unit': 'kg'},
    {'name': 'Maize Stovers (Dry stalks/leaves)', 'category': 'Roughages & Fodder', 'min20': 0.7, 'max20': 0.9, 'min30': 1.1, 'max30': 1.3, 'min40': 1.5, 'max40': 1.7, 'min50': 1.8, 'max50': 2.1, 'unit': 'kg'},
    {'name': 'Sorghum Stover', 'category': 'Roughages & Fodder', 'min20': 0.7, 'max20': 0.9, 'min30': 1.1, 'max30': 1.3, 'min40': 1.5, 'max40': 1.7, 'min50': 1.8, 'max50': 2.1, 'unit': 'kg'},
    {'name': 'Lucerne / Alfalfa (Fresh)', 'category': 'Roughages & Fodder', 'min20': 2.5, 'max20': 3.0, 'min30': 4.0, 'max30': 4.5, 'min40': 5.5, 'max40': 6.0, 'min50': 7.0, 'max50': 7.5, 'unit': 'kg'},
    {'name': 'Desmodium (Fresh)', 'category': 'Roughages & Fodder', 'min20': 2.5, 'max20': 3.0, 'min30': 3.5, 'max30': 4.0, 'min40': 5.0, 'max40': 5.5, 'min50': 6.5, 'max50': 7.0, 'unit': 'kg'},
    {'name': 'Sweet Potato Vines (Fresh)', 'category': 'Roughages & Fodder', 'min20': 3.0, 'max20': 3.5, 'min30': 4.5, 'max30': 5.0, 'min40': 6.0, 'max40': 6.5, 'min50': 7.5, 'max50': 8.0, 'unit': 'kg'},

    // Protein-Rich Feeds
    {'name': 'Lucerne Hay', 'category': 'Protein-Rich Feeds', 'min20': 0.6, 'max20': 0.8, 'min30': 1.0, 'max30': 1.1, 'min40': 1.3, 'max40': 1.5, 'min50': 1.6, 'max50': 1.8, 'unit': 'kg'},
    {'name': 'Desmodium (Dry Hay)', 'category': 'Protein-Rich Feeds', 'min20': 0.6, 'max20': 0.8, 'min30': 0.9, 'max30': 1.1, 'min40': 1.2, 'max40': 1.4, 'min50': 1.5, 'max50': 1.7, 'unit': 'kg'},
    {'name': 'Calliandra Leaves (Fresh/Dry)', 'category': 'Protein-Rich Feeds', 'min20': 0.3, 'max20': 0.5, 'min30': 0.5, 'max30': 0.8, 'min40': 0.7, 'max40': 1.0, 'min50': 0.9, 'max50': 1.2, 'unit': 'kg'},
    {'name': 'Sunflower Seedcake', 'category': 'Protein-Rich Feeds', 'min20': 0.05, 'max20': 0.10, 'min30': 0.10, 'max30': 0.15, 'min40': 0.15, 'max40': 0.20, 'min50': 0.20, 'max50': 0.25, 'unit': 'kg'},
    {'name': 'Soyabean Meal', 'category': 'Protein-Rich Feeds', 'min20': 0.05, 'max20': 0.10, 'min30': 0.10, 'max30': 0.15, 'min40': 0.15, 'max40': 0.20, 'min50': 0.20, 'max50': 0.25, 'unit': 'kg'},
    {'name': 'Canola Meal', 'category': 'Protein-Rich Feeds', 'min20': 0.05, 'max20': 0.10, 'min30': 0.10, 'max30': 0.15, 'min40': 0.15, 'max40': 0.20, 'min50': 0.20, 'max50': 0.25, 'unit': 'kg'},
    {'name': 'Dairy Meal', 'category': 'Protein-Rich Feeds', 'min20': 0.15, 'max20': 0.25, 'min30': 0.25, 'max30': 0.35, 'min40': 0.35, 'max40': 0.50, 'min50': 0.45, 'max50': 0.60, 'unit': 'kg'},

    // Energy-Rich & Concentrates
    {'name': 'Crushed Maize', 'category': 'Energy-Rich & Concentrates', 'min20': 0.15, 'max20': 0.25, 'min30': 0.20, 'max30': 0.35, 'min40': 0.30, 'max40': 0.50, 'min50': 0.40, 'max50': 0.60, 'unit': 'kg'},
    {'name': 'Maize Germ', 'category': 'Energy-Rich & Concentrates', 'min20': 0.15, 'max20': 0.25, 'min30': 0.25, 'max30': 0.35, 'min40': 0.35, 'max40': 0.50, 'min50': 0.45, 'max50': 0.60, 'unit': 'kg'},
    {'name': 'Wheat Bran', 'category': 'Energy-Rich & Concentrates', 'min20': 0.15, 'max20': 0.25, 'min30': 0.25, 'max30': 0.35, 'min40': 0.35, 'max40': 0.50, 'min50': 0.45, 'max50': 0.60, 'unit': 'kg'},
    {'name': 'Wheat Pollard', 'category': 'Energy-Rich & Concentrates', 'min20': 0.15, 'max20': 0.25, 'min30': 0.20, 'max30': 0.35, 'min40': 0.30, 'max40': 0.45, 'min50': 0.40, 'max50': 0.55, 'unit': 'kg'},
    {'name': 'Rice Bran', 'category': 'Energy-Rich & Concentrates', 'min20': 0.10, 'max20': 0.20, 'min30': 0.20, 'max30': 0.30, 'min40': 0.30, 'max40': 0.45, 'min50': 0.40, 'max50': 0.55, 'unit': 'kg'},
    {'name': 'Barley Grain', 'category': 'Energy-Rich & Concentrates', 'min20': 0.10, 'max20': 0.20, 'min30': 0.20, 'max30': 0.30, 'min40': 0.30, 'max40': 0.45, 'min50': 0.40, 'max50': 0.55, 'unit': 'kg'},
    {'name': 'Sorghum Grain', 'category': 'Energy-Rich & Concentrates', 'min20': 0.10, 'max20': 0.20, 'min30': 0.20, 'max30': 0.30, 'min40': 0.30, 'max40': 0.45, 'min50': 0.40, 'max50': 0.55, 'unit': 'kg'},
    {'name': 'Commercial Pellets', 'category': 'Energy-Rich & Concentrates', 'min20': 0.20, 'max20': 0.30, 'min30': 0.30, 'max30': 0.45, 'min40': 0.40, 'max40': 0.60, 'min50': 0.50, 'max50': 0.75, 'unit': 'kg'},

    // Commercial Pellets
    {'name': 'Commercial Lamb Grower Pellets', 'category': 'Commercial Pellets', 'min20': 0.20, 'max20': 0.35, 'min30': 0.35, 'max30': 0.50, 'min40': 0.50, 'max40': 0.65, 'min50': 0.0, 'max50': 0.0, 'unit': 'kg'},
    {'name': 'Sheep Pellets', 'category': 'Commercial Pellets', 'min20': 0.20, 'max20': 0.30, 'min30': 0.30, 'max30': 0.45, 'min40': 0.40, 'max40': 0.60, 'min50': 0.50, 'max50': 0.75, 'unit': 'kg'},
    {'name': 'Sheep Finisher Pellets', 'category': 'Commercial Pellets', 'min20': 0.20, 'max20': 0.30, 'min30': 0.30, 'max30': 0.45, 'min40': 0.40, 'max40': 0.60, 'min50': 0.50, 'max50': 0.75, 'unit': 'kg'},

    // Crop By-Products
    {'name': 'Bean Haulm', 'category': 'Crop By-Products', 'min20': 0.6, 'max20': 0.8, 'min30': 1.0, 'max30': 1.2, 'min40': 1.3, 'max40': 1.6, 'min50': 1.7, 'max50': 1.9, 'unit': 'kg'},
    {'name': 'Wheat Straw', 'category': 'Crop By-Products', 'min20': 0.6, 'max20': 0.8, 'min30': 1.0, 'max30': 1.2, 'min40': 1.3, 'max40': 1.6, 'min50': 1.7, 'max50': 1.9, 'unit': 'kg'},
    {'name': 'Sunflower Residue', 'category': 'Crop By-Products', 'min20': 0.5, 'max20': 0.7, 'min30': 0.8, 'max30': 1.0, 'min40': 1.1, 'max40': 1.4, 'min50': 1.4, 'max50': 1.7, 'unit': 'kg'},
    {'name': 'Vegetable Trimmings (Clean)', 'category': 'Crop By-Products', 'min20': 2.5, 'max20': 3.0, 'min30': 4.0, 'max30': 4.5, 'min40': 5.5, 'max40': 6.0, 'min50': 7.0, 'max50': 7.5, 'unit': 'kg'},
    {'name': 'Maize Milling By-Products', 'category': 'Crop By-Products', 'min20': 0.15, 'max20': 0.25, 'min30': 0.25, 'max30': 0.35, 'min40': 0.35, 'max40': 0.50, 'min50': 0.45, 'max50': 0.60, 'unit': 'kg'},

    // Mineral Supplements
    {'name': 'Mineral Lick / Bone DCP', 'category': 'Mineral Supplements', 'min20': 0.01, 'max20': 0.015, 'min30': 0.01, 'max30': 0.015, 'min40': 0.015, 'max40': 0.02, 'min50': 0.015, 'max50': 0.02, 'unit': 'g/day'},
    {'name': 'Salt Lick', 'category': 'Mineral Supplements', 'min20': 0.0, 'max20': 0.0, 'min30': 0.0, 'max30': 0.0, 'min40': 0.0, 'max40': 0.0, 'min50': 0.0, 'max50': 0.0, 'unit': 'Free choice'},
    {'name': 'Sheep Mineral Premix', 'category': 'Mineral Supplements', 'min20': 0.01, 'max20': 0.015, 'min30': 0.01, 'max30': 0.015, 'min40': 0.015, 'max40': 0.02, 'min50': 0.015, 'max50': 0.02, 'unit': 'g/day'},
    {'name': 'Urea-Molasses Block', 'category': 'Mineral Supplements', 'min20': 0.05, 'max20': 0.05, 'min30': 0.075, 'max30': 0.075, 'min40': 0.10, 'max40': 0.10, 'min50': 0.10, 'max50': 0.10, 'unit': 'kg'},
  ];

  double _calculateTotalDMI() {
    double total = 0.0;
    for (var entry in _selectedFeeds.entries) {
      if (entry.value) {
        final feedName = entry.key;
        final feed = _feedDatabase.firstWhere((f) => f['name'] == feedName, orElse: () => {});
        if (feed.isNotEmpty) {
          double minVal = 0.0;
          double maxVal = 0.0;
          if (_selectedSheepWeight == 20.0) {
            minVal = feed['min20']; maxVal = feed['max20'];
          } else if (_selectedSheepWeight == 30.0) {
            minVal = feed['min30']; maxVal = feed['max30'];
          } else if (_selectedSheepWeight == 40.0) {
            minVal = feed['min40']; maxVal = feed['max40'];
          } else if (_selectedSheepWeight == 50.0) {
            minVal = feed['min50']; maxVal = feed['max50'];
          }
          if (feed['unit'] == 'kg') {
            total += (minVal + maxVal) / 2.0;
          }
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);
    double totalDMI = _calculateTotalDMI();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header Banner
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
            child: Row(
              children: const [
                Icon(Icons.calculate_rounded, color: primaryGreen, size: 28),
                SizedBox(width: 12),
                Text(
                  'Sheep Nutrition & DMI Calculator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Interactive Calculator Card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: primaryGreen.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: primaryGreen.withValues(alpha: 0.15),
                            child: const Icon(Icons.grass_rounded, color: primaryGreen),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Automated Dry Matter Intake (DMI) Calculator',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Select sheep weight and check the provided feeds to instantly calculate total daily dry matter intake:',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          const Text('Sheep Weight:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 12),
                          DropdownButton<double>(
                            value: _selectedSheepWeight,
                            dropdownColor: Colors.white,
                            items: const [
                              DropdownMenuItem(value: 20.0, child: Text('20 kg Sheep')),
                              DropdownMenuItem(value: 30.0, child: Text('30 kg Sheep')),
                              DropdownMenuItem(value: 40.0, child: Text('40 kg Sheep')),
                              DropdownMenuItem(value: 50.0, child: Text('50 kg Sheep')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                if (val != null) _selectedSheepWeight = val;
                              });
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      const Text('Select Provided Feeds:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryGreen)),
                      const SizedBox(height: 8),

                      ...['Roughages & Fodder', 'Protein-Rich Feeds', 'Energy-Rich & Concentrates', 'Commercial Pellets', 'Crop By-Products', 'Mineral Supplements'].map((cat) {
                        final feedsInCat = _feedDatabase.where((f) => f['category'] == cat).toList();
                        return ExpansionTile(
                          title: Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryGreen)),
                          initiallyExpanded: false,
                          children: feedsInCat.map((feed) {
                            final feedName = feed['name'] as String;
                            bool isChecked = _selectedFeeds[feedName] ?? false;
                            return CheckboxListTile(
                              title: Text(feedName, style: const TextStyle(fontSize: 12)),
                              subtitle: Text('Recommended for ${_selectedSheepWeight.toInt()}kg: ${_selectedSheepWeight == 20.0 ? feed['min20'] : (_selectedSheepWeight == 30.0 ? feed['min30'] : (_selectedSheepWeight == 40.0 ? feed['min40'] : feed['min50']))} - ${_selectedSheepWeight == 20.0 ? feed['max20'] : (_selectedSheepWeight == 30.0 ? feed['max30'] : (_selectedSheepWeight == 40.0 ? feed['max40'] : feed['max50']))} ${feed['unit']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              value: isChecked,
                              activeColor: primaryGreen,
                              dense: true,
                              onChanged: (val) {
                                setState(() {
                                  _selectedFeeds[feedName] = val ?? false;
                                });
                              },
                            );
                          }).toList(),
                        );
                      }),

                      const Divider(height: 24),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Estimated Dry Matter Intake (DMI):',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryGreen),
                            ),
                            Text(
                              '${totalDMI.toStringAsFixed(2)} kg / day',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Master Feed Intake Reference Table Card
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
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
                            
                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Protein-Rich Feeds', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Lucerne Hay'))), DataCell(Text('0.6 – 0.8 kg')), DataCell(Text('1.0 – 1.1 kg')), DataCell(Text('1.3 – 1.5 kg')), DataCell(Text('1.6 – 1.8 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Desmodium (Dry Hay)'))), DataCell(Text('0.6 – 0.8 kg')), DataCell(Text('0.9 – 1.1 kg')), DataCell(Text('1.2 – 1.4 kg')), DataCell(Text('1.5 – 1.7 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Calliandra Leaves (Fresh/Dry)'))), DataCell(Text('0.3 – 0.5 kg')), DataCell(Text('0.5 – 0.8 kg')), DataCell(Text('0.7 – 1.0 kg')), DataCell(Text('0.9 – 1.2 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sunflower Seedcake'))), DataCell(Text('0.05 – 0.10 kg')), DataCell(Text('0.10 – 0.15 kg')), DataCell(Text('0.15 – 0.20 kg')), DataCell(Text('0.20 – 0.25 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Soyabean Meal'))), DataCell(Text('0.05 – 0.10 kg')), DataCell(Text('0.10 – 0.15 kg')), DataCell(Text('0.15 – 0.20 kg')), DataCell(Text('0.20 – 0.25 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Canola Meal'))), DataCell(Text('0.05 – 0.10 kg')), DataCell(Text('0.10 – 0.15 kg')), DataCell(Text('0.15 – 0.20 kg')), DataCell(Text('0.20 – 0.25 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Dairy Meal'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.25 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.45 – 0.60 kg'))]),

                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Energy-Rich & Concentrates', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Crushed Maize'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.20 – 0.35 kg')), DataCell(Text('0.30 – 0.50 kg')), DataCell(Text('0.40 – 0.60 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Maize Germ'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.25 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.45 – 0.60 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Wheat Bran'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.25 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.45 – 0.60 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Wheat Pollard'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.20 – 0.35 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.55 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Rice Bran'))), DataCell(Text('0.10 – 0.20 kg')), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.55 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Barley Grain'))), DataCell(Text('0.10 – 0.20 kg')), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.55 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sorghum Grain'))), DataCell(Text('0.10 – 0.20 kg')), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.55 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Commercial Pellets'))), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.60 kg')), DataCell(Text('0.50 – 0.75 kg'))]),

                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Commercial Pellets', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Commercial Lamb Grower Pellets'))), DataCell(Text('0.20 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.50 – 0.65 kg')), DataCell(Text('N/A (growing)'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sheep Pellets'))), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.60 kg')), DataCell(Text('0.50 – 0.75 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sheep Finisher Pellets'))), DataCell(Text('0.20 – 0.30 kg')), DataCell(Text('0.30 – 0.45 kg')), DataCell(Text('0.40 – 0.60 kg')), DataCell(Text('0.50 – 0.75 kg'))]),

                            DataRow(color: WidgetStatePropertyAll(Color(0x141B5E20)), cells: [DataCell(Text('Crop By-Products', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen))), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Bean Haulm'))), DataCell(Text('0.6 – 0.8 kg')), DataCell(Text('1.0 – 1.2 kg')), DataCell(Text('1.3 – 1.6 kg')), DataCell(Text('1.7 – 1.9 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Wheat Straw'))), DataCell(Text('0.6 – 0.8 kg')), DataCell(Text('1.0 – 1.2 kg')), DataCell(Text('1.3 – 1.6 kg')), DataCell(Text('1.7 – 1.9 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Sunflower Residue'))), DataCell(Text('0.5 – 0.7 kg')), DataCell(Text('0.8 – 1.0 kg')), DataCell(Text('1.1 – 1.4 kg')), DataCell(Text('1.4 – 1.7 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Vegetable Trimmings (Clean)'))), DataCell(Text('2.5 – 3.0 kg')), DataCell(Text('4.0 – 4.5 kg')), DataCell(Text('5.5 – 6.0 kg')), DataCell(Text('7.0 – 7.5 kg'))]),
                            DataRow(cells: [DataCell(Padding(padding: EdgeInsets.only(left: 12.0), child: Text('Maize Milling By-Products'))), DataCell(Text('0.15 – 0.25 kg')), DataCell(Text('0.25 – 0.35 kg')), DataCell(Text('0.35 – 0.50 kg')), DataCell(Text('0.45 – 0.60 kg'))]),

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