package unl.feirnnr.cc.decibelio.user.business;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

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

    public Rol findByRol(@NotNull String type){
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
     * @param firstName Nombre del usuario.
     * @param lastName Apellido del usuario.
     * @param email email electrónico del usuario.
     * @return El usuario creado con su rol por defecto.
     */
    public User createUserWithDefaultRole(String firstName, String lastName, String email) {
        return userRolService.createUserWithDefaultRole(firstName, lastName, email);
    }

}
