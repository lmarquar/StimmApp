import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class IDScanService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  static const _allLabels = [
    'Name',
    'Nom',
    'Vornamen',
    'Given names',
    'Prénoms',
    'Geburtsdatum',
    'Date of birth',
    'Date de naissance',
    'Staatsangehörigkeit',
    'Nationality',
    'Nationalité',
    'Nationalite',
    'najonal', // Common OCR misread of Nationalité
    'Geburtsort',
    'Place of birth',
    'Lieu de naissance',
    'Gültig bis',
    'Expiry date',
    'Date d\'expiration',
    'Anschrift',
    'Address',
    'Adresse',
    'Größe',
    'Height',
    'Taille',
    'Augenfarbe',
    'Eye color',
    'Couleur des yeux',
    'Zugangsnummer',
    'CAN',
    'ID-Number',
    'Ausweisnummer',
  ];

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

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      if (_matchLabel(line, ['Name', 'Nom']) &&
          !_matchLabel(line, ['Vornamen'])) {
        final value = _getValue(lines, i, ['Name', 'Nom']);
        if (value != null) {
          data['surname'] = _cleanSurname(value);
        }
      }
      if (_matchLabel(line, ['Vornamen', 'Given names', 'Prénoms'])) {
        data['givenName'] = _getValue(lines, i, [
          'Vornamen',
          'Given names',
          'Prénoms',
        ]);
      }
      if (_matchLabel(line, ['Geburtsdatum', 'Date of birth'])) {
        final val = _getValue(lines, i, ['Geburtsdatum', 'Date of birth']);
        if (val != null) data['dob'] = _parseDate(val);
      }
      if (_matchLabel(line, ['Staatsangehörigkeit', 'Nationality'])) {
        final val = _getValue(lines, i, ['Staatsangehörigkeit', 'Nationality']);
        if (val != null) data['nationality'] = _cleanValue(val);
      }
      if (_matchLabel(line, ['Geburtsort', 'Place of birth'])) {
        data['placeOfBirth'] = _getValue(lines, i, [
          'Geburtsort',
          'Place of birth',
        ]);
      }
      if (_matchLabel(line, ['Gültig bis', 'Expiry date'])) {
        final val = _getValue(lines, i, ['Gültig bis', 'Expiry date']);
        if (val != null) data['expiryDate'] = _parseDate(val);
      }
    }

    // ID Number is usually a 9-character alphanumeric string at the top right
    final idRegex = RegExp(r'[A-Z0-9]{9}');
    for (var line in lines) {
      if (idRegex.hasMatch(line) && line.length == 9) {
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

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (_matchLabel(line, ['Anschrift', 'Address'])) {
        String address = "";
        if (i + 1 < lines.length && !_isLabel(lines[i + 1])) {
          address += lines[i + 1].trim();
        }
        if (i + 2 < lines.length && !_isLabel(lines[i + 2])) {
          address += " ${lines[i + 2].trim()}";
        }
        if (address.isNotEmpty) data['address'] = address;
      }
      if (_matchLabel(line, ['Größe', 'Height'])) {
        data['height'] = _getValue(lines, i, ['Größe', 'Height']);
      }
    }

    _parseMRZ(recognizedText.text, data);
  }

  bool _matchLabel(String line, List<String> labels) {
    final lowerLine = line.toLowerCase();
    return labels.any((label) {
      final lowerLabel = label.toLowerCase();
      if (!lowerLine.contains(lowerLabel)) return false;
      // Precision: "Name" should not match "Vornamen"
      if (lowerLabel == 'name' && lowerLine.contains('vornamen')) return false;
      return true;
    });
  }

  bool _isLabel(String line) {
    final lower = line.toLowerCase();
    return _allLabels.any((label) => lower.contains(label.toLowerCase()));
  }

  String? _getValue(List<String> lines, int index, List<String> labels) {
    String currentLine = lines[index];

    // 1. Try same line after removing labels
    String valueOnSameLine = currentLine;
    for (var label in labels) {
      final pos = valueOnSameLine.toLowerCase().indexOf(label.toLowerCase());
      if (pos != -1) {
        valueOnSameLine = valueOnSameLine.replaceRange(
          pos,
          pos + label.length,
          '',
        );
      }
    }
    valueOnSameLine = valueOnSameLine
        .replaceAll(RegExp(r'^[ /:-]+'), '')
        .trim();

    if (valueOnSameLine.isNotEmpty &&
        !_isLabel(valueOnSameLine) &&
        valueOnSameLine.length > 2) {
      return valueOnSameLine;
    }

    // 2. Try next lines, skipping labels
    for (int i = index + 1; i < lines.length && i < index + 3; i++) {
      String nextLine = lines[i].trim();
      if (nextLine.isEmpty) continue;
      if (_isLabel(nextLine)) continue;
      return nextLine;
    }
    return null;
  }

  String _cleanValue(String value) {
    String cleaned = value;
    // Remove any known labels that might have leaked into the value
    for (var label in _allLabels) {
      final lowerLabel = label.toLowerCase();
      if (cleaned.toLowerCase().contains(lowerLabel)) {
        final pos = cleaned.toLowerCase().indexOf(lowerLabel);
        if (pos != -1) {
          cleaned = cleaned.replaceRange(pos, pos + label.length, '');
        }
      }
    }
    return cleaned.replaceAll(RegExp(r'^[ /:-]+'), '').trim();
  }

  String _cleanSurname(String value) {
    String cleaned = _cleanValue(value);
    // Fix: Surname ([a] gets missinterpretet as Tal<Name>)
    if (cleaned.startsWith('Tal') &&
        cleaned.length > 3 &&
        cleaned[3] == cleaned[3].toUpperCase()) {
      return cleaned.substring(3).trim();
    }
    if (cleaned.startsWith('al') &&
        cleaned.length > 2 &&
        cleaned[2] == cleaned[2].toUpperCase()) {
      return cleaned.substring(2).trim();
    }
    return cleaned;
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
