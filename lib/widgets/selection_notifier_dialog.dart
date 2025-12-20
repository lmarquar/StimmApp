import 'package:flutter/material.dart';

/// Generic dialog that shows a list of selectable options and writes the
/// selected value back to [notifier] on Confirm.
///
/// - notifier: ValueNotifier T? that will be updated on confirm.
/// - options: available options to choose from.
/// - optionLabel: builds a label for each option.
/// - title / confirmLabel / cancelLabel: optional UI text.
/// - onConfirm: optional callback executed after notifier is updated.
class SelectionNotifierDialog<T> extends StatefulWidget {
  final ValueNotifier<T?> notifier;
  final List<T> options;
  final String Function(BuildContext, T) optionLabel;
  final String title;
  final String confirmLabel;
  final String cancelLabel;
  final void Function(T?)? onConfirm;

  const SelectionNotifierDialog({
    super.key,
    required this.notifier,
    required this.options,
    required this.optionLabel,
    this.title = 'Select',
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
  });

  @override
  State<SelectionNotifierDialog<T>> createState() =>
      _SelectionNotifierDialogState<T>();
}

class _SelectionNotifierDialogState<T>
    extends State<SelectionNotifierDialog<T>> {
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected =
        widget.notifier.value ??
        (widget.options.isNotEmpty ? widget.options.first : null);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (widget.options.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No options',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Flexible(
                child: RadioGroup(
                  groupValue: _selected,
                  onChanged: (T? value) {
                    setState(() {
                      if (value != null) {
                        _selected = value;
                      }
                    });
                  },
                  child: ListView(
                    shrinkWrap: true,
                    children: widget.options.map((opt) {
                      final label = widget.optionLabel(context, opt);
                      return RadioListTile<T>(title: Text(label), value: opt);
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(widget.cancelLabel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    widget.notifier.value = _selected;
                    widget.onConfirm?.call(_selected);
                    debugPrint(
                      '[SelectionNotifierDialog] confirmed value: $_selected',
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(widget.confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
