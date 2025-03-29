import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_menu.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _searchQuery = '';
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 2; // Set to 2 for Users tab

  @override
  Widget build(BuildContext context) {
    // Define the primary indigo color to match other admin screens
    final Color primaryIndigo = Colors.indigo;
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryIndigo, // Updated to use consistent color
        elevation: 4,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Users list
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _firestoreService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryIndigo),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No users found',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                // Filter users based on search query
                final filteredUsers = snapshot.data!.where((user) {
                  final nameMatch =
                      user.name?.toLowerCase().contains(_searchQuery) ?? false;
                  final emailMatch =
                      user.email.toLowerCase().contains(_searchQuery);
                  return _searchQuery.isEmpty || nameMatch || emailMatch;
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No matching users found',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryIndigo.withOpacity(0.1),
                            foregroundColor: primaryIndigo,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: primaryIndigo.withOpacity(0.2),
                          child:
                              user.photoUrl != null && user.photoUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        user.photoUrl!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, __) =>
                                            const Icon(Icons.person),
                                      ),
                                    )
                                  : const Icon(Icons.person),
                        ),
                        title: Text(
                          user.name ?? user.email,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user.role == 'admin'
                                    ? primaryIndigo.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.role == 'admin' ? 'Admin' : 'User',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: user.role == 'admin'
                                      ? primaryIndigo
                                      : Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'change_role') {
                              _showChangeRoleDialog(
                                  context, user, primaryIndigo);
                            } else if (value == 'delete') {
                              _confirmDeleteUser(context, user, primaryIndigo);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'change_role',
                              child: Row(
                                children: [
                                  Icon(Icons.admin_panel_settings,
                                      size: 20, color: primaryIndigo),
                                  const SizedBox(width: 8),
                                  Text('Change Role',
                                      style: TextStyle(color: primaryIndigo)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomMenu(
        currentIndex: _selectedIndex,
        onIndexChanged: (index) {
          if (index == _selectedIndex) return;

          switch (index) {
            case 0: // Dashboard
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
              break;
            case 1: // Destinations
              Navigator.pushReplacementNamed(context, '/manage-destinations');
              break;
            case 2: // Already on Users
              break;
            case 3: // Analytics
              Navigator.pushReplacementNamed(context, '/analytics');
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add user dialog or navigate to add user screen
          _showAddUserDialog(context, primaryIndigo);
        },
        backgroundColor: primaryIndigo,
        child: const Icon(Icons.person_add, color: Colors.white),
        tooltip: 'Add New User',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showChangeRoleDialog(
      BuildContext context, UserModel user, Color primaryIndigo) {
    String newRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change User Role',
            style:
                TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current role: ${user.role}'),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('User'),
              value: 'user',
              groupValue: newRole,
              activeColor: primaryIndigo,
              onChanged: (value) {
                setState(() {
                  newRole = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Admin'),
              value: 'admin',
              groupValue: newRole,
              activeColor: primaryIndigo,
              onChanged: (value) {
                setState(() {
                  newRole = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryIndigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
            onPressed: () async {
              Navigator.pop(context);

              if (newRole != user.role) {
                setState(() {
                  _isLoading = true;
                });

                try {
                  await _firestoreService.updateUserRole(user.uid, newRole);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User role updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() {}); // Refresh the UI
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating user role: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteUser(
      BuildContext context, UserModel user, Color primaryIndigo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete User',
            style:
                TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this user? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.deleteUser(user.uid);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User successfully deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showAddUserDialog(BuildContext context, Color primaryIndigo) {
    // Form values
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String role = 'user';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New User',
            style:
                TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text('User Role', style: TextStyle(color: Colors.grey[700])),
                RadioListTile<String>(
                  title: const Text('Regular User'),
                  value: 'user',
                  groupValue: role,
                  activeColor: primaryIndigo,
                  onChanged: (value) {
                    setState(() {
                      role = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Admin'),
                  value: 'admin',
                  groupValue: role,
                  activeColor: primaryIndigo,
                  onChanged: (value) {
                    setState(() {
                      role = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryIndigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create User'),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Implement user creation logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This feature will be implemented soon'),
                    backgroundColor: Colors.orange,
                  ),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
