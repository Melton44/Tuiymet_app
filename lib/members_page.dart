import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MembersViewPage extends StatefulWidget {
  const MembersViewPage({super.key});

  @override
  State<MembersViewPage> createState() => _MembersViewPageState();
}

class _MembersViewPageState extends State<MembersViewPage> {
  List<dynamic> _members = [];
  List<dynamic> _announcements = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPageData();
  }

  // Fetch live members from Flask backend
  Future<void> _fetchPageData() async {
    // Note: Use 'http://10.0.2.2:5000/api/members' for Android Emulator, or your local network IP for physical devices
    final membersUrl = Uri.parse('http://10.0.2.2:5000/api/members');
    
    try {
      final response = await http.get(membersUrl);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _members = data['members'] ?? [];
          // You can also fetch announcements here if you have a backend route for them
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load members data.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Card
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
                              child: const Icon(Icons.people_alt_outlined, color: primaryGreen, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Tuiymet Members View',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Official noticeboard and registered database directory',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Group Announcements Noticeboard Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.campaign, color: primaryGreen),
                                SizedBox(width: 8),
                                Text(
                                  'Official Group & Vet Advisories',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _announcements.isEmpty
                                ? const Text('No recent announcements posted.', style: TextStyle(color: Colors.grey))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _announcements.length,
                                    itemBuilder: (context, index) {
                                      final item = _announcements[index];
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: primaryGreen.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: primaryGreen.withValues(alpha: 0.1)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  item['title'] ?? '',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 15),
                                                ),
                                                Text(
                                                  item['date'] ?? '',
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(item['content'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Members Directory List (Connected to PostgreSQL database table: farm_members)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Registered Members Directory',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: primaryGreen),
                                  onPressed: () {
                                    setState(() => _isLoading = true);
                                    _fetchPageData();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _members.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('No members found in the database.', style: TextStyle(color: Colors.grey)),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _members.length,
                                    itemBuilder: (context, index) {
                                      final m = _members[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: primaryGreen.withValues(alpha: 0.1),
                                            child: Text(
                                              '${m['id'] ?? index + 1}',
                                              style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          title: Text(
                                            '${m['full_name']} (${m['group_rank'] ?? 'Member'})',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            'ID: ${m['national_id']} | Phone: ${m['phone_number'] ?? 'N/A'} | Gender: ${m['gender']}',
                                          ),
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
    );
  }
}