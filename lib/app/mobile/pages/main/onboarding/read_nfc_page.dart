import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, MethodChannel;
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';


class ReadNfcPage extends StatefulWidget {
  const ReadNfcPage({super.key});

  @override
  State<ReadNfcPage> createState() => _ReadNfcPageState();
}

class _ReadNfcPageState extends State<ReadNfcPage> {
  final TextEditingController controllerPw = TextEditingController();
  final TextEditingController controllerEm = TextEditingController();
  static const platform = MethodChannel('com.example.stimmapp/eid');
  String _statusMessage = 'Ready to scan';
  bool _isScanning = false;
  String? _readerName;
  bool _cardAvailable = false;
  final TextEditingController _tcTokenController = TextEditingController(
    text: 'https://test.governikus-eid.de/AusweisAuskunft/WebServiceRequesterServlet',
  );

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      debugPrint('Received method call from native: ${call.method} with args: ${call.arguments}');
      if (!mounted) return;
      switch (call.method) {
        case 'onMessage':
          setState(() {
            _statusMessage = 'SDK: ${call.arguments}';
          });
          break;
        case 'onRequestPin':
          _showInputDialog(title: 'Enter PIN', method: 'setPin');
          break;
        case 'onRequestCan':
          _showInputDialog(title: 'Enter CAN', method: 'setCan');
          break;
        case 'onRequestPuk':
          _showInputDialog(title: 'Enter PUK', method: 'setPuk');
          break;
        case 'onCardDetected':
          setState(() {
            _cardAvailable = true;
            _statusMessage = 'ID Card detected!';
          });
          showSuccessSnackBar('ID Card detected!');
          break;
        case 'onCardLost':
          setState(() {
            _cardAvailable = false;
            _statusMessage = 'ID Card lost!';
          });
          showErrorSnackBar('ID Card lost!');
          break;
        case 'onReaderInfo':
          final args = call.arguments as Map;
          setState(() {
            _readerName = args['name'] as String?;
            _cardAvailable = args['cardAvailable'] as bool;
          });
          break;
      }
    });
  }

  void _showInputDialog({required String title, required String method}) {
    final TextEditingController inputController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: inputController,
          decoration: InputDecoration(hintText: title.split(' ').last),
          keyboardType: TextInputType.number,
          obscureText: method == 'setPin',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              platform.invokeMethod(method, {method.toLowerCase().substring(3): inputController.text});
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> startScan() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Initializing scan...';
    });
    try {
      final result = await platform.invokeMethod('startVerification', {'tcTokenURL': _tcTokenController.text});
      if (result == 'Success') {
        showSuccessSnackBar('Verification Successful');
        setState(() => _statusMessage = 'Verification Successful');
      } else {
        showErrorSnackBar('Verification Failed: $result');
        setState(() => _statusMessage = 'Verification Failed: $result');
      }
    } catch (e) {
      showErrorSnackBar('Error: $e');
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(title: const Text("Confirm Identity")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _cardAvailable ? Icons.contactless : Icons.nfc,
                  size: 100,
                  color: _cardAvailable ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 32),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.l,
                ),
                if (_readerName != null) ...[
                  const SizedBox(height: 16),
                  Text('Reader: $_readerName', style: AppTextStyles.m),
                ],
                const SizedBox(height: 32),
                TextField(
                  controller: _tcTokenController,
                  decoration: const InputDecoration(
                    labelText: 'tcTokenURL',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                if (_isScanning)
                  const CircularProgressIndicator()
                else
                  const Text('Please place your ID card on the back of your device.'),
              ],
            ),
          ),
        ),
      ),
      buttons: [
        ButtonWidget(
          isFilled: true,
          label: _isScanning ? 'Scanning...' : 'Start ID Scan',
          callback: _isScanning ? null : startScan,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
