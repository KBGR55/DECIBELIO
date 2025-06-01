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

     /**
     * Lista todos los usuarios con status = true (activos).
     * Notar que la tabla se llama "USER" entre comillas (exactamente así).
     */
    public List<User> findAllActive() {
        return crudService.findWithNativeQuery(
            "SELECT * FROM \"USER\" WHERE status = TRUE",
            User.class
        );
     }
 
     /**
      * Lista todos los usuarios con status = false (inactivos).
      */
     public List<User> findAllInactive() {
         return crudService.findWithNativeQuery(
             "SELECT * FROM \"USER\" WHERE status = FALSE",
             User.class
         );
     }
 
     /**
      * Busca un usuario por email, sin importar su estado.
      * @param email Correo electrónico a buscar (único).
      * @return Usuario encontrado o null si no existe.
      */
     public User findByEmailTrueFalse(String email) {
         // JPQL: aquí JPA traduce correctamente la entidad User a la tabla "USER"
         String jpql = "SELECT u FROM User u WHERE u.email = :email";
         Map<String, Object> params = new HashMap<>();
         params.put("email", email);
         List<User> resultList = crudService.findWithQuery(jpql, params);
         if (resultList != null && !resultList.isEmpty()) {
             return resultList.get(0);
         }
         return null;
     }

    
}
