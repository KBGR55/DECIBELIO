import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:flutter/material.dart';

class ExpandableButton extends StatefulWidget {
  final String titleExpanded;
  final String titleCollapsed;
  final Widget expandedContent;

  const ExpandableButton({
    super.key,
    required this.titleExpanded,
    required this.titleCollapsed,
    required this.expandedContent,
  });

  @override
  State<ExpandableButton> createState() => _ExpandableButtonState();
}

class _ExpandableButtonState extends State<ExpandableButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool esTemaOscuro = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: 
          ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              side: BorderSide(color: esTemaOscuro?Colors.white:Colors.black, width: 1)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AdaptiveTheme.of(context).theme.cardColor,
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 20)),
          
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            children: [
              Text(
                _isExpanded ? widget.titleExpanded : widget.titleCollapsed,
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                  fontWeight: FontWeight.w600,
                  height: 0.5,
                )
              ),
              Icon(Icons.arrow_drop_down, color: esTemaOscuro?Colors.white:Colors.black)
            ],
          )
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? null : 0,
          child: _isExpanded
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.expandedContent,
          )
              : null,
        ),
      ],
    );
  }
}
