import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class FreeTextHintWidget extends StatefulWidget {
  final bool isRevealed;
  final bool isCorrect;
  final String correctDisplay;
  final ValueChanged<String> onSubmit;

  const FreeTextHintWidget({
    super.key,
    required this.isRevealed,
    required this.isCorrect,
    required this.correctDisplay,
    required this.onSubmit,
  });

  @override
  State<FreeTextHintWidget> createState() => _FreeTextHintWidgetState();
}

class _FreeTextHintWidgetState extends State<FreeTextHintWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (!widget.isRevealed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRevealed) {
      return _buildRevealedState(context);
    }
    return _buildInputState(context);
  }

  Widget _buildInputState(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.lightParchment,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warmBeige, width: 1.5),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.darkBrown,
                  ),
              decoration: InputDecoration(
                hintText: 'Type a number...',
                hintStyle: TextStyle(
                  color: AppColors.agedInkBlue.withValues(alpha: 0.4),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
              cursorColor: AppColors.deepBurgundy,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _submit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.deepBurgundy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Submit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.parchment,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevealedState(BuildContext context) {
    final color = widget.isCorrect ? AppColors.sageGreen : AppColors.dustyRose;
    final icon = widget.isCorrect ? Icons.check_rounded : Icons.close_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.isCorrect
                  ? 'Correct!'
                  : 'Answer: ${widget.correctDisplay}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
