import 'package:flutter/material.dart';
import 'package:stimmapp/core/constants/german_states.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

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
      decoration: InputDecoration(
        labelText: context.l10n.state,
        border: const OutlineInputBorder(),
      ),
      hint: Text(context.l10n.pleaseSelectState),
      initialValue: selectedState,
      onChanged: onStateChanged,
      items: germanStates.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }
}
