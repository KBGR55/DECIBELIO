package unl.feirnnr.cc.decibelio.user.data;

import org.eclipse.microprofile.config.inject.ConfigProperty;

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
    @ConfigProperty(name = "defaulRol", defaultValue = "VISOR_GENERAL")
    private String defaulRol;

    
    public UserRol save(@NotNull UserRol userRol) {
        return userRol.getId() == null ? crudService.create(userRol) : crudService.update(userRol);
    }

    public User createUserWithDefaultRole(String firstName, String lastName, String email) {
        // Crear el nuevo usuario
        User user = new User(firstName, lastName, email);
        crudService.create(user);  // Usar CrudService para crear el usuario
        System.out.println(user);

        // Buscar el rol "VISOR_GENERAL"
        Rol rol = rolService.findByType(defaulRol);
        if (rol == null) {
            throw new IllegalStateException("El rol por defecto 'VISOR_GENERAL' no se encuentra.");
        }
        // Crear la relación entre el usuario y el rol
        UserRol userRol = new UserRol();
        userRol.setUser(user);
        userRol.setRol(rol);
        crudService.create(userRol);  // Usar CrudService para guardar la relación

        return user;  // Retornar el usuario creado con el rol asignado
    }

}