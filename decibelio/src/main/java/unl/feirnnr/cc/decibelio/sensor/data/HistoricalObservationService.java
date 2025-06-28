package unl.feirnnr.cc.decibelio.sensor.data;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.Query;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.HistoricalObservation;

@Stateless
public class HistoricalObservationService {

    @Inject
    CrudService crudService;

    public HistoricalObservation save(HistoricalObservation historicalObservation) {
        return historicalObservation.getId() == null ? crudService.create(historicalObservation)
                : crudService.update(historicalObservation);
    }

    public HistoricalObservation findById(@NotNull Long id) {
        HistoricalObservation entity = crudService.find(HistoricalObservation.class, id);
        if (entity != null) {
            return entity;
        }
        throw new EntityNotFoundException("HistoricalObservation not found [" + id + "]");
    }

    public List<HistoricalObservation> findAllHistoricalObservation() {
        return crudService.findWithNativeQuery("select * from historical_observation", HistoricalObservation.class);
    }
    public List<HistoricalObservation> findBySensorAndDateRange(
        @NotNull String sensorExternalId,
        @NotNull LocalDate startDate,
        @NotNull LocalDate endDate) {

            String sql =
            "SELECT " +
            "  o.id, " +
            "  o.date, " +
            "  o.sensorexternalid, " +
            "  o.time_frame_id, " +
            "  o.geo_latitude, " +
            "  o.geo_longitude, " +
            "  o.quantity_value, " +
            "  o.quantity_abbreviation, " +
            "  o.quantity_time, " +
            "  o.qualitative_scale_value_id, " +
            "  o.qualitative_scale_value_name, " +
            "  ho.measurement_type " +                   
            "FROM observation o " +
            "JOIN historical_observation ho ON ho.id = o.id " +
            "WHERE o.sensorexternalid = ? " +
            "  AND o.date BETWEEN ? AND ? " +
            "ORDER BY o.date, o.quantity_time";

        // Creamos la query mapeada a HistoricalObservation.class
        Query q = crudService.createNativeQuery(sql, HistoricalObservation.class);
        q.setParameter(1, sensorExternalId);
        q.setParameter(2, Date.valueOf(startDate));
        q.setParameter(3, Date.valueOf(endDate));

        @SuppressWarnings("unchecked")
        List<HistoricalObservation> list = q.getResultList();
        return list;
    }

}
