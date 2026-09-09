import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/airports.dart';

/// A responsive, searchable list the user picks an [Airport] from. Used for
/// both the "From" and "To" fields on the home screen search form — pass
/// [excluding] so the airport already chosen on the other field is greyed
/// out (you can't fly to the airport you're departing from).
class AirportPickerScreen extends StatefulWidget {
  final String title;
  final Airport? excluding;

  const AirportPickerScreen({super.key, required this.title, this.excluding});

  @override
  State<AirportPickerScreen> createState() => _AirportPickerScreenState();
}

class _AirportPickerScreenState extends State<AirportPickerScreen> {
  final _controller = TextEditingController();
  List<Airport> _results = airports;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _results = searchAirports(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: 'Search city, airport or code',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textGrey),
                          onPressed: () {
                            _controller.clear();
                            _onChanged('');
                          },
                        ),
                ),
              ),
            ),
            Expanded(
              child: _results.isEmpty
                  ? const Center(
                      child: Text('No airports match your search', style: TextStyle(color: AppColors.textGrey)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, i) {
                        final airport = _results[i];
                        final disabled = airport == widget.excluding;
                        return ListTile(
                          enabled: !disabled,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.08),
                            child: Text(
                              airport.iata.substring(0, 1),
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            '${airport.city}, ${airport.country}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: disabled ? const Text('Already selected on the other field') : null,
                          trailing: Text(
                            airport.iata,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          onTap: disabled ? null : () => Navigator.pop(context, airport),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
