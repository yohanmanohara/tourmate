import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final double contentPadding = isSmallScreen ? 12.0 : 16.0;

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
            padding: EdgeInsets.all(contentPadding),
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
                  return _buildEmptyState(
                    icon: Icons.person_off,
                    message: 'No users found',
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
                  return _buildEmptyState(
                    icon: Icons.search_off,
                    message: 'No matching users found',
                    showClearButton: true,
                    primaryIndigo: primaryIndigo,
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(contentPadding / 2),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(user, primaryIndigo, isSmallScreen);
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

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    bool showClearButton = false,
    Color? primaryIndigo,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (showClearButton && primaryIndigo != null) ...[
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
        ],
      ),
    );
  }

  Widget _buildUserCard(
      UserModel user, Color primaryIndigo, bool isSmallScreen) {
    final double verticalPadding = isSmallScreen ? 6.0 : 8.0;
    final double fontSize = isSmallScreen ? 11.0 : 12.0;

    return Card(
      margin: EdgeInsets.symmetric(
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: verticalPadding,
        ),
        leading: SizedBox(
          width: isSmallScreen ? 36 : 40,
          height: isSmallScreen ? 36 : 40,
          child: CircleAvatar(
            backgroundColor: primaryIndigo.withOpacity(0.2),
            child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      user.photoUrl!,
                      width: isSmallScreen ? 36 : 40,
                      height: isSmallScreen ? 36 : 40,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) =>
                          Icon(Icons.person, size: isSmallScreen ? 18 : 24),
                    ),
                  )
                : Icon(Icons.person, size: isSmallScreen ? 18 : 24),
          ),
        ),
        title: Text(
          user.name ?? user.email,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 13 : 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: TextStyle(fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(
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
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color:
                      user.role == 'admin' ? primaryIndigo : Colors.green[700],
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: isSmallScreen ? 20 : 24),
          onSelected: (value) async {
            if (value == 'change_role') {
              _showChangeRoleDialog(context, user, primaryIndigo);
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
                  Text('Change Role', style: TextStyle(color: primaryIndigo)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeRoleDialog(
      BuildContext context, UserModel user, Color primaryIndigo) {
    String newRole = user.role;
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            'Change User Role',
            style: TextStyle(
              color: primaryIndigo,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          contentPadding: const EdgeInsets.only(top: 20),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current role: ${user.role}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Theme(
                    data: Theme.of(context).copyWith(
                      listTileTheme: ListTileTheme.of(context).copyWith(
                        dense: isSmallScreen,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
              child: const Text('Save'),
              onPressed: () async {
                Navigator.pop(context);

                if (newRole != user.role) {
                  // Update the parent state to show loading indicator
                  this.setState(() {
                    _isLoading = true;
                  });

                  try {
                    await _firestoreService.updateUserRole(user.uid, newRole);

                    if (mounted) {
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User role updated successfully'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // Force rebuild the widget to refresh the user list
                      this.setState(() {
                        // This empty setState will trigger a rebuild
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating user role: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      // Turn off loading indicator
                      this.setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
            ),
          ],
        );
      }),
    );
  }

  Future<void> _confirmDeleteUser(
      BuildContext context, UserModel user, Color primaryIndigo) async {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete User',
          style: TextStyle(
            color: primaryIndigo,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this user? This action cannot be undone.',
          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
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
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting user: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
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
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Add New User',
              style: TextStyle(
                color: primaryIndigo,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 18 : 20,
              ),
            ),
            contentPadding: const EdgeInsets.only(top: 20),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(
                        controller: nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      _buildTextField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      _buildTextField(
                        controller: passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'User Role',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          listTileTheme: ListTileTheme.of(context).copyWith(
                            dense: isSmallScreen,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                    ],
                  ),
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
                child: isProcessing
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Create User'),
                onPressed: isProcessing
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          // Set processing state
                          setState(() {
                            isProcessing = true;
                          });

                          try {
                            // Create a new Firebase Auth user
                            final userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            if (userCredential.user != null) {
                              // Update the user's display name
                              await userCredential.user!.updateDisplayName(
                                nameController.text.trim(),
                              );

                              // Create a UserModel
                              final newUser = UserModel(
                                uid: userCredential.user!.uid,
                                email: emailController.text.trim(),
                                role: role,
                                name: nameController.text.trim(),
                                photoUrl: null,
                              );

                              // Store in Firestore
                              await _firestoreService.createUser(newUser);

                              // Close dialog
                              if (mounted) {
                                Navigator.pop(context);

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'User ${emailController.text} created successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                // Refresh the UI
                                this.setState(() {});
                              }
                            }
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              isProcessing = false;
                            });

                            String errorMessage = 'Failed to create user';

                            switch (e.code) {
                              case 'email-already-in-use':
                                errorMessage = 'Email is already in use';
                                break;
                              case 'invalid-email':
                                errorMessage = 'Invalid email format';
                                break;
                              case 'weak-password':
                                errorMessage = 'Password is too weak';
                                break;
                              case 'operation-not-allowed':
                                errorMessage = 'User creation is not enabled';
                                break;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              isProcessing = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error creating user: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    bool isSmallScreen = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: isSmallScreen ? 18 : 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 12 : 16,
          horizontal: isSmallScreen ? 8 : 12,
        ),
      ),
      validator: validator,
    );
  }
}
