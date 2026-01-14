import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/services/google_places_service.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String apiKey;
  final String label;
  final String? Function(String?)? validator;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.apiKey,
    required this.label,
    this.validator,
  });

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  late final GooglePlacesService _placesService;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _placesService = GooglePlacesService(apiKey: widget.apiKey);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<GooglePlacesPrediction>(
          displayStringForOption: (option) => option.description,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<GooglePlacesPrediction>.empty();
            }

            final completer = Completer<Iterable<GooglePlacesPrediction>>();

            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 600), () async {
              try {
                final results = await _placesService.getAutocomplete(
                  textEditingValue.text,
                );
                completer.complete(results);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                completer.complete(
                  const Iterable<GooglePlacesPrediction>.empty(),
                );
              }
            });

            return completer.future;
          },
          onSelected: (GooglePlacesPrediction selection) {
            widget.controller.text = selection.description;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: selection.description.length),
            );
          },
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            // Synchronize our controller with the internal Autocomplete controller
            if (textController.text != widget.controller.text) {
              textController.text = widget.controller.text;
            }

            // Update widget.controller when internal controller changes
            textController.addListener(() {
              if (widget.controller.text != textController.text) {
                widget.controller.text = textController.text;
              }
            });

            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                suffixIcon: const Icon(Icons.location_on),
              ),
              style: AppTextStyles.m,
              validator: widget.validator,
              onFieldSubmitted: (value) {
                onFieldSubmitted();
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: constraints.maxWidth,
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.location_on, size: 18),
                        title: Text(option.description, style: AppTextStyles.m),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
