package unl.feirnnr.cc.decibelio.user.data;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.user.model.Rol;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Stateless
public class RolService {

    @Inject
    CrudService crudService;

    public List<Rol> findAll() {
        return crudService.findWithNativeQuery("select * from rol", Rol.class);
    }

    public List<Rol> findAllActive() {
        return crudService.findWithNativeQuery("select * from rol where status = TRUE", Rol.class);
    }

    /**
     * Buscar un rol por tipo.
     * 
     * @param tipo El tipo de rol (por ejemplo, "VISOR_GENERAL").
     * @return El rol correspondiente o null si no se encuentra.
     */
    public Rol findByTipo(String tipo) {
        String query = "SELECT * FROM rol WHERE tipo = :tipo AND status = TRUE";
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("tipo", tipo);
        List<Rol> resultList = crudService.findWithQuery(query, parameters);
        if (resultList != null && !resultList.isEmpty()) {
            return resultList.get(0);
        }
        return null;
    }

}
