import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../configs/app_colors.dart';

class ExamCardShimmer extends StatelessWidget {
  const ExamCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Status gradient strip
          Container(
            height: 4,
            color: Colors.grey[300],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          width: 200,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        width: 80,
                        height: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  
                  // Info Row (Questions and Duration)
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 100,
                        height: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Progress Indicator
                  Container(
                    width: double.infinity,
                    height: 6,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  
                  // Start and Due Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        color: Colors.white,
                      ),
                      Container(
                        width: 80,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // More Icon
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}