import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chatgpt_usage_service.dart';
import '../providers/app_provider.dart';

class UsageMonitorWidget extends StatelessWidget {
  const UsageMonitorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TokenUsageInfo>(
      future: ChatGPTUsageService.getTokenUsageInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError) {
          return _buildErrorCard();
        }

        final usageInfo = snapshot.data;
        if (usageInfo == null) {
          return _buildEmptyCard();
        }

        return _buildUsageCard(context, usageInfo);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading usage information...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 20),
            const SizedBox(width: 12),
            Text(
              'Failed to load usage information',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              'No usage data available',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard(BuildContext context, TokenUsageInfo usageInfo) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with model and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ChatGPT Usage',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: usageInfo.usageColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: usageInfo.usageColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    usageInfo.usageLevel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: usageInfo.usageColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Model info
            Row(
              children: [
                Icon(Icons.smart_toy, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 4),
                Text(
                  'Model: ${usageInfo.model}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Token usage bar
            _buildTokenUsageBar(usageInfo),
            const SizedBox(height: 12),

            // Token details
            _buildTokenDetails(usageInfo),
            const SizedBox(height: 12),

            // Daily stats
            _buildDailyStats(usageInfo),
            const SizedBox(height: 12),

            // Action buttons
            _buildActionButtons(context, usageInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenUsageBar(TokenUsageInfo usageInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Context Usage',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${usageInfo.usedTokens.toString()} / ${usageInfo.maxTokens.toString()}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[200],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: usageInfo.usagePercentage / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: usageInfo.usageColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${usageInfo.usagePercentage.toStringAsFixed(1)}% used',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${usageInfo.remainingTokens.toString()} remaining',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTokenDetails(TokenUsageInfo usageInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Requests:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                usageInfo.totalRequests.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Tokens Used:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                usageInfo.totalTokensUsed.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats(TokenUsageInfo usageInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Usage',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tokens:',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                usageInfo.dailyTokensUsed.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Est. Cost:',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '\$${usageInfo.dailyCost.toStringAsFixed(4)}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TokenUsageInfo usageInfo) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showDetailedUsageDialog(context, usageInfo);
            },
            icon: const Icon(Icons.info_outline, size: 16),
            label: Text(
              'Details',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.blue[600]!),
              foregroundColor: Colors.blue[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showResetUsageDialog(context);
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(
              'Reset',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.orange[600]!),
              foregroundColor: Colors.orange[600],
            ),
          ),
        ),
      ],
    );
  }

  void _showDetailedUsageDialog(BuildContext context, TokenUsageInfo usageInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'ChatGPT Usage Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Model', usageInfo.model),
              _buildDetailRow('Max Context', '${usageInfo.maxTokens.toString()} tokens'),
              _buildDetailRow('Current Usage', '${usageInfo.usedTokens.toString()} tokens'),
              _buildDetailRow('Remaining', '${usageInfo.remainingTokens.toString()} tokens'),
              _buildDetailRow('Usage Level', usageInfo.usageLevel),
              _buildDetailRow('Usage Percentage', '${usageInfo.usagePercentage.toStringAsFixed(2)}%'),
              const Divider(),
              _buildDetailRow('Total Requests', usageInfo.totalRequests.toString()),
              _buildDetailRow('Total Tokens Used', usageInfo.totalTokensUsed.toString()),
              const Divider(),
              _buildDetailRow('Today\'s Tokens', usageInfo.dailyTokensUsed.toString()),
              _buildDetailRow('Today\'s Cost', '\$${usageInfo.dailyCost.toStringAsFixed(6)}'),
              const Divider(),
              _buildDetailRow('Price per 1M tokens', '\$${ChatGPTUsageService.pricePerMillion.toStringAsFixed(2)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Usage Statistics',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will reset all usage statistics including daily usage and total counts. This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ChatGPTUsageService.resetUsage();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usage statistics reset successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
            child: Text('Reset', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
