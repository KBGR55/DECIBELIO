package unl.feirnnr.cc.decibelio.user.data;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.user.model.User;

import java.util.List;

@Stateless
public class UserService {

    @Inject
    CrudService crudService;

    /**
     * Lista todos los usuarios activos.
     * @return Lista de usuarios activos.
     */
    public List<User> findAllActive() {
       return crudService.findWithNativeQuery("SELECT * FROM user WHERE status = TRUE", User.class);
    }
}
