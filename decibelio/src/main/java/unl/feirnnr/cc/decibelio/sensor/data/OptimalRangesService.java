package unl.feirnnr.cc.decibelio.sensor.data;

import java.util.List;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.Query;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.OptimalRange;


@Stateless
public class OptimalRangesService {
    @Inject
    private CrudService crudService;

      /**
     * Encuentra un OptimalRange por sus identificadores de landUse y timeFrame.
     *
     * @param landUseId   ID del LandUse.
     * @param timeFrameId ID del TimeFrame.
     * @return El OptimalRange encontrado, o null si no hay ninguno.
     */
    public OptimalRange findByLandUseAndTimeFrame(@NotNull Long landUseId, @NotNull Long timeFrameId) {
        // La tabla en BD se llama optimalrange, y las columnas de FK son landuse_id y timeframe_id.
        String sql = 
            "SELECT * " +
            "FROM public.optimalrange r " +
            "WHERE r.landuse_id = ? AND r.timeframe_id = ?";

        Query query = crudService.createNativeQuery(sql, OptimalRange.class);
        query.setParameter(1, landUseId);
        query.setParameter(2, timeFrameId);

        @SuppressWarnings("unchecked")
        List<OptimalRange> resultados = query.getResultList();
        if (resultados.isEmpty()) {
            return null;
        }
        // Suponemos que solo existe uno para cada par (landUse, timeFrame).
        return resultados.get(0);
    }

    /**
     * Opcional: Si quisieras listar todos los rangos de la BD de una vez.
     */
    public List<OptimalRange> findAll() {
        String sql = "SELECT * FROM public.optimalrange";
        @SuppressWarnings("unchecked")
        List<OptimalRange> lista = crudService.createNativeQuery(sql, OptimalRange.class)
                                              .getResultList();
        return lista;
    }
    
}
