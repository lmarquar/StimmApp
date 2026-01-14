import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/services/id_scan_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:stimmapp/l10n/app_localizations.dart';

class IDScanPage extends StatefulWidget {
  const IDScanPage({super.key});

  @override
  State<IDScanPage> createState() => _IDScanPageState();
}

class _IDScanPageState extends State<IDScanPage> {
  final ImagePicker _picker = ImagePicker();
  final IDScanService _scanService = IDScanService();

  XFile? _frontImage;
  XFile? _backImage;
  bool _isProcessing = false;
  Map<String, dynamic>? _scannedData;

  Future<void> _pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = image;
        } else {
          _backImage = image;
        }
      });
    }
  }

  Future<void> _processId() async {
    if (_frontImage == null || _backImage == null) {
      showErrorSnackBar('Please scan both front and back of your ID');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final data = await _scanService.scanId(
        _frontImage!.path,
        _backImage!.path,
      );
      setState(() {
        _scannedData = data;
      });
    } catch (e) {
      showErrorSnackBar('Error processing ID: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _scanService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.idScan)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              l10n.scanYourId,
              style: AppTextStyles.lBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildImagePicker(
              l10n.frontSide,
              _frontImage,
              () => _pickImage(true),
            ),
            const SizedBox(height: 16),
            _buildImagePicker(
              l10n.backSide,
              _backImage,
              () => _pickImage(false),
            ),
            const SizedBox(height: 32),
            if (_scannedData == null)
              ButtonWidget(
                label: l10n.processId,
                isFilled: true,
                callback: _isProcessing ? null : _processId,
              )
            else
              _buildDataOverview(l10n),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label, XFile? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 48),
                  const SizedBox(height: 8),
                  Text(label),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(image.path), fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildDataOverview(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${l10n.scannedData}:', style: AppTextStyles.mBold),
        const SizedBox(height: 8),
        _dataRow(l10n.surname, _scannedData?['surname']),
        _dataRow(l10n.givenName, _scannedData?['givenName']),
        _dataRow(
          l10n.dateOfBirth,
          _scannedData?['dateOfBirth']?.toString().split(' ')[0],
        ),
        _dataRow(l10n.nationality, _scannedData?['nationality']),
        _dataRow(l10n.placeOfBirth, _scannedData?['placeOfBirth']),
        _dataRow(
          l10n.expiryDate,
          _scannedData?['expiryDate']?.toString().split(' ')[0],
        ),
        _dataRow(l10n.idNumber, _scannedData?['idNumber']),
        _dataRow(l10n.address, _scannedData?['address']),
        _dataRow(l10n.height, _scannedData?['height']),
        const SizedBox(height: 24),
        ButtonWidget(
          label: l10n.confirmAndFinish,
          isFilled: true,
          callback: () => Navigator.pop(context, {
            'scannedData': _scannedData,
            'frontImage': _frontImage,
            'backImage': _backImage,
          }),
        ),
        const SizedBox(height: 8),
        ButtonWidget(
          label: l10n.scanAgain,
          isFilled: false,
          callback: () => setState(() => _scannedData = null),
        ),
      ],
    );
  }

  Widget _dataRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: AppTextStyles.mBold),
          ),
          Expanded(child: Text(value ?? 'Not found')),
        ],
      ),
    );
  }
}
