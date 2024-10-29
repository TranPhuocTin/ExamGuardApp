import 'package:exam_guardian/configs/app_animation.dart';
import 'package:flutter/material.dart';
import 'package:exam_guardian/configs/app_colors.dart';
import 'package:lottie/lottie.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  final String examTitle;
  final Future<void> Function() onConfirm;

  const DeleteConfirmationDialog({
    Key? key,
    required this.examTitle,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _DeleteConfirmationDialogState createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isProcessing)
            Lottie.network(
              AppAnimation.deleteAnimation,
              width: 150,
              height: 150,
              fit: BoxFit.fill,
            )
          else
            Column(
              children: [
                SizedBox(height: 15),
                Text(
                  "Are you sure?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 15),
                Text(
                  "Do you really want to delete the '${widget.examTitle}'? This process cannot be undone.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          SizedBox(height: 22),
          if (!isProcessing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: _handleDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Delete",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() => isProcessing = true);
    await widget.onConfirm();
    await Future.delayed(Duration(seconds: 2));
  
    if (!mounted) return;

    // Now you can safely use context
    Navigator.of(context).pop();
  }
}
