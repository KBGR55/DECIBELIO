package unl.feirnnr.cc.decibelio.user.data;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.user.model.Rol;
import unl.feirnnr.cc.decibelio.user.model.User;
import unl.feirnnr.cc.decibelio.user.model.UserRol;

@Stateless
public class UserRolService {

    @Inject
    CrudService crudService;

    @Inject
    RolService rolService;

    @Inject
    UserService userService;

    public UserRol save(@NotNull UserRol userRol) {
        return userRol.getId() == null ? crudService.create(userRol) : crudService.update(userRol);
    }

    /**
     * Recupera todas las relaciones UserRol activas para un usuario específico.
     * 
     * @param user Usuario del cual se buscan roles activos.
     */
    public List<UserRol> findByUser(User user) {
        String jpql = "SELECT ur FROM UserRol ur WHERE ur.user = :user AND ur.status = TRUE";
        Map<String, Object> params = new HashMap<>();
        params.put("user", user);
        return crudService.findWithQuery(jpql, params);
    }

  /**
     * Crea un usuario (si no existe) y le asigna el rol por defecto (defaulRol).
     * @param firstName  Nombre del usuario.
     * @param lastName   Apellido del usuario.
     * @param email      Correo del usuario.
     * @return El usuario creado (o existente) con el rol por defecto asignado.
     */
    public User createUserWithDefaultRole(String firstName, String lastName, String email) {
        // 1. Verificar si ya existe un usuario con ese email
        User user = userService.findByEmail(email);
        if (user == null) {
            // Si no existe, creamos uno nuevo
            user = new User(firstName, lastName, email);
            user.setStatus(true);
            userService.save(user);
        }

        // 2. Recuperar el rol por defecto (o crearlo si no existe)
        Rol defaultRol = rolService.getOrCreateDefaultRol();
        if (defaultRol == null) {
            throw new IllegalStateException(
                "No se pudo obtener ni crear el rol por defecto '" + rolService.defaulRol + "'.");
        }

        // 3. Verificar si el usuario ya tiene asignado ese rol (status = TRUE)
        List<UserRol> existingRelations = findByUser(user);
        boolean yaTieneRol = existingRelations.stream()
                .anyMatch(ur -> ur.getRol().getType().equals(defaultRol.getType()));

        if (!yaTieneRol) {
            // 4. Crear la relación UserRol (status = TRUE).
            UserRol userRol = new UserRol();
            userRol.setUser(user);
            userRol.setRol(defaultRol);
            userRol.setStatus(true);
            crudService.create(userRol);
        }

        return user;
    }

}