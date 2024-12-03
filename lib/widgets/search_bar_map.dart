import 'package:flutter/material.dart';
import 'package:travelvn/service/places_service.dart';

class CustomSearchBarMap extends StatefulWidget {
  final TextEditingController controller;
  final String hintText; //gợi ý trong ô tìm kiếm
  final IconData icon;
  final Function(String) onSubmitted;
  final VoidCallback onClear;

  const CustomSearchBarMap({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.onSubmitted,
    required this.onClear,
  }) : super(key: key);

  @override
  State<CustomSearchBarMap> createState() => _CustomSearchBarMapState();
}

class _CustomSearchBarMapState extends State<CustomSearchBarMap> {
  List<Map<String, String>> _suggestions = [];
  bool _isLoading = false;

//dùng để lấy gợi ý địa điểm từ API tìm kiếm
  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      //Hàm này gửi yêu cầu đến API và chờ kết quả
      final suggestions = await PlacesService.searchPlaces(query);
      //Cập nhật giao diện
      setState(() => _suggestions = suggestions);
    } finally {
      //Tắt trạng thái tải để vòng xoay ẩn đi
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Trường tìm kiếm
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          //Dùng để đọc và ghi dữ liệu trong ô tìm kiếm.
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(widget.icon),
              //Biểu tượng xóa
              suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.onClear();
                      setState(() => _suggestions = []);
                    },
                  )
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16), //Tạo khoảng cách giữa nội dung và viền
            ),
            onChanged: _getSuggestions, //cập nhật danh sách gợi ý dựa trên nội dung nhập
            onSubmitted: widget.onSubmitted, //thực hiện tìm kiếm 
          ),
        ),
        // Hiển thị gợi ý khi có
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index]; //Lấy từng gợi ý từ danh sách _suggestions
                return ListTile(
                  title: Text(
                    suggestion['display_name']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, //Nếu tên quá dài, hiển thị dấu ba chấm
                  ),
                  onTap: () {
                    //Cập nhật nội dung của thanh tìm kiếm với tên địa điểm được chọn
                    widget.controller.text = suggestion['display_name']!;
                    //Gọi hàm xử lý khi chọn gợi ý
                    widget.onSubmitted(suggestion['display_name']!);
                    //Xóa danh sách gợi ý và cập nhật giao diện
                    setState(() => _suggestions = []);
                  },
                );
              },
            ),
          ),
          // Hiển thị trạng thái đang tải
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}