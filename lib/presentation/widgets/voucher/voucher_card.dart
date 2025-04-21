import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/voucher.dart';
import 'package:intl/intl.dart';

class VoucherCard extends StatelessWidget {
  final Voucher voucher;

  const VoucherCard({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Voucher Details'),
              content: const Text('detail voucher'), // Placeholder text
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              voucher.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              context.go('/edit-voucher/${voucher.id}');
                            },
                          ),
                        ],
                      ),
                      Text(
                        voucher.type.toLowerCase().contains('discount')
                            ? 'Cucikilat'
                            : 'WashWise',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF95BBE3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voucher.obtainMethod,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voucher.validityPeriod != null
                            ? 'Valid until ${DateFormat('dd/MM/yyyy').format(voucher.validityPeriod!)}'
                            : 'No expiry',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(10, double.infinity),
                painter: DashedLinePainter(),
              ),
              Container(
                width: 100,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      voucher.type,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF95BBE3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashHeight = 5;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
