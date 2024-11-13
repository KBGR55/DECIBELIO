package unl.feirnnr.cc.decibelio.user.business;

import java.util.List;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import unl.feirnnr.cc.decibelio.user.data.RolService;
import unl.feirnnr.cc.decibelio.user.data.UserRolService;
import unl.feirnnr.cc.decibelio.user.model.Rol;
import unl.feirnnr.cc.decibelio.user.model.User;

@Stateless
public class UserFacade {
    
    @Inject
    private RolService rolService;

    @Inject
    private UserRolService userRolService;

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
