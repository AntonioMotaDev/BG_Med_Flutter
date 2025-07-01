import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/providers/theme_provider.dart';
import 'package:bg_med/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 24),

              // User Profile Section
              if (user != null) ...[
                _buildSectionTitle('Perfil de Usuario'),
                _buildUserProfileCard(context, ref, user),
                const SizedBox(height: 24),
              ],

              // App Settings Section
              _buildSectionTitle('Configuración de la App'),
              _buildSettingsCard(context, ref, [
                _buildThemeTile(context, ref),
                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: 'Notificaciones',
                  subtitle: 'Configurar alertas y recordatorios',
                  onTap: () => _showNotificationsDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Idioma',
                  subtitle: 'Español (por defecto)',
                  onTap: () => _showLanguageDialog(context),
                ),
              ]),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionTitle('Gestión de Datos'),
              _buildSettingsCard(context, ref, [
                _buildSettingsTile(
                  icon: Icons.backup,
                  title: 'Respaldo de Datos',
                  subtitle: 'Crear copia de seguridad',
                  onTap: () => _showBackupDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.download,
                  title: 'Exportar Datos',
                  subtitle: 'Descargar registros en PDF',
                  onTap: () => _showExportDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.delete_forever,
                  title: 'Limpiar Datos Locales',
                  subtitle: 'Eliminar registros guardados',
                  onTap: () => _showClearDataDialog(context),
                  isDestructive: true,
                ),
              ]),
              const SizedBox(height: 24),

              // About Section
              _buildSectionTitle('Acerca de'),
              _buildSettingsCard(context, ref, [
                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'Información de la App',
                  subtitle: 'BG Med v1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.help,
                  title: 'Ayuda y Soporte',
                  subtitle: 'Guías y contacto',
                  onTap: () => _showHelpDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Política de Privacidad',
                  subtitle: 'Términos y condiciones',
                  onTap: () => _showPrivacyDialog(context),
                ),
              ]),
              const SizedBox(height: 24),

              // Logout Section
              if (user != null) ...[
                _buildLogoutCard(context, ref),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF008080), Color(0xFF7E84F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Personaliza tu experiencia médica',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, WidgetRef ref, dynamic user) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF008080),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7E84F2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7E84F2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditProfileDialog(context, ref, user),
                  icon: const Icon(Icons.edit, color: Color(0xFF008080)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, WidgetRef ref, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF008080).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          themeNotifier.themeIcon,
          color: const Color(0xFF008080),
          size: 20,
        ),
      ),
      title: const Text(
        'Tema de la App',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Modo ${themeNotifier.themeDescription}'),
      trailing: PopupMenuButton<AppThemeMode>(
        icon: const Icon(Icons.arrow_drop_down),
        onSelected: (AppThemeMode mode) {
          themeNotifier.setTheme(mode);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: AppThemeMode.light,
            child: Row(
              children: [
                Icon(Icons.light_mode, size: 20),
                SizedBox(width: 12),
                Text('Claro'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: AppThemeMode.dark,
            child: Row(
              children: [
                Icon(Icons.dark_mode, size: 20),
                SizedBox(width: 12),
                Text('Oscuro'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: AppThemeMode.system,
            child: Row(
              children: [
                Icon(Icons.brightness_auto, size: 20),
                SizedBox(width: 12),
                Text('Sistema'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
              ? const Color(0xFFE53E3E).withOpacity(0.1)
              : const Color(0xFF008080).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? const Color(0xFFE53E3E) : const Color(0xFF008080),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? const Color(0xFFE53E3E) : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLogoutCard(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE53E3E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.logout,
            color: Color(0xFFE53E3E),
            size: 20,
          ),
        ),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFFE53E3E),
          ),
        ),
        subtitle: const Text('Salir de tu cuenta'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showLogoutDialog(context, ref),
      ),
    );
  }

  // Dialog methods
  void _showEditProfileDialog(BuildContext context, WidgetRef ref, dynamic user) {
    final nameController = TextEditingController(text: user.name);
    
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
                const SnackBar(content: Text('Perfil actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
              await ref.read(authNotifierProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53E3E)),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificaciones'),
        content: const Text('Configuración de notificaciones próximamente disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idioma'),
        content: const Text('Configuración de idioma próximamente disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respaldo de Datos'),
        content: const Text('Función de respaldo próximamente disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Datos'),
        content: const Text('Función de exportación próximamente disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Datos Locales'),
        content: const Text('¿Estás seguro? Esta acción eliminará todos los registros guardados localmente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Limpiar datos de Hive
              final frapsBox = Hive.box<Frap>('fraps');
              await frapsBox.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos locales eliminados')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53E3E)),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de BG Med'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BG Med v1.0.0'),
            SizedBox(height: 8),
            Text('Aplicación para el manejo de registros médicos prehospitalarios (FRAP).'),
            SizedBox(height: 8),
            Text('Desarrollado para profesionales de la salud.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda y Soporte'),
        content: const Text('Para soporte técnico, contacta al administrador del sistema.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const Text('Toda la información médica es tratada con la máxima confidencialidad según las normativas de protección de datos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
} 