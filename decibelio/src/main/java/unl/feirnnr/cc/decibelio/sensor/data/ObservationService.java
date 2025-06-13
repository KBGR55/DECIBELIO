package unl.feirnnr.cc.decibelio.sensor.data;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.annotation.Nullable;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
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
        String jpql = "SELECT m FROM Observation m " +
                "WHERE " +
                "  m.date = (" +
                "    SELECT MAX(m2.date) " +
                "    FROM Observation m2 " +
                "    WHERE m2.sensorExternalId = m.sensorExternalId" +
                "  ) " +
                "  AND m.id = (" +
                "    SELECT MAX(m3.id) " +
                "    FROM Observation m3 " +
                "    WHERE m3.sensorExternalId = m.sensorExternalId " +
                "      AND m3.date = m.date" +
                "  ) " +
                "  AND EXISTS (" +
                "    SELECT s FROM Sensor s " +
                "    WHERE s.externalId = m.sensorExternalId " +
                "      AND s.sensorStatus = :activeStatus" +
                "  )";

        Map<String, Object> parameters = new HashMap<>();
        parameters.put("activeStatus", SensorStatus.ACTIVE);

        return crudService.findWithQuery(jpql, parameters);
    }

    /**
     * Busca observaciones en un rango de fechas, filtrando cada hora a múltiplos de
     * intervalMinutes,
     * para un sensor (opcional). Se usa consulta nativa para manejar EXTRACT(...) y
     * MOD(...).
     *
     * @param sensorExternalId Opcional, si se quiere filtrar por sensor.
     * @param startDate        Fecha inicial (inclusive).
     * @param endDate          Fecha final (inclusive).
     * @param intervalMinutes  Intervalo en minutos (e.g. 30 para cada media hora).
     * @return Lista de Observation que cumplen el criterio.
     */
    public List<Observation> findMetricsBySensorAndDateRangeWithInterval(
            @Nullable String sensorExternalId,
            @NotNull LocalDate startDate,
            @NotNull LocalDate endDate,
            @NotNull Integer intervalMinutes) {

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * ")
                .append("FROM public.observation o ")
                .append("WHERE o.date BETWEEN ? AND ? ")
                .append("  AND MOD(EXTRACT(MINUTE FROM o.quantity_time), ?) = 0 ");

        // Usamos 'o.sensorexternalid' en lugar de 'o.sensor_external_id'
        if (sensorExternalId != null && !sensorExternalId.isEmpty()) {
            sql.append("AND o.sensorexternalid = ? ");
        }

        sql.append("ORDER BY o.date ASC, o.quantity_time ASC");

        Query nativeQuery = crudService.getEntityManager()
                .createNativeQuery(sql.toString(), Observation.class);

        int index = 1;
        nativeQuery.setParameter(index++, Date.valueOf(startDate)); // primer '?'
        nativeQuery.setParameter(index++, Date.valueOf(endDate)); // segundo '?'
        nativeQuery.setParameter(index++, intervalMinutes); // tercer '?'

        if (sensorExternalId != null && !sensorExternalId.isEmpty()) {
            nativeQuery.setParameter(index++, sensorExternalId); // cuarto '?'
        }

        @SuppressWarnings("unchecked")
        List<Observation> resultados = nativeQuery.getResultList();
        return resultados;
    }

    /**
     * Recupera las métricas de observación (maximo) según si la
     * hora es diurna o nocturna
     * agrupado por la hora en cada periodo (diurno/nocturno).
     * 
     * @param date Fecha a consultar.
     * @return Lista de métricas agrupadas por TimeFrame (diurno/nocturno)
     */
    public List<Observation> findMaxMetricsByDayAndNight(@NotNull LocalDate date, @NotNull String sensorExternalId) {
        String query = "SELECT o " +
                "FROM Observation o " +
                "JOIN o.timeFrame tf " +
                "WHERE o.date = :date " +
                "AND tf.name IN ('DIURNO', 'NOCTURNO') " +
                "AND o.sensorExternalId = :sensorExternalId " +
                "AND o.quantity.value = (SELECT MAX(o2.quantity.value) FROM Observation o2 WHERE o2.timeFrame.id = o.timeFrame.id AND o2.date = :date AND o2.sensorExternalId = :sensorExternalId) "
                +
                "ORDER BY tf.name, o.quantity.time";
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("date", date);
        parameters.put("sensorExternalId", sensorExternalId);
    
        return crudService.findWithQuery(query, parameters);
    }
    
    public List<Observation> findMinMetricsByDayAndNight(@NotNull LocalDate date, @NotNull String sensorExternalId) {
        String query = "SELECT o " +
                "FROM Observation o " +
                "JOIN o.timeFrame tf " +
                "WHERE o.date = :date " +
                "AND tf.name IN ('DIURNO', 'NOCTURNO') " +
                "AND o.sensorExternalId = :sensorExternalId " +
                "AND o.quantity.value = (SELECT MIN(o2.quantity.value) FROM Observation o2 WHERE o2.timeFrame.id = o.timeFrame.id AND o2.date = :date AND o2.sensorExternalId = :sensorExternalId) "
                +
                "ORDER BY tf.name, o.quantity.time";
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("date", date);
        parameters.put("sensorExternalId", sensorExternalId);
    
        return crudService.findWithQuery(query, parameters);
    }
    
    public List<Map<String, Object>> findAvgByTimeFrame(@NotNull LocalDate date, @NotNull String sensorExternalId) {
        String query = "SELECT " +
                "   tf.name AS timeFrame, " +
                "   AVG(o.quantity.value) AS avgValue, " +
                "   o.sensorExternalId, " +
                "   o.geoLocation.latitude AS geo_latitude, " +
                "   o.geoLocation.longitude AS geo_longitude " +
                "FROM Observation o " +
                "JOIN o.timeFrame tf " +
                "WHERE o.date = :date " +
                "AND o.sensorExternalId = :sensorExternalId " +
                "AND tf.name IN ('DIURNO', 'NOCTURNO') " +
                "GROUP BY tf.name, o.sensorExternalId, o.geoLocation.latitude, o.geoLocation.longitude";
    
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("date", date);
        parameters.put("sensorExternalId", sensorExternalId);
    
        List<Object[]> results = crudService.findWithQuery(query, parameters);
    
        // Transforming the result into a List of Maps with more descriptive keys
        List<Map<String, Object>> response = new ArrayList<>();
        for (Object[] result : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("timeFrame", result[0]);
            map.put("avgValue", result[1]);
            map.put("sensorExternalId", result[2]);
            map.put("geoLatitude", result[3]);
            map.put("geoLongitude", result[4]);
            response.add(map);
        }
    
        return response;
    }
    
    public List<Map<String, Object>> findMetricsByTimeFrame(@NotNull LocalDate date, @NotNull String sensorExternalId) {
        String query = "SELECT " +
                "   tf.name AS timeFrame, " +
                "   MIN(o.quantity.value) AS minValue, " +
                "   MAX(o.quantity.value) AS maxValue, " +
                "   AVG(o.quantity.value) AS avgValue, " +
                "   o.sensorExternalId, " +
                "   o.geoLocation.latitude AS geo_latitude, " +
                "   o.geoLocation.longitude AS geo_longitude, " +
                "   tf.startTime AS startTime, " +  // Agregado startTime
                "   tf.endTime AS endTime " +      // Agregado endTime
                "FROM Observation o " +
                "JOIN o.timeFrame tf " +
                "WHERE o.date = :date " +
                "AND o.sensorExternalId = :sensorExternalId " +
                "AND tf.name IN ('DIURNO', 'NOCTURNO') " +
                "GROUP BY tf.name, o.sensorExternalId, o.geoLocation.latitude, o.geoLocation.longitude, tf.startTime, tf.endTime";  // Asegurarme de incluir startTime y endTime en el GROUP BY
    
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("date", date);
        parameters.put("sensorExternalId", sensorExternalId);
    
        List<Object[]> results = crudService.findWithQuery(query, parameters);
    
        // Transforming the result into a List of Maps with more descriptive keys
        List<Map<String, Object>> response = new ArrayList<>();
        for (Object[] result : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("timeFrame", result[0]);
            map.put("minValue", result[1]);
            map.put("maxValue", result[2]);
            map.put("avgValue", result[3]);
            map.put("sensorExternalId", result[4]);
            map.put("geoLatitude", result[5]);
            map.put("geoLongitude", result[6]);
            map.put("startTime", result[7]);  // Se añade el valor de startTime
            map.put("endTime", result[8]);    // Se añade el valor de endTime
            response.add(map);
        }    
        return response;
    }
    
    
    /**
     * Genera "ALTO" / "BAJO" para una observación, dado un Sensor y su Quantity.
     * @param sensor   Sensor al cual pertenece la medición (ya debe estar cargado con LandUse).
     * @param quantity Objeto Quantity que contiene getValue() (número) y getTime() (LocalTime).
     * @return "ALTO" o "BAJO" según la comparación, o null si no se pudodeterminar.
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
