import 'dart:async';
import 'dart:developer';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/search/users_list.dart';
import 'package:domandito/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  String searchQuery = '';
  Timer? _debounce;
  String valll = '';
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    log('val: $val');
    valll = val;
    setState(() {});
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        searchQuery = val.trim().toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          !context.isCurrentLanguageAr() ? 'Search friends' : 'بحث الأصدقاء',
        ),
        leading: IconButton.filled(
          onPressed: () => context.back(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            CustomTextField(
              padding: 0,
              autoFocus: true,
              label: !context.isCurrentLanguageAr()
                  ? valll.contains('@')
                        ? 'Search by username'
                        : 'Search'
                  : valll.contains('@')
                  ? 'بحث بإسم المستخدم'
                  : 'بحث',
              onChanged: _onSearchChanged, // استخدمنا الديبونس هنا
              suffixIcon: !valll.contains('@') ? null : Text('@'),
            ),
            const SizedBox(height: 16),
            Expanded(child: SearchUsersList(searchQuery: searchQuery)),
          ],
        ),
      ),
    );
  }
}
