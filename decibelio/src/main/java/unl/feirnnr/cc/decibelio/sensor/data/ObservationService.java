package unl.feirnnr.cc.decibelio.sensor.data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.annotation.Nullable;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.PersistenceContext;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.Observation;
import unl.feirnnr.cc.decibelio.sensor.model.OptimalRange;
import unl.feirnnr.cc.decibelio.sensor.model.Quantity;
import unl.feirnnr.cc.decibelio.sensor.model.Sensor;
import unl.feirnnr.cc.decibelio.sensor.model.SensorStatus;
import unl.feirnnr.cc.decibelio.sensor.model.TimeFrame;

@Stateless
public class ObservationService {

    @Inject
    CrudService crudService;

    @Inject
    SensorService sensorService;

    @Inject
    TimeFrameService timeFrameService;

    @Inject
    OptimalRangesService optimalRangesService;

    @PersistenceContext(unitName = "decibelioPU")
    EntityManager em;

    /**
     * Guarda una entidad Observation. Si la entidad no tiene un ID, se creará.
     * De lo contrario, se actualizará la entidad existente.
     * 
     * @param metric la entidad Observation a ser guardada
     * @return la entidad Observation guardada
     */
    public Observation save(@NotNull Observation metric) {
        return metric.getId() == null ? crudService.create(metric) : crudService.update(metric);
    }

    /**
     * Busca una entidad Observation por su ID.
     * 
     * @param id el ID de la entidad Observation a ser encontrada
     * @return la entidad Observation encontrada
     * @throws EntityNotFoundException si no se encuentra ninguna entidad
     *                                 Observation con
     *                                 el ID dado
     */
    public Observation findById(@NotNull Long id) {
        Observation entity = crudService.find(Observation.class, id);
        if (entity != null) {
            return entity;
        }
        throw new EntityNotFoundException("Observation not found [" + id + "]");
    }

    /**
     * Recupera todas las entidades Observation de la base de datos.
     * 
     * @return una lista de todas las entidades Observation
     */
    public List<Observation> findAll() {
        return crudService.findWithNativeQuery("select * from metric", Observation.class);
    }

    public List<Observation> findLastMetricOfActiveSensors() {
        String query = "SELECT m FROM Observation m " +
                "WHERE m.date = (SELECT MAX(m2.date) FROM Observation m2 WHERE m2.sensorExternalId = m.sensorExternalId) "
                +
                "AND m.id = (SELECT MAX(m3.id) FROM Observation m3 WHERE m3.sensorExternalId = m.sensorExternalId AND m3.date = m.date) "
                +
                "AND EXISTS (SELECT s FROM Sensor s WHERE s.externalId = m.sensorExternalId AND s.sensorStatus = :activeStatus)";

        Map<String, Object> parameters = new HashMap<>();
        parameters.put("activeStatus", SensorStatus.ACTIVE);

        return crudService.findWithQuery(query, parameters);
    }

    public List<Observation> findMetricsBySensorAndDateRangeWithInterval(
            @Nullable String sensorExternalId,
            @NotNull LocalDate startDate,
            @NotNull LocalDate endDate,
            @NotNull Integer intervalMinutes) {

        StringBuilder queryBuilder = new StringBuilder(
                "SELECT m FROM Observation m WHERE m.date BETWEEN :startDate AND :endDate " +
                        "AND MOD(EXTRACT(MINUTE FROM m.time), :intervalMinutes) = 0 ");
        Map<String, Object> parameters = new HashMap<>();

        if (sensorExternalId != null && !sensorExternalId.isEmpty()) {
            queryBuilder.append("AND m.sensorExternalId = :sensorExternalId ");
            parameters.put("sensorExternalId", sensorExternalId);
        }
        queryBuilder.append("ORDER BY m.date ASC, m.time ASC");
        String query = queryBuilder.toString();
        parameters.put("startDate", startDate);
        parameters.put("endDate", endDate);
        parameters.put("intervalMinutes", intervalMinutes);

        return crudService.findWithQuery(query, parameters);
    }

    /**
     * Encuentra las métricas máximas por día y noche para una fecha dada.
     * 
     * @param date Fecha a consultar
     * @return Lista de métricas máximas agrupadas por día y noche
     */
    public List<Observation> findMaxMetricsByDayAndNight(@NotNull LocalDate date) {
        String query = "SELECT m FROM Observation m WHERE m.id IN (" +
                "    SELECT m1.id FROM Observation m1 WHERE m1.date = :date AND " +
                "    EXTRACT(HOUR FROM m1.time) BETWEEN 7 AND 20 AND " +
                "    m1.value = (SELECT MAX(m2.value) FROM Observation m2 WHERE m2.sensorExternalId = m1.sensorExternalId "
                +
                "               AND m2.date = :date AND EXTRACT(HOUR FROM m2.time) BETWEEN 7 AND 20) " +
                ") " +
                "OR m.id IN (" +
                "    SELECT m3.id FROM Observation m3 WHERE m3.date = :date AND " +
                "    (EXTRACT(HOUR FROM m3.time) BETWEEN 21 AND 23 OR EXTRACT(HOUR FROM m3.time) BETWEEN 0 AND 6) AND "
                +
                "    m3.value = (SELECT MAX(m4.value) FROM Observation m4 WHERE m4.sensorExternalId = m3.sensorExternalId "
                +
                "               AND m4.date = :date AND (EXTRACT(HOUR FROM m4.time) BETWEEN 21 AND 23 OR EXTRACT(HOUR FROM m4.time) BETWEEN 0 AND 6)) "
                +
                ")";

        Map<String, Object> parameters = new HashMap<>();
        parameters.put("date", date);

        return crudService.findWithQuery(query, parameters);
    }

    public void processAndSaveObservation(String externalId, Map<String, Object> payloadMap) {

        Sensor sensor = sensorService.findByExternalId(externalId);
        // Parseo de los valores
        float sonLaeq = Float.parseFloat(payloadMap.getOrDefault("son_laeq", "0").toString());
        String timeInstant = payloadMap.get("TimeInstant").toString(); // formato: 2024-05-20T14:45:00.000Z
        LocalDate date = LocalDate.parse(timeInstant.substring(0, 10));
        LocalTime time = LocalTime.parse(timeInstant.substring(11, 19));

        // Construcción de Quantity
        Quantity quantity = new Quantity();
        quantity.setValue(sonLaeq);
        quantity.setTime(time);
        quantity.setAbbreviation("LAeq"); // ← puedes parametrizar esto también

        // Construcción de Observation
        Observation obs = new Observation();
        obs.setDate(date);
        obs.setQuantity(quantity);
        obs.setGeoLocation(sensor.getGeoLocation());
        obs.setSensorExternalId(externalId);
        obs.setQualitativeScaleValue(null);
        obs.setTimeFrame(null); // opcional
        obs.setQuantity(quantity);

        // Persistencia// Necesario si Quantity tiene su propio ID
        em.persist(obs);
    }

    /**
     * Genera "ALTO" / "BAJO" para una observación, dado un Sensor y su Quantity.
     * <p>
     * 1. Obtiene el LandUse del sensor.
     * 2. Obtiene la hora de la cantidad (Quantity).
     * 3. Busca el TimeFrame apropiado (usando timeFrameService).
     * 4. Busca el OptimalRange que corresponde a (landUseId, timeFrameId).
     * 5. Compara quantity.getValue() (asumimos double o BigDecimal) contra
     * range.getValue().
     * 6. Devuelve "ALTO" si value &gt; rango; en otro caso "BAJO".
     *
     * @param sensor   Sensor al cual pertenece la medición (ya debe estar cargado
     *                 con LandUse).
     * @param quantity Objeto Quantity que contiene getValue() (número) y getTime()
     *                 (LocalTime).
     * @return "ALTO" o "BAJO" según la comparación, o null si no se pudo
     *         determinar.
     */
    public String generateRange(@NotNull Sensor sensor, @NotNull Quantity quantity) {
        var landUse = sensor.getLandUse();
        LocalTime hora = quantity.getTime();
        // 3. Buscar el TimeFrame correspondiente
        TimeFrame timeFrame;
        timeFrame = timeFrameService.findByTime(hora);
        // 4. Obtener el OptimalRange según landUse + timeFrame
        OptimalRange range = optimalRangesService.findByLandUseAndTimeFrame(
                landUse.getId(),
                timeFrame.getId());
        // 5. Comparar el valor de la medición vs. rango óptimo
        BigDecimal valorMedido = BigDecimal.valueOf(quantity.getValue());
        BigDecimal valorRango = range.getValue(); // suponemos que getValue() devuelve BigDecimal

        if (valorMedido.compareTo(valorRango) > 0) {
            return "ALTO";
        } else {
            return "BAJO";
        }
    }

}
