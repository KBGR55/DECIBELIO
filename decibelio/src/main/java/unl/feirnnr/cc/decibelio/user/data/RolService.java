package unl.feirnnr.cc.decibelio.user.data;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.user.model.Rol;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@Stateless
public class RolService {

    @Inject
    CrudService crudService;

    @Inject
    @ConfigProperty(name = "defaulRol", defaultValue = "VISOR_GENERAL")
    public String defaulRol;

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
     * Busca un rol por su campo "type" (y status = TRUE).
     * Si no existe, lo crea en BD con el valor por defecto de "defaulRol".
     */
    public Rol findByType(String type) {
        String jpql = "SELECT r FROM Rol r WHERE r.type = :type AND r.status = TRUE";
        Map<String, Object> params = new HashMap<>();
        params.put("type", type);
        List<Rol> resultList = crudService.findWithQuery(jpql, params);

        if (resultList != null && !resultList.isEmpty()) {
            return resultList.get(0);
        }

        // Si no existe un rol activo con ese type, lo creamos automáticamente
        Rol nuevoRol = new Rol(type);
        nuevoRol.setStatus(true);
        return crudService.create(nuevoRol);
    }

    /**
     * Devuelve el rol por defecto, creándolo si no existe (usa la propiedad defaulRol).
     */
    public Rol getOrCreateDefaultRol() {
        return findByType(defaulRol);
    }   

    /**
     * Busca un Rol por su ID.
     * @param id Identificador de Rol.
     * @return Rol encontrado, o null si no existe.
     */
    public Rol findById(Long id) {
        return crudService.find(Rol.class, id);
    }
    

}
