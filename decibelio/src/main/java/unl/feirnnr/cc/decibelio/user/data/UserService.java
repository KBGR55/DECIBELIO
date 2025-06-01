package unl.feirnnr.cc.decibelio.user.data;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.user.model.User;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

      /**
     * Busca un usuario por email.
     * @param email Correo electrónico a buscar.
     * @return Usuario encontrado o null si no existe.
     */
    public User findByEmail(String email) {
        // Usamos JPQL a través de findWithQuery en CrudService
        String jpql = "SELECT u FROM User u WHERE u.email = :email AND u.status = TRUE";
        Map<String, Object> params = new HashMap<>();
        params.put("email", email);
        List<User> resultList = crudService.findWithQuery(jpql, params);
        if (resultList != null && !resultList.isEmpty()) {
            return resultList.get(0);
        }
        return null;
    }

    
}
