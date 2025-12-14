import 'package:domandito/core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'loading_widget.dart';

class GovernoratesScreen extends StatefulWidget {
  const GovernoratesScreen({super.key});

  @override
  State<GovernoratesScreen> createState() => _GovernoratesScreenState();
}

class _GovernoratesScreenState extends State<GovernoratesScreen> {
  final _controller = ScrollController();
  final int _limit = 30;
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _docs = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _controller.addListener(() {
      if (_controller.position.pixels ==
              _controller.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection("governorates")
        .orderBy("id")
        .limit(_limit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _docs.addAll(snapshot.docs);
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(title: const Text("المحافظات"),),
      body: SafeArea(
        child: Column(
          children: [
            // CustomAppbar(isBack: true,title: 'اختر المحافظة',),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: AppConstance.hPadding),
                controller: _controller,
                itemCount: _docs.length + 1,
                itemBuilder: (context, index) {
                  if (index < _docs.length) {
                    final data = _docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name']),
                      onTap: () {
                        Navigator.pop(context, {
                          'id': _docs[index].id,
                          'name': data['name'],
                        });
                      },
                    );
                  } else {
                    return _isLoading
                        ? const Center(child: LoadingWidget())
                        : const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
