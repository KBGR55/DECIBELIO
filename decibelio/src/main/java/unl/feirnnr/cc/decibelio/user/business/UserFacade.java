package unl.feirnnr.cc.decibelio.user.business;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.user.data.RolService;
import unl.feirnnr.cc.decibelio.user.data.UserRolService;
import unl.feirnnr.cc.decibelio.user.data.UserService;
import unl.feirnnr.cc.decibelio.user.model.Rol;
import unl.feirnnr.cc.decibelio.user.model.User;
import unl.feirnnr.cc.decibelio.user.model.UserRol;

@Stateless
public class UserFacade {

    private static final Logger LOGGER = Logger.getLogger(UserFacade.class.getName());

    @Inject
    private RolService rolService;

    @Inject
    private UserService userService;

    @Inject
    private UserRolService userRolService;

    public User save(@NotNull @Valid User entity) {
        LOGGER.log(Level.OFF, "Saving User entity: {0}", entity);
        return userService.save(entity);
    }

    public Rol findByRol(@NotNull String type) {
        return rolService.findByType(type);
    }

    public UserRol save(@NotNull @Valid UserRol entity) {
        LOGGER.log(Level.OFF, "Saving UserRol entity: {0}", entity);
        return userRolService.save(entity);
    }

    public List<Rol> findAllRoles() {
        return rolService.findAll();
    }

    public List<Rol> findAllActiveRoles() {
        return rolService.findAllActive();
    }

    /**
     * Crea un nuevo usuario con el rol por defecto "VISOR_GENERAL".
     * 
     * @param firstName Nombre del usuario.
     * @param lastName  Apellido del usuario.
     * @param email     email electrónico del usuario.
     * @return El usuario creado con su rol por defecto.
     */
    public User createUserWithDefaultRole(String firstName, String lastName, String email) {
        return userRolService.createUserWithDefaultRole(firstName, lastName, email);
    }

    public List<User> findAllActiveUsers() {
        return userService.findAllActive();
    }

    public List<User> findAllInactiveUsers() {
        return userService.findAllInactive();
    }

    /**
     * Busca un usuario por email, sin importar su estado.
     * 
     * @param email Correo electrónico a buscar.
     * @return Usuario encontrado o null si no existe.
     */
    public User findByEmailTrueFalse(String email) {
        return userService.findByEmailTrueFalse(email);
    }

    /**
     * Asigna (o reactiva) el rol con ID {@code roleId} al usuario con
     * {@code email}.
     * Si el usuario no existe, lanza IllegalArgumentException.
     * Si el rol no existe o está inactivo, lanza IllegalArgumentException.
     * Si ya existía una relación activa, la deja tal cual; si existía pero
     * status=false, la reactiva.
     */
    public UserRol assignRoleToUser(String email, Long roleId) {
        // 1) Buscar usuario por email
        User user = userService.findByEmail(email);
        if (user == null) {
            throw new IllegalArgumentException("Usuario no encontrado con email: " + email);
        }

        // 2) Buscar rol por ID (asegurarnos de que el rol exista y esté status=true)
        Rol rol = rolService.findById(roleId);
        if (rol == null) {
            throw new IllegalArgumentException("Rol no encontrado con id: " + roleId);
        }
        if (!rol.getStatus()) {
            throw new IllegalArgumentException("El rol con id " + roleId + " está inactivo");
        }

        // 3) Verificar si ya existe una relación UserRol (activo o inactivo) entre
        // usuario y rol:
        List<UserRol> relaciones = userRolService.findByUser(user);
        for (UserRol ur : relaciones) {
            if (ur.getRol().getId().equals(roleId)) {
                if (ur.getStatus()) {
                    // Ya estaba activo: devolvemos dicha relación sin cambiar nada
                    return ur;
                } else {
                    // Estaba inactivo: reactivamos
                    ur.setStatus(true);
                    return userRolService.save(ur);
                }
            }
        }

        // 4) Si no existía la relación, creamos una nueva con status = true
        UserRol nueva = new UserRol();
        nueva.setUser(user);
        nueva.setRol(rol);
        nueva.setStatus(true);
        return userRolService.save(nueva);
    }

      public List<String> getRolesForUser(User user) {
        List<UserRol> relaciones = userRolService.findByUser(user);
        return relaciones.stream()
                         .map(ur -> ur.getRol().getType())
                         .collect(Collectors.toList());
    }

}
