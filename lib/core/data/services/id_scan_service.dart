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

      if (_matchLabel(line, ['Name', 'Nom'])) {
        final value = _getValue(lines, i);
        if (value != null) {
          data['surname'] = _cleanSurname(value);
        }
      }
      if (_matchLabel(line, ['Vornamen', 'Given names'])) {
        data['givenName'] = _getValue(lines, i);
      }
      if (_matchLabel(line, ['Geburtsdatum', 'Date of birth'])) {
        final val = _getValue(lines, i);
        if (val != null) data['dob'] = _parseDate(val);
      }
      if (_matchLabel(line, ['Staatsangehörigkeit', 'Nationality'])) {
        data['nationality'] = _getValue(lines, i);
      }
      if (_matchLabel(line, ['Geburtsort', 'Place of birth'])) {
        data['placeOfBirth'] = _getValue(lines, i);
      }
      if (_matchLabel(line, ['Gültig bis', 'Expiry date'])) {
        final val = _getValue(lines, i);
        if (val != null) data['expiryDate'] = _parseDate(val);
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
      if (_matchLabel(line, ['Anschrift', 'Address'])) {
        // Address can span multiple lines
        String address = "";
        if (i + 1 < lines.length) address += lines[i + 1].trim();
        if (i + 2 < lines.length &&
            !_matchLabel(lines[i + 2], ['Größe', 'Height'])) {
          address += " ${lines[i + 2].trim()}";
        }
        data['address'] = address;
      }
      if (_matchLabel(line, ['Größe', 'Height'])) {
        data['height'] = _getValue(lines, i);
      }
    }

    // MRZ Parsing (backup for some fields)
    _parseMRZ(recognizedText.text, data);
  }

  bool _matchLabel(String line, List<String> labels) {
    final lowerLine = line.toLowerCase();
    return labels.any((label) => lowerLine.contains(label.toLowerCase()));
  }

  String? _getValue(List<String> lines, int index) {
    // Sometimes OCR puts the value on the same line after the label (or some noise)
    // For German ID, it's mostly on the next line or separated by a lot of spaces.
    if (index + 1 < lines.length) {
      return lines[index + 1].trim();
    }
    return null;
  }

  String _cleanSurname(String value) {
    // Fix: Surname ([a] gets missinterpretet as Tal<Name>)
    // If it starts with "Tal" or "al", and then an uppercase letter, remove it.
    if (value.startsWith('Tal') &&
        value.length > 3 &&
        value[3] == value[3].toUpperCase()) {
      return value.substring(3).trim();
    }
    if (value.startsWith('al') &&
        value.length > 2 &&
        value[2] == value[2].toUpperCase()) {
      return value.substring(2).trim();
    }
    return value;
  }

  void _parseMRZ(String text, Map<String, dynamic> data) {
    // Basic MRZ regex for German ID (3 lines)
    // IDD<<...
    // 000000...
    // SURNAME<<GIVEN<NAME...
    final mrzLines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.contains('<<'))
        .toList();
    if (mrzLines.length >= 3) {
      // Very basic MRZ parsing
      // Line 1: IDD<<DOC_NUM...
      if (mrzLines[0].length >= 14) {
        data['idNumber'] ??= mrzLines[0].substring(5, 14);
      }

      // Line 2: contains DOB and Expiry
      // Format: YYMMDD(check)SEX YYMMDD(check)NAT...
      if (mrzLines[1].length >= 30) {
        final dobStr = mrzLines[1].substring(0, 6);
        final expiryStr = mrzLines[1].substring(8, 14);
        final nationality = mrzLines[1].substring(15, 18);

        data['dob'] ??= _parseMRZDate(dobStr);
        data['expiryDate'] ??= _parseMRZDate(expiryStr);
        data['nationality'] ??= nationality.replaceAll('<', '').trim();
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

  DateTime? _parseMRZDate(String d) {
    if (d.length != 6) return null;
    try {
      int year = int.parse(d.substring(0, 2));
      int month = int.parse(d.substring(2, 4));
      int day = int.parse(d.substring(4, 6));

      // Threshold for year (e.g. 50)
      int currentYear = DateTime.now().year % 100;
      if (year > currentYear + 10) {
        year += 1900;
      } else {
        year += 2000;
      }
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDate(String dateStr) {
    // Clean string from common OCR noise in dates
    String cleanDate = dateStr.replaceAll(RegExp(r'[^0-9.]'), '');
    try {
      // German format: dd.MM.yyyy
      return DateFormat('dd.MM.yyyy').parse(cleanDate.trim());
    } catch (e) {
      try {
        return DateFormat('dd.MM.yy').parse(cleanDate.trim());
      } catch (_) {
        return null;
      }
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
