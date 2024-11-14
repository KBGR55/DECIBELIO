package unl.feirnnr.cc.decibelio.user.data;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.user.model.Rol;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Stateless
public class RolService {

    @Inject
    CrudService crudService;

    public Rol save(@NotNull Rol rol) {
        return rol.getId() == null ? crudService.create(rol) : crudService.update(rol);
    }

    public List<Rol> findAll() {
        return crudService.findWithNativeQuery("select * from rol", Rol.class);
    }

    public List<Rol> findAllActive() {
        return crudService.findWithNativeQuery("select * from rol where status = TRUE", Rol.class);
    }

    /**
     * Buscar un rol por type.
     * 
     * @param type El type de rol (por ejemplo, "VISOR_GENERAL").
     * @return El rol correspondiente o null si no se encuentra.
     */
    public Rol findByType(String type) {
        String query = "SELECT r FROM Rol r WHERE r.type = :type AND r.status = TRUE";
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("type", type);
        List<Rol> resultList = crudService.findWithQuery(query, parameters);
        if (resultList != null && !resultList.isEmpty()) {
            return resultList.get(0);
        }
        return null;
    }    

}
