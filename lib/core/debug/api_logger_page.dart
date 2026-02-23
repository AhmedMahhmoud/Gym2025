import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackletics/core/debug/api_logger_model.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'dart:convert';

class ApiLoggerPage extends StatelessWidget {
  final ApiLoggerModel logData;

  const ApiLoggerPage({
    required this.logData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'API Request Logger',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy All',
            onPressed: () => _copyAllToClipboard(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            _buildStatusBadge(),
            const SizedBox(height: 16),

            // Timestamp
            _buildSection(
              title: 'Timestamp',
              content: logData.formattedTimestamp,
            ),
            const SizedBox(height: 16),

            // Request Section
            _buildRequestSection(),
            const SizedBox(height: 16),

            // Response Section
            _buildResponseSection(),
            const SizedBox(height: 16),

            // Error Section (if any)
            if (logData.isError) ...[
              _buildErrorSection(),
              const SizedBox(height: 16),
            ],

            // Raw JSON
            _buildRawJsonSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isSuccess = !logData.isError &&
        logData.statusCode != null &&
        logData.statusCode! < 400;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isSuccess
                ? 'Success (${logData.statusCode})'
                : 'Error (${logData.statusCode ?? logData.errorType ?? "Unknown"})',
            style: TextStyle(
              color: isSuccess ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSection() {
    return _buildCard(
      title: 'REQUEST',
      icon: Icons.send,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Method', logData.method),
          _buildInfoRow('Endpoint', logData.endpoint),
          if (logData.baseUrl != null)
            _buildInfoRow('Base URL', logData.baseUrl!),
          if (logData.fullUrl != null)
            _buildInfoRow('Full URL', logData.fullUrl!),
          if (logData.requestHeaders != null &&
              logData.requestHeaders!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSubsection('Headers', logData.requestHeaders!),
          ],
          if (logData.queryParameters != null &&
              logData.queryParameters!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSubsection('Query Parameters', logData.queryParameters!),
          ],
          if (logData.requestData != null &&
              logData.requestData!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSubsection('Request Body', logData.requestData!),
          ],
        ],
      ),
    );
  }

  Widget _buildResponseSection() {
    return _buildCard(
      title: 'RESPONSE',
      icon: Icons.reply,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (logData.statusCode != null)
            _buildInfoRow('Status Code', logData.statusCode.toString()),
          if (logData.responseHeaders != null &&
              logData.responseHeaders!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSubsection('Headers', logData.responseHeaders!),
          ],
          if (logData.responseData != null) ...[
            const SizedBox(height: 12),
            _buildSubsection('Response Body', logData.responseData),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
    return _buildCard(
      title: 'ERROR',
      icon: Icons.error_outline,
      color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (logData.errorType != null)
            _buildInfoRow('Error Type', logData.errorType!),
          if (logData.errorMessage != null)
            _buildInfoRow('Error Message', logData.errorMessage!),
        ],
      ),
    );
  }

  Widget _buildRawJsonSection() {
    return Builder(
      builder: (context) => _buildCard(
        title: 'RAW JSON',
        icon: Icons.code,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _copyJsonToClipboard(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy JSON'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: SelectableText(
                _formatJson(logData.toJson()),
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? AppColors.primary).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color ?? AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsection(String title, dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: SelectableText(
            _formatJson(data),
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  String _formatJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  void _copyJsonToClipboard(BuildContext context) {
    final json = _formatJson(logData.toJson());
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyAllToClipboard(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('API Request Logger');
    buffer.writeln('==================');
    buffer.writeln('Timestamp: ${logData.formattedTimestamp}');
    buffer.writeln('Status: ${logData.isError ? "Error" : "Success"}');
    buffer.writeln('');
    buffer.writeln('REQUEST:');
    buffer.writeln('Method: ${logData.method}');
    buffer.writeln('Endpoint: ${logData.endpoint}');
    if (logData.baseUrl != null) buffer.writeln('Base URL: ${logData.baseUrl}');
    if (logData.fullUrl != null) buffer.writeln('Full URL: ${logData.fullUrl}');
    if (logData.requestHeaders != null) {
      buffer.writeln('Headers: ${_formatJson(logData.requestHeaders)}');
    }
    if (logData.requestData != null) {
      buffer.writeln('Body: ${_formatJson(logData.requestData)}');
    }
    buffer.writeln('');
    buffer.writeln('RESPONSE:');
    if (logData.statusCode != null)
      buffer.writeln('Status Code: ${logData.statusCode}');
    if (logData.responseHeaders != null) {
      buffer.writeln('Headers: ${_formatJson(logData.responseHeaders)}');
    }
    if (logData.responseData != null) {
      buffer.writeln('Body: ${_formatJson(logData.responseData)}');
    }
    if (logData.errorMessage != null) {
      buffer.writeln('');
      buffer.writeln('ERROR:');
      buffer.writeln('Type: ${logData.errorType ?? "Unknown"}');
      buffer.writeln('Message: ${logData.errorMessage}');
    }
    buffer.writeln('');
    buffer.writeln('RAW JSON:');
    buffer.writeln(_formatJson(logData.toJson()));

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All data copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
