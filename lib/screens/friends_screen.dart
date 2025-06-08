import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';
import '../utils/app_theme.dart';
import '../widgets/bottom_menu_bar.dart';
import 'friend_habits_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  List<AppUser> _searchResults = [];
  List<String> _friendUids = [];
  bool _isLoading = true;
  List<AppUser> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final friends = await _userService.getFriendsOfCurrentUser();
    setState(() {
      _friends = friends;
      _friendUids = friends.map((f) => f.uid).toList();
      _isLoading = false;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final results = await _userService.searchUsersByEmail(query);
    setState(() => _searchResults = results);
  }

  Future<void> _addFriend(AppUser friend) async {
    if (_friendUids.contains(friend.uid)) return;
    await _userService.addFriend(friend.uid);
    setState(() {
      _friendUids.add(friend.uid);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${friend.displayName} as a friend.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by email',
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchResults.clear();
                    });
                  },
                )
                    : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchUsers(_searchController.text.trim()),
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() => _searchResults.clear());
                }
              },
              onSubmitted: (value) => _searchUsers(value.trim()),
            ),
            const SizedBox(height: 16),

            if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    final isFriend = _friendUids.contains(user.uid);
                    return ListTile(
                      tileColor: AppTheme.cardColor,
                      title: Text(user.displayName),
                      subtitle: Text(user.email),
                      trailing: isFriend
                          ? const Text('Friend', style: TextStyle(color: Colors.grey))
                          : IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () => _addFriend(user),
                      ),
                    );
                  },
                ),
              )


            else if (_searchController.text.isNotEmpty)
              const Expanded(
                child: Center(child: Text('No users found.')),
              )


            else
              Expanded(
                child: _friends.isEmpty
                    ? const Center(child: Text('You have no friends yet.'))
                    : ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    final friend = _friends[index];
                    return Card(
                      color: AppTheme.cardColor, // sau Color(0xFF8CC695)
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FriendHabitsScreen(friend: friend),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                friend.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                friend.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        )
      ),
      bottomNavigationBar: const BottomMenuBar(currentIndex: 2),
    );
  }
}
