import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/screens/search_result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  final String? search;
  const SearchScreen({super.key, this.search});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  List<String> searchHistory = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    if (widget.search != null) {
      searchController.text = widget.search!;
    }
    _initPrefs();
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Form(
          key: _formKey,
          child: Container(
            height: 36,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: searchController,
              focusNode: focusNode,
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey[600], size: 18),
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              onSubmitted: (value) {
                _searchSubmit(value);
              },
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: searchHistory.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search History',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _deleteAllHistory(),
                        child: Text('Clear',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            )),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      itemCount: searchHistory.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => _searchSubmit(searchHistory[index]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.search,
                                      size: 18, color: Colors.grey[600]),
                                  SizedBox(width: 24),
                                  Text(
                                    searchHistory[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () => _deleteHistory(index),
                                icon: Icon(Icons.delete,
                                    size: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(),
    );
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _searchSubmit(String? search) async {
    if (searchHistory.contains(search)) {
      searchHistory.remove(search);
    }
    searchHistory.insert(0, search ?? searchController.text);
    prefs.setStringList('searchHistory', searchHistory);
    if (widget.search != null) {
      Navigator.pop(context);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SearchResultScreen(
                search: search ?? searchController.text,
              )),
    );
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
      searchController.text = '';
    });
  }

  Future<void> _deleteAllHistory() async {
    prefs.setStringList('searchHistory', []);
    setState(() {
      searchHistory = [];
    });
  }

  Future<void> _deleteHistory(int index) async {
    prefs.setStringList('searchHistory',
        searchHistory.sublist(0, index) + searchHistory.sublist(index + 1));
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }
}
