import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  String _selectedType = 'Text';

  final _types = const ['Text', 'URL', 'Contact'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onGeneratePressed() {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter some text or a URL first')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(content: content, type: _selectedType),
      ),
    );
  }

  bool get _isDark => widget.themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('QR generator'),
        actions: [
          IconButton(
            tooltip: _isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(_isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              widget.onThemeChanged(_isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Turn any text or link into a scannable code.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 28),
              Text('Content type',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: _types.map((type) {
                  final selected = type == _selectedType;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        selectedColor: AppTheme.navy,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : null,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedType = type),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              Text('Your content',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                maxLines: _selectedType == 'Contact' ? 4 : 2,
                decoration: InputDecoration(
                  hintText: _selectedType == 'URL'
                      ? 'https://example.com'
                      : _selectedType == 'Contact'
                      ? 'Name, phone, email'
                      : 'Type something to encode',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _onGeneratePressed,
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Generate QR code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}