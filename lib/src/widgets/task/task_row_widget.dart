import 'package:flutter/widgets.dart';

class TaskRowWidget extends StatelessWidget {
  final Widget icon;
  final Widget content;
  final Function()? onTap;
  const TaskRowWidget({
    super.key,
    required this.icon,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 48,
                height: 50,
                child: Transform.scale(
                  scale: 1.2,
                  child: icon,
                ),
              ),
            ),
            Expanded(
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}
