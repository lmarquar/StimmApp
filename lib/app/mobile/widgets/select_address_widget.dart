import 'package:flutter/material.dart';
import 'package:stimmapp/core/constants/german_states.dart';

// This list can be moved to a separate constants file if used elsewhere.

class SelectAddressWidget extends StatelessWidget {
  const SelectAddressWidget({
    super.key,
    required this.selectedState,
    required this.onStateChanged,
  });

  final String? selectedState;
  final ValueChanged<String?> onStateChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Bundesland',
        border: OutlineInputBorder(),
      ),
      hint: const Text('Bitte Bundesland auswählen'),
      initialValue: selectedState,
      onChanged: onStateChanged,
      items: germanStates.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }
}
