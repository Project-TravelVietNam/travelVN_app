import 'package:flutter/material.dart';
import 'package:travelvn/service/places_service.dart';

class CustomSearchBarMap extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
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

  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final suggestions = await PlacesService.searchPlaces(query);
      setState(() => _suggestions = suggestions);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(widget.icon),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: _getSuggestions,
            onSubmitted: widget.onSubmitted,
          ),
        ),
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
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(
                    suggestion['display_name']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    widget.controller.text = suggestion['display_name']!;
                    widget.onSubmitted(suggestion['display_name']!);
                    setState(() => _suggestions = []);
                  },
                );
              },
            ),
          ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}