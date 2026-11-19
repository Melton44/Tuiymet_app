import 'package:flutter/material.dart';

const Color _primaryGreen = Color(0xFF1B5E20);

/// Number of members waiting for approval.
int countPendingRequests(List<Map<String, dynamic>> memberRoles) =>
    memberRoles.where((m) => m['hasPendingRequest'] == true).length;

/// Bell icon with a red badge. Put it in the dashboard header,
/// but only show it to Admin / Secretary.
class PendingRequestsBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const PendingRequestsBell({super.key, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: count > 0 ? '$count pending access request(s)' : 'No pending requests',
          icon: Icon(
            count > 0 ? Icons.notifications_active : Icons.notifications_none,
            color: _primaryGreen,
          ),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 9 ? '9+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

/// Card listing every member waiting for approval, with Approve / Reject.
/// Renders nothing when there are no pending requests.
class PendingRequestsCard extends StatelessWidget {
  final List<Map<String, dynamic>> memberRoles;
  final void Function(int index, Map<String, dynamic> updated) onUpdateMemberRole;

  const PendingRequestsCard({
    super.key,
    required this.memberRoles,
    required this.onUpdateMemberRole,
  });

  void _decide(BuildContext context, Map<String, dynamic> member, bool approve) {
    final index = memberRoles.indexOf(member);
    if (index == -1) return;

    final updated = Map<String, dynamic>.from(member);
    updated['hasPendingRequest'] = false;
    updated['isGranted'] = approve;
    updated['requestRejected'] = !approve;
    onUpdateMemberRole(index, updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approve
            ? '${member['name']} approved. They can now access the portal.'
            : '${member['name']}\'s request was rejected.'),
        backgroundColor: approve ? _primaryGreen : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = memberRoles.where((m) => m['hasPendingRequest'] == true).toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Text(
                'Pending Access Requests (${pending.length})',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'These members have logged in and are waiting for portal access.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ...pending.map((member) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.amber.shade100,
                    child: Icon(Icons.person, color: Colors.amber.shade800),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member['name']} (${member['rank'] ?? 'Member'})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Phone: ${member['phone'] ?? 'N/A'} | Farm #${member['farmNo'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Reject',
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: () => _decide(context, member, false),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
                    onPressed: () => _decide(context, member, true),
                    icon: const Icon(Icons.check, color: Colors.white, size: 16),
                    label: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}