import 'package:flutter/material.dart';

class TreasurerPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final double totalFunds;
  final Function(Map<String, dynamic>) onAddTransaction;

  const TreasurerPage({
    super.key,
    required this.transactions,
    required this.totalFunds,
    required this.onAddTransaction,
  });

  @override
  State<TreasurerPage> createState() => _TreasurerPageState();
}

class _TreasurerPageState extends State<TreasurerPage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCredit = true;

  void _submitTransaction() {
    final double? amt = double.tryParse(_amountController.text);
    if (amt == null || _descriptionController.text.isEmpty) return;

    widget.onAddTransaction({
      'title': _descriptionController.text.trim(),
      'date': DateTime.now().toString().split(' ')[0],
      'amount': amt,
      'isCredit': _isCredit,
    });

    _amountController.clear();
    _descriptionController.clear();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Treasurer Form & Funds Summary
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Treasurer Treasury Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Group Funds Available', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('KES ${widget.totalFunds.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryGreen)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Amount (KES)', prefixIcon: Icon(Icons.attach_money, color: primaryGreen)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Funds Description / Note', prefixIcon: Icon(Icons.notes, color: primaryGreen)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Contribution / Income'),
                        selected: _isCredit,
                        onSelected: (val) => setState(() => _isCredit = true),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Expense / Payout'),
                        selected: !_isCredit,
                        onSelected: (val) => setState(() => _isCredit = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                      onPressed: _submitTransaction,
                      child: const Text('Record Transaction', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Transaction Log View
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Group Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = widget.transactions[index];
                      final bool isCredit = tx['isCredit'];
                      return ListTile(
                        leading: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                        title: Text(tx['title']),
                        subtitle: Text(tx['date']),
                        trailing: Text(
                          '${isCredit ? "+ KES" : "- KES"} ${tx['amount']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCredit ? Colors.green : Colors.red,
                          ),
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
    );
  }
}