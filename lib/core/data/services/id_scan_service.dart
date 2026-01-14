import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class IDScanService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<Map<String, dynamic>> scanId(String frontPath, String backPath) async {
    final frontInputImage = InputImage.fromFilePath(frontPath);
    final backInputImage = InputImage.fromFilePath(backPath);

    final frontText = await _textRecognizer.processImage(frontInputImage);
    final backText = await _textRecognizer.processImage(backInputImage);

    Map<String, dynamic> data = {};

    _parseFront(frontText, data);
    _parseBack(backText, data);

    return data;
  }

  void _parseFront(RecognizedText recognizedText, Map<String, dynamic> data) {
    final lines = recognizedText.blocks
        .expand((b) => b.lines)
        .map((l) => l.text)
        .toList();

    // German ID Front labels:
    // Name / Nom
    // Vornamen / Given names
    // Geburtsdatum / Date of birth
    // Staatsangehörigkeit / Nationality
    // Geburtsort / Place of birth
    // Gültig bis / Expiry date
    // Zugangsnummer / CAN (not needed here)
    // ID-Number is at the top right

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      if (line.contains('Name') || line.contains('Nom')) {
        if (i + 1 < lines.length) data['surname'] = lines[i + 1].trim();
      }
      if (line.contains('Vornamen') || line.contains('Given names')) {
        if (i + 1 < lines.length) data['givenName'] = lines[i + 1].trim();
      }
      if (line.contains('Geburtsdatum') || line.contains('Date of birth')) {
        if (i + 1 < lines.length) data['dob'] = _parseDate(lines[i + 1]);
      }
      if (line.contains('Staatsangehörigkeit') ||
          line.contains('Nationality')) {
        if (i + 1 < lines.length) data['nationality'] = lines[i + 1].trim();
      }
      if (line.contains('Geburtsort') || line.contains('Place of birth')) {
        if (i + 1 < lines.length) data['placeOfBirth'] = lines[i + 1].trim();
      }
      if (line.contains('Gültig bis') || line.contains('Expiry date')) {
        if (i + 1 < lines.length) data['expiryDate'] = _parseDate(lines[i + 1]);
      }
    }

    // ID Number is usually a 9-character alphanumeric string at the top right
    // We can try to find it via regex
    final idRegex = RegExp(r'[A-Z0-9]{9}');
    for (var line in lines) {
      if (idRegex.hasMatch(line) && line.length == 9) {
        // Avoid matching CAN or other 6-digit numbers
        data['idNumber'] = line;
        break;
      }
    }
  }

  void _parseBack(RecognizedText recognizedText, Map<String, dynamic> data) {
    final lines = recognizedText.blocks
        .expand((b) => b.lines)
        .map((l) => l.text)
        .toList();

    // German ID Back labels:
    // Anschrift / Address
    // Größe / Height
    // Augenfarbe / Eye color

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.contains('Anschrift') || line.contains('Address')) {
        // Address can span multiple lines
        String address = "";
        if (i + 1 < lines.length) address += lines[i + 1].trim();
        if (i + 2 < lines.length && !lines[i + 2].contains('Größe')) {
          address += " ${lines[i + 2].trim()}";
        }
        data['address'] = address;
      }
      if (line.contains('Größe') || line.contains('Height')) {
        if (i + 1 < lines.length) data['height'] = lines[i + 1].trim();
      }
    }

    // MRZ Parsing (backup for some fields)
    _parseMRZ(recognizedText.text, data);
  }

  void _parseMRZ(String text, Map<String, dynamic> data) {
    // Basic MRZ regex for German ID (3 lines)
    // IDD<<...
    // 000000...
    // SURNAME<<GIVEN<NAME...
    final mrzLines = text.split('\n').where((l) => l.contains('<<')).toList();
    if (mrzLines.length >= 3) {
      // Very basic MRZ parsing
      // Line 1: IDD<<DOC_NUM...
      if (mrzLines[0].length >= 14) {
        data['idNumber'] ??= mrzLines[0].substring(5, 14);
      }

      // Line 3: SURNAME<<GIVEN NAMES
      final nameLine = mrzLines[2];
      final parts = nameLine.split('<<');
      if (parts.length >= 2) {
        data['surname'] ??= parts[0].replaceAll('<', ' ').trim();
        data['givenName'] ??= parts[1].replaceAll('<', ' ').trim();
      }
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // German format: dd.MM.yyyy
      return DateFormat('dd.MM.yyyy').parse(dateStr.trim());
    } catch (e) {
      try {
        // Try yyMMdd from MRZ if needed, but here we expect human readable
        return DateFormat('dd.MM.yy').parse(dateStr.trim());
      } catch (_) {
        return null;
      }
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
