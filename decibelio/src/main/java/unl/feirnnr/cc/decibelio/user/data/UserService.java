package unl.feirnnr.cc.decibelio.user.data;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.user.model.User;

import java.util.List;

@Stateless
public class UserService {

    @Inject
    CrudService crudService;

    
    public User save(@NotNull User user) {
        System.out.println(user);
        return user.getId() == null ? crudService.create(user) : crudService.update(user);
    }

    /**
     * Lista todos los usuarios activos.
     * @return Lista de usuarios activos.
     */
    public List<User> findAllActive() {

       return crudService.findWithNativeQuery("SELECT * FROM User WHERE status = TRUE", User.class);
    }
}
