import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConsoleScreen extends StatefulWidget {
  const SupabaseConsoleScreen({super.key});

  @override
  State<SupabaseConsoleScreen> createState() => _SupabaseConsoleScreenState();
}

class _SupabaseConsoleScreenState extends State<SupabaseConsoleScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    print("Fetching users...");
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .order('created_at', ascending: false);
    setState(() {
      _users = response;
      print(_users);
    });
  }

  Future<void> _createUser() async {
    await Supabase.instance.client.from('users').insert({
      'name': _nameController.text,
      'email': _emailController.text,
    });
    _nameController.clear();
    _emailController.clear();
    await _fetchUsers();
  }

  Future<void> _deleteUser(int id) async {
    await Supabase.instance.client.from('users').delete().eq('id', id);
    await _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase CRUD'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createUser,
              child: const Text('Add User'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUsers,
              child: const Text('Fetch Users'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                      title: Text(user['name'] ?? ''),
                      subtitle: Text(user['email'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteUser(user['id']),
                      ),
                      onTap: () {
                        print("Passing User data: $user}");
                        Navigator.pushNamed(
                          context,
                          '/certificate_preview',
                          arguments: user,
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
