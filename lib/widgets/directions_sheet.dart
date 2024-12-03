import 'package:flutter/material.dart';

class DirectionsSheet extends StatelessWidget {
  final double totalDistance; //Tổng quãng đường (đơn vị: km).
  final String totalDuration; //Tổng thời gian di chuyển (đơn vị: phút hoặc giờ).
  final List<Map<String, dynamic>> routeSteps; //Danh sách các bước chỉ dẫn của lộ trình

  const DirectionsSheet({
    super.key,
    required this.totalDistance,
    required this.totalDuration,
    required this.routeSteps,
  });

  @override
  Widget build(BuildContext context) {
    //Widget có thể kéo thả để mở rộng hoặc thu nhỏ
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      expand: false, //Cho phép sheet mở rộng hết màn hình nếu true.
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildSummary(),
            const Divider(height: 24),
            _buildStepsList(scrollController),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Chi tiết hành trình',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Icon(Icons.directions_car),
            Text('${totalDistance.toStringAsFixed(1)} km'),
          ],
        ),
        Column(
          children: [
            const Icon(Icons.access_time),
            Text(totalDuration),
          ],
        ),
      ],
    );
  }

  Widget _buildStepsList(ScrollController scrollController) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: routeSteps.length,
        itemBuilder: (context, index) {
          final step = routeSteps[index];
          return ListTile(
            leading: _getDirectionIcon(step['instruction']),
            title: Text(_getInstructionText(step['instruction'])),
            subtitle: Text(
              '${step['distance']} km - ${step['duration']} phút',
            ),
          );
        },
      ),
    );
  }

  Icon _getDirectionIcon(String instruction) {
    switch (instruction) {
      case 'turn':
        return const Icon(Icons.turn_right);
      case 'new name':
        return const Icon(Icons.straight);
      case 'depart':
        return const Icon(Icons.departure_board);
      case 'arrive':
        return const Icon(Icons.place);
      default:
        return const Icon(Icons.arrow_forward);
    }
  }

  String _getInstructionText(String instruction) {
    switch (instruction) {
      case 'turn':
        return 'Rẽ';
      case 'new name':
        return 'Đi thẳng';
      case 'depart':
        return 'Bắt đầu';
      case 'arrive':
        return 'Đến nơi';
      default:
        return 'Tiếp tục';
    }
  }
} 