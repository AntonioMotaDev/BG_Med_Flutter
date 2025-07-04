import 'package:bg_med/core/providers/theme_provider.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileMenu extends ConsumerWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isDarkMode = ref.watch(isDarkModeProvider);
    final primaryColor = isDarkMode ? AppTheme.primaryBlueDark : AppTheme.primaryBlue;
    final destructiveColor = isDarkMode ? AppTheme.accentRedDark : AppTheme.accentRed;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle_outlined),
      onSelected: (String value) {
        switch (value) {
          case 'profile':
            _showEditProfileDialog(context, ref, user, isDarkMode);
            break;
          case 'logout':
            _showLogoutDialog(context, ref, isDarkMode);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.edit, color: primaryColor),
              const SizedBox(width: 12),
              const Text('Editar Perfil'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: destructiveColor),
              const SizedBox(width: 12),
              const Text('Cerrar Sesión'),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, dynamic user, bool isDarkMode) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado')),
      );
      return;
    }

    final nameController = TextEditingController(text: user.name);
    final primaryColor = isDarkMode ? AppTheme.primaryBlueDark : AppTheme.primaryBlue;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Email: ${user.email}',
              style: TextStyle(
                color: isDarkMode ? AppTheme.textSecondaryDark : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar actualización de perfil
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Perfil actualizado exitosamente'),
                  backgroundColor: primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final primaryColor = isDarkMode ? AppTheme.primaryBlueDark : AppTheme.primaryBlue;
    final destructiveColor = isDarkMode ? AppTheme.accentRedDark : AppTheme.accentRed;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sesión cerrada exitosamente'),
                      backgroundColor: primaryColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: $e'),
                      backgroundColor: destructiveColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: destructiveColor,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
} 