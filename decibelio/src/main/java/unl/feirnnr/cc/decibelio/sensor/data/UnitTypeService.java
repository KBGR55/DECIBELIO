package unl.feirnnr.cc.decibelio.sensor.data;

import java.util.List;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.Query;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.UnitType;

@Stateless
public class UnitTypeService {

    @Inject
    CrudService crudService;

    /**
     * Guarda o actualiza un UnitType.
     *
     * @param unitType entidad a guardar o actualizar.
     * @return UnitType guardado o actualizado.
     */
    public UnitType save(@NotNull UnitType unitType) {
        return unitType.getId() == null ? crudService.create(unitType) : crudService.update(unitType);
    }

    /**
     * Busca un UnitType por su ID.
     *
     * @param id identificador del UnitType.
     * @return UnitType encontrado.
     * @throws EntityNotFoundException si no existe el UnitType.
     */
    public UnitType findById(@NotNull Long id) {
        UnitType entity = crudService.find(UnitType.class, id);
        if (entity != null) {
            return entity;
        }
        throw new EntityNotFoundException("UnitType not found [" + id + "]");
    }

    /**
     * Busca un UnitType por nombre y abreviatura.
     *
     * @param name nombre del UnitType.
     * @param abbreviation abreviatura del UnitType.
     * @return UnitType encontrado o null si no existe.
     */
    public UnitType findByNameAndAbbreviation(@NotNull String name, @NotNull String abbreviation) {
        String sql = "SELECT * FROM UnitType WHERE name = ? AND abbreviation = ?";
        Query query = crudService.createNativeQuery(sql, UnitType.class);
        query.setParameter(1, name);
        query.setParameter(2, abbreviation);
        @SuppressWarnings("unchecked")
        List<UnitType> results = query.getResultList();
        if (!results.isEmpty()) {
            return results.get(0);
        }
        return null;
    }

    /**
     * Obtiene todos los UnitType.
     *
     * @return lista de UnitType.
     */
    public List<UnitType> findAll() {
        return crudService.findWithNativeQuery("SELECT * FROM UnitType", UnitType.class);
    }
}
