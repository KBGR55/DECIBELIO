package unl.feirnnr.cc.decibelio.sensor.data;

import java.util.List;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.Query;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.Range;

@Stateless
public class RangeService {

    @Inject
    CrudService crudService;

    /**
     * Encuentra un rango por su ID.
     *
     * @param id El ID del rango.
     * @return El rango encontrado.
     * @throws EntityNotFoundException Si el rango no se encuentra.
     */
    public Range findById(@NotNull Long id) {
        Range entity = crudService.find(Range.class, id);
        if (entity != null) {
            return entity;
        }
        throw new EntityNotFoundException("Range not found [" + id + "]");
    }

    /**
     * Encuentra todos los rangos.
     *
     * @return Lista de todos los rangos.
     */
    public List<Range> findAll() {
        return crudService.findWithNativeQuery("select * from range", Range.class);
    }

    /**
     * Encuentra un rango por sus identificadores de landUse y timeFrame.
     *
     * @param landUseId 
     * @param timeFrameId 
     * @return El rango encontrado, o nulo si no se encuentra.
     */
    public Range findByLandUseAndTimeFrame(@NotNull Long landUseId, @NotNull Long timeFrameId) {
        String sql = "SELECT * FROM Range WHERE landUse_id = ? AND timeFrame_id = ?";
        Query query = crudService.createNativeQuery(sql, Range.class);
        query.setParameter(1, landUseId);
        query.setParameter(2, timeFrameId);
        @SuppressWarnings("unchecked")
        List<Range> ranges = query.getResultList();
        if (!ranges.isEmpty()) {
            return ranges.get(0);
        }
        return null;
    }
    
}