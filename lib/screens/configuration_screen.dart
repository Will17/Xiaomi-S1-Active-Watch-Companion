import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chatGptKeyController = TextEditingController();
  final _webhookUrlController = TextEditingController();
  final _portController = TextEditingController(text: '8080');

  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfiguration();
  }

  @override
  void dispose() {
    _chatGptKeyController.dispose();
    _webhookUrlController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _loadCurrentConfiguration() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    _chatGptKeyController.text = provider.chatGPTApiKey;
    _webhookUrlController.text = provider.alexaWebhookUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuration',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ChatGPT Configuration
                  _buildSectionTitle('ChatGPT Configuration'),
                  const SizedBox(height: 16),
                  _buildChatGPTSection(provider),
                  const SizedBox(height: 24),

                  // Webhook Configuration
                  _buildSectionTitle('Webhook Configuration'),
                  const SizedBox(height: 16),
                  _buildWebhookSection(provider),
                  const SizedBox(height: 24),

                  // Server Configuration
                  _buildSectionTitle('Server Configuration'),
                  const SizedBox(height: 16),
                  _buildServerSection(provider),
                  const SizedBox(height: 24),

                  // Actions
                  _buildActionButtons(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildChatGPTSection(AppProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OpenAI API Key',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _chatGptKeyController,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                hintText: 'sk-...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
                helperText: 'Get your API key from platform.openai.com',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your ChatGPT API key';
                }
                if (!value.startsWith('sk-')) {
                  return 'API key should start with "sk-"';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await provider.saveChatGPTApiKey(
                          _chatGptKeyController.text,
                        );
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'ChatGPT API key saved successfully',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save API Key',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebhookSection(AppProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alexa Webhook URL',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _webhookUrlController,
              decoration: InputDecoration(
                hintText: 'http://your-server.com/webhook',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'URL where Alexa will send voice commands',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter webhook URL';
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasAbsolutePath) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await provider.saveAlexaWebhookUrl(
                          _webhookUrlController.text,
                        );
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Webhook URL saved successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save Webhook URL',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerSection(AppProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Local Webhook Server',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Switch(
                  value: provider.isWebhookServerRunning,
                  onChanged: (value) async {
                    if (value) {
                      final port = int.tryParse(_portController.text) ?? 8080;
                      final success = await provider.startWebhookServer(
                        port: port,
                      );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Server started on ${provider.webhookUrl}',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      await provider.stopWebhookServer();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Server stopped'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: 'Port',
                hintText: '8080',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Port for the local webhook server',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a port number';
                }
                final port = int.tryParse(value);
                if (port == null || port < 1 || port > 65535) {
                  return 'Please enter a valid port (1-65535)';
                }
                return null;
              },
            ),
            if (provider.webhookUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Webhook URL:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      provider.webhookUrl,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppProvider provider) {
    return Column(
      children: [
        // Clear Data Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading
                ? null
                : () {
                    _showClearDataDialog(provider);
                  },
            icon: const Icon(Icons.delete_outline),
            label: Text(
              'Clear All Data',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Test Configuration Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading
                ? null
                : () {
                    _testConfiguration(provider);
                  },
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              'Test Configuration',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showClearDataDialog(AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will delete all conversations, automations, and configuration. This action cannot be undone.',
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
              await provider.clearConversationHistory();
              await provider.clearAutomationHistory();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: Text(
              'Clear All',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _testConfiguration(AppProvider provider) {
    bool hasApiKey = provider.chatGPTApiKey.isNotEmpty;
    bool hasWebhookUrl = provider.alexaWebhookUrl.isNotEmpty;
    bool serverRunning = provider.isWebhookServerRunning;

    String message;
    Color color;

    if (hasApiKey && hasWebhookUrl && serverRunning) {
      message = 'Configuration is complete and ready to use!';
      color = Colors.green;
    } else {
      List<String> issues = [];
      if (!hasApiKey) issues.add('ChatGPT API key');
      if (!hasWebhookUrl) issues.add('Alexa webhook URL');
      if (!serverRunning) issues.add('Server not running');

      message = 'Configuration incomplete: ${issues.join(', ')}';
      color = Colors.orange;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
