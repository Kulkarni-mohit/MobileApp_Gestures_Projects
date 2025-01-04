import 'package:flutter/material.dart';

class Snake extends StatelessWidget {
  final int rows;
  final int columns;
  final double cellSize;

  const Snake({
    Key? key,
    required this.rows,
    required this.columns,
    required this.cellSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: Text('Snake Game Placeholder'),
      ),
    );
  }
}
