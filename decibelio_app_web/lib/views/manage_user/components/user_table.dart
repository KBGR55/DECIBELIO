// lib/views/manage_user/components/user_table.dart

import 'dart:convert'; // Necesario para jsonDecode
import 'package:decibelio_app_web/models/role_dto.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/constants.dart';
import 'package:decibelio_app_web/models/user_dto.dart';
import 'package:decibelio_app_web/services/conexion.dart';

class UserTable extends StatefulWidget {
  final String searchQuery;

  const UserTable({
    super.key,
    required this.searchQuery,
  });

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  bool showActive = true; // true = mostrar usuarios activos, false = inactivos
  List<UserDTO> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Controlador para el scroll horizontal (aparece solo si la tabla desborda)
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserList();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  /// Carga de la lista de usuarios (activos o inactivos) desde el backend.
  Future<void> _loadUserList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Dependiendo de showActive, llamamos al endpoint correspondiente
      final String path = showActive ? 'user/active' : 'user/inactive';
      _users = await _fetchUsersFromApi(path);

      debugPrint(
        'Recibidos ${_users.length} usuarios de ${showActive ? "activos" : "inactivos"}',
      );
      setState(() {});
    } catch (e) {
      debugPrint('Error al cargar usuarios: $e');
      setState(() {
        _users = [];
        _errorMessage = 'No se pudo cargar la lista de usuarios.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Llama a backend a través de Conexion().solicitudGet para obtener lista de usuarios.
  Future<List<UserDTO>> _fetchUsersFromApi(String dirRecurso) async {
    final respuesta = await Conexion().solicitudGet(dirRecurso, Conexion.noToken);

    if (respuesta.status == 'SUCCESS' && respuesta.payload != null) {
      // El payload es un JSON serializado que contiene { "payload": [ ...lista de usuarios...] }
      final Map<String, dynamic> decoded = jsonDecode(respuesta.payload as String);
      final List<dynamic> listaJson = decoded['payload'] as List<dynamic>;

      return listaJson
          .map((u) => UserDTO.fromJson(u as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Error al obtener usuarios: ${respuesta.message}');
  }

  /// Cambia el estado del usuario (activar o desactivar) usando solicitudPut.
  Future<void> _toggleUserStatus(UserDTO user) async {
    final emailEncoded = Uri.encodeComponent(user.email);
    final String path = user.status
        ? 'user/deactivate?email=$emailEncoded'
        : 'user/activate?email=$emailEncoded';

    try {
      // No enviamos body, solo invocamos PUT al endpoint
      final respuesta = await Conexion().solicitudPut(path, {}, Conexion.noToken);

      // Mostramos un AlertDialog con el mensaje devuelto por el servidor
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(user.status ? 'Desactivar Usuario' : 'Activar Usuario'),
          content: Text(respuesta.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Refrescamos la lista para que se refleje el cambio de estado
      _loadUserList();
    } catch (e) {
      debugPrint('Error al cambiar estado de usuario: $e');
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('No se pudo cambiar el estado: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

   /// Abre un diálogo que lista los roles activos disponibles y permite asignar uno.
  Future<void> _openAssignRoleDialog(UserDTO user) async {
    // 1) Obtener roles activos del backend
    List<RoleDTO> rolesDisponibles = [];
    try {
      final resp = await Conexion().solicitudGet('rol/active', Conexion.noToken);
      if (resp.status == 'SUCCESS' && resp.payload != null) {
        final decoded = jsonDecode(resp.payload as String);
        final List<dynamic> listaRolesJson = decoded['payload'] as List<dynamic>;
        rolesDisponibles = listaRolesJson
            .map((r) => RoleDTO.fromJson(r as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('No se obtuvieron roles activos');
      }
    } catch (e) {
      debugPrint('Error al cargar roles activos: $e');
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('No se pudo cargar los roles: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
      return;
    }

    // 2) Mostrar diálogo con Dropdown para seleccionar un rol
    int? selectedRoleId;
    String? selectedRoleType;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Asignar Rol'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    isExpanded: true,
                    hint: const Text('Seleccione un rol'),
                    value: selectedRoleId,
                    items: rolesDisponibles.map((role) {
                      return DropdownMenuItem<int>(
                        value: role.id,
                        child: Text(role.type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedRoleId = value;
                        selectedRoleType = rolesDisponibles
                            .firstWhere((r) => r.id == value!)
                            .type;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: selectedRoleId == null
                      ? null
                      : () async {
                          // 3) Al confirmar, invocar el endpoint PUT de asignar rol
                          final emailEncoded = Uri.encodeComponent(user.email);
                          final path =
                              'user/assign/role?email=$emailEncoded&roleId=$selectedRoleId';
                          try {
                            final respAssign = await Conexion()
                                .solicitudPut(path, {}, Conexion.noToken);

                            await showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Asignar Rol'),
                                content: Text(respAssign.message),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );

                            Navigator.of(context).pop(); // cerrar diálogo
                            _loadUserList(); // refrescar tabla
                          } catch (e) {
                            debugPrint('Error al asignar rol: $e');
                            await showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content:
                                    Text('No se pudo asignar el rol: $e'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                  child: const Text('Asignar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar la lista según searchQuery
    final query = widget.searchQuery.toLowerCase();
    final List<UserDTO> filteredUsers = _users.where((user) {
      final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
      final email = user.email.toLowerCase();
      final roles = user.roles.join(', ').toLowerCase();
      return fullName.contains(query) ||
          email.contains(query) ||
          roles.contains(query);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==================================================
          // 1) Cabecera con botones “Activos” / “Inactivos”
          // ==================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                showActive ? "Usuarios Activos" : "Usuarios Inactivos",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          showActive ? Colors.blue : Colors.transparent,
                      foregroundColor:
                          showActive ? Colors.white : Colors.white70,
                      elevation: showActive ? 2 : 0,
                      minimumSize: const Size(80, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side:
                            const BorderSide(color: Colors.white70, width: 1),
                      ),
                    ),
                    onPressed: () {
                      if (!showActive) {
                        setState(() {
                          showActive = true;
                        });
                        _loadUserList();
                      }
                    },
                    child: const Text("Activos"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !showActive ? Colors.blue : Colors.transparent,
                      foregroundColor:
                          !showActive ? Colors.white : Colors.white70,
                      elevation: !showActive ? 2 : 0,
                      minimumSize: const Size(80, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side:
                            const BorderSide(color: Colors.white70, width: 1),
                      ),
                    ),
                    onPressed: () {
                      if (showActive) {
                        setState(() {
                          showActive = false;
                        });
                        _loadUserList();
                      }
                    },
                    child: const Text("Inactivos"),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ====================================================
          // 2) Mensaje de error si hubo problemas al cargar
          // ====================================================
          if (_errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],

          // ====================================================
          // 3) Indicador de carga mientras se obtienen datos
          // ====================================================
          if (_isLoading) ...[
            const SizedBox(height: defaultPadding),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: defaultPadding),
          ] else ...[
            // ====================================================
            // 4) Si no hay usuarios filtrados, mostramos texto
            // ====================================================
            if (filteredUsers.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No hay usuarios que coincidan.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
              ),
            ] else
              // ====================================================
              // 5) DataTable con scroll horizontal (si hace falta)
              // ====================================================
              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: double.infinity,
                    child: Scrollbar(
                      controller: _horizontalController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16,
                          headingRowHeight: 40,
                          dataRowHeight: 56,
                          horizontalMargin: 12,
                          columns: const [
                            DataColumn(label: Text("Nombre Completo")),
                            DataColumn(label: Text("Email")),
                            DataColumn(label: Text("Roles")),
                            DataColumn(label: Text("Acciones")),
                          ],
                          rows: List.generate(
                            filteredUsers.length,
                            (index) => _userDataRow(
                              filteredUsers[index],
                              constraints.maxWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  /// Construye cada fila del DataTable a partir de un UserDTO.
  /// Usa [tableMaxWidth] para asignar anchos proporcionales a cada columna
  /// y recortar texto con ellipsis si es muy largo.
  DataRow _userDataRow(UserDTO user, double tableMaxWidth) {
    final String fullName = '${user.firstName} ${user.lastName}';
    final String rolesText = user.roles.join(', ');

    // Anchos aproximados para columnas:
    final double nombreWidth = tableMaxWidth * 0.25;
    final double emailWidth = tableMaxWidth * 0.30;
    final double rolesWidth = tableMaxWidth * 0.25;
    // El 20% restante queda para la columna “Acciones”

    return DataRow(cells: [
      // --- Columna: Nombre Completo + avatar
      DataCell(
        SizedBox(
          width: nombreWidth,
          child: Row(
            children: [
              ClipOval(
                child: user.photo.isNotEmpty
                    ? Image.network(
                        user.photo,
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 30,
                            height: 30,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person, size: 20),
                          );
                        },
                      )
                    : Container(
                        width: 30,
                        height: 30,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, size: 20),
                      ),
              ),
              const SizedBox(width: defaultPadding / 2),
              Expanded(
                child: Text(
                  fullName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),

      // --- Columna: Email
      DataCell(
        SizedBox(
          width: emailWidth,
          child: Text(
            user.email,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),

      // --- Columna: Roles
      DataCell(
        SizedBox(
          width: rolesWidth,
          child: Text(
            rolesText,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),

      // --- Columna: Acciones (Switch con Tooltip)
      DataCell(
        SizedBox(
          width: tableMaxWidth * 0.20,
          child: Row(
            children: [
              // Switch para activar/desactivar
              Tooltip(
                message:
                    user.status ? 'Desactivar usuario' : 'Activar usuario',
                child: Switch(
                  value: user.status,
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.redAccent,
                  onChanged: (_) {
                    _toggleUserStatus(user);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // IconButton para “Asignar rol”
              Tooltip(
                message: 'Asignar rol',
                child: IconButton(
                  icon: const Icon(Icons.person_add, size: 20),
                  onPressed: () {
                    _openAssignRoleDialog(user);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
