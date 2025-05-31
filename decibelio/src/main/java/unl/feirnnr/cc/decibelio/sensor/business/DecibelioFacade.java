package unl.feirnnr.cc.decibelio.sensor.business;

import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.dto.ObservationDTO;
import unl.feirnnr.cc.decibelio.sensor.data.LandUseService;
import unl.feirnnr.cc.decibelio.sensor.data.ObservationService;
import unl.feirnnr.cc.decibelio.sensor.data.QualitativeScaleService;
import unl.feirnnr.cc.decibelio.sensor.data.RangeService;
import unl.feirnnr.cc.decibelio.sensor.data.SensorService;
import unl.feirnnr.cc.decibelio.sensor.data.UnitTypeService;
import unl.feirnnr.cc.decibelio.sensor.model.LandUse;
import unl.feirnnr.cc.decibelio.sensor.model.GeoLocation;
import unl.feirnnr.cc.decibelio.sensor.model.Observation;
import unl.feirnnr.cc.decibelio.sensor.model.OptimalRange;
import unl.feirnnr.cc.decibelio.sensor.model.QualitativeScale;
import unl.feirnnr.cc.decibelio.sensor.model.Sensor;
import unl.feirnnr.cc.decibelio.sensor.model.TimeFrame;
import unl.feirnnr.cc.decibelio.sensor.model.UnitType;


import java.util.List;
import java.util.ArrayList;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

@Stateless
public class DecibelioFacade {

    private static final Logger LOGGER = Logger.getLogger(DecibelioFacade.class.getName());

    @Inject
    SensorService sensorService;

    @Inject
    LandUseService landUseService;
    @Inject
    ObservationService observationService;
    @Inject
    RangeService rangeService;
    @Inject
    UnitTypeService unitTypeService;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm:ss");

    private Observation insert(@NotNull ObservationDTO  observationDTO) {
        LOGGER.log(Level.INFO, "Inserting observation: {0}", observationDTO);

       
        Observation observation = new Observation();
        observation.setDate(observationDTO.getDate());
        observation.setSensorExternalId(observationDTO.getSensorExternalId());
        //        observation.setValue(observationDTO.getValue());
    
        return observationService.save(observation);        
    }

    public Sensor save(@NotNull @Valid Sensor entity) {
        LOGGER.log(Level.OFF, "Saving Sensor entity: {0}", entity);
        return sensorService.save(entity);
    }

    public Sensor findBySensorId(@NotNull Long id) {
        return sensorService.findById(id);
    }

    public List<Sensor> findAllSensors() {
        return sensorService.findAll();
    }

    public List<Sensor> findAllSensorsActive() {
        return sensorService.findAllActive();
    }

    public LandUse findByLandUseId(@NotNull Long id) {
        return landUseService.findById(id);
    }

    public List<LandUse> findAllLandUse() {
        return landUseService.findAll();
    }

    /**
     * Encuentra todas las Métricas.
     * 
     * @return una lista de todas las Métricas
     */
    public List<Observation> findAllMetrics() {
        return observationService.findAll();
    }

    /**
     * Encuentra todos los Rangos.
     * 
     * @return una lista de todos los Rangos
     */
    public List<OptimalRange> findAllRanges() {
        return rangeService.findAll();
    }

    public Sensor findByExternalId(@NotNull String externalId) {
        return sensorService.findByExternalId(externalId);
    }

    /**
     * Guarda una lista de Métricas en la base de datos. Si ocurre un error, la
     * transacción se revertirá.
     * 
     * @param observation la lista de Métricas a ser guardadas
     * @return la lista de Métricas guardadas
     */
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public List<Observation> save(List<Observation> observation) {
        List<Observation> savedMetrics = new ArrayList<>();
        for (Observation metric : observation) {
            try {
                Observation savedMetric = observationService.save(metric);
                savedMetrics.add(savedMetric);
            } catch (Exception e) {
                LOGGER.severe("Error saving metric with ID: " + metric.getId() + ": " + e.getMessage());
            }
        }
        return savedMetrics;
    }

    /**
     * Encuentra una Métrica por su ID.
     * 
     * @param id el ID de la Métrica
     * @return la entidad Métrica encontrada
     */
    public Observation findByMetricId(Long id) {
        return observationService.findById(id);
    }

    /**
     * Carga las medidas del CSV a las métricas
     * 
     * @param file
     * @return Los errores al procesar la carga
     */
    public List<String> loadMetricFileCSV(InputStream uploadedInputStream) {
        List<String> errors = new ArrayList<>();
        List<Observation> observation = new ArrayList<>();

        try (Reader reader = new InputStreamReader(uploadedInputStream);
                CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT.withFirstRecordAsHeader())) {
            LOGGER.info("CSV parser created");

            for (CSVRecord csvRecord : csvParser) {
                LOGGER.info("Processing record: " + csvRecord.toString());

                Observation metric = new Observation();
                try {
                    metric.setDate(LocalDate.parse(csvRecord.get("Fecha"), DATE_FORMATTER));
                    // metric.setTime(LocalTime.parse(csvRecord.get("Time/No."), TIME_FORMATTER));
                   // metric.setValue(Float.parseFloat(csvRecord.get("Value").replace(",", ".")));
                    metric.setGeoLocation(new GeoLocation(
                            Float.parseFloat(csvRecord.get("Latitud_y").replace(",", ".")),
                            Float.parseFloat(csvRecord.get("Longitud_x").replace(",", "."))));
                    metric.setSensorExternalId(csvRecord.get("Sensor_externalId"));
                    metric = generateRange(metric);
                    observation.add(metric);
                } catch (DateTimeParseException e) {
                    String errorMessage = "Error parsing date or time: " + e.getMessage() + " in record: "
                            + csvRecord.toString();
                    LOGGER.severe(errorMessage);
                    errors.add(errorMessage);
                } catch (Exception e) {
                    String errorMessage = "Error parsing CSV record: " + e.getMessage() + " in record: "
                            + csvRecord.toString();
                    LOGGER.severe(errorMessage);
                    errors.add(errorMessage);
                }
            }
        } catch (IOException e) {
            String errorMessage = "Error reading CSV file: " + e.getMessage();
            LOGGER.severe(errorMessage);
            errors.add(errorMessage);
        }

        if (errors.isEmpty() && !observation.isEmpty()) {
            try {
                save(observation);
                LOGGER.info("CSV file processed and observation saved");
            } catch (Exception e) {
                String errorMessage = "Error saving observation: " + e.getMessage();
                LOGGER.severe(errorMessage);
                errors.add(errorMessage);
            }
        } else if (!observation.isEmpty()) {
            LOGGER.warning("CSV file processed with errors. Observations were not saved.");
        }

        return errors;
    }

    /**
     * Genera el rango de la métrica basado en los valores de rango establecidos.
     * 
     * @param metric la Métrica para la cual se debe generar el rango
     * @return la Métrica con el rango asignado
     */
    public Observation generateRange(Observation metric) {
        List<OptimalRange> ranges = rangeService.findAll();
        // LocalTime hora = metric.getTime();
        Sensor sensor = findByExternalId(metric.getSensorExternalId());
        LandUse landUse = sensor.getLandUse();

        if (landUse == null) {
            LOGGER.warning("LandUse is null for sensor with external ID: " + metric.getSensorExternalId());
            return metric;
        }

        /**
         * TimeFrame timeFrame = findTimeFrameForHour(hora, ranges);
         * if (timeFrame == null) {
         * LOGGER.warning("No TimeFrame found for time: " + hora);
         * return metric;
         * }
         * 
         * OptimalRange range = rangeService.findByLandUseAndTimeFrame(landUse.getId(),
         * timeFrame.getId());
         * if (range != null) {
         * BigDecimal metricValue = BigDecimal.valueOf(metric.getValue());
         * BigDecimal rangeValue = range.getValue();
         * if (metricValue.compareTo(rangeValue) > 0) {
         * metric.setRange("ALTO");
         * } else {
         * metric.setRange("BAJO");
         * }
         * } else {
         * LOGGER.warning(
         * "No Range found for LandUse ID: " + landUse.getId() + " and TimeFrame ID: " +
         * timeFrame.getId());
         * return metric;
         * }
         */
        return metric;
    }

    /**
     * Busca el TimeFrame adecuado basado en la hora proporcionada y los rangos
     * disponibles.
     * Recorre la lista de rangos y compara si la hora está dentro de alguno de los
     * TimeFrames.
     * 
     * @param hour   la hora a verificar
     * @param ranges la lista de rangos disponibles
     * @return el TimeFrame correspondiente o null si no se encuentra
     */

    private TimeFrame findTimeFrameForHour(LocalTime hour, List<OptimalRange> ranges) {
        for (OptimalRange range : ranges) {
            LocalTime startTime = range.getTimeFrame().getStartTime();
            LocalTime endTime = range.getTimeFrame().getEndTime();
            if (isTimeInRange(hour, startTime, endTime)) {
                return range.getTimeFrame();
            }
        }
        return null;
    }

    /**
     * Verifica si una hora específica está dentro de un rango de tiempo.
     * Maneja el caso en el que el rango de tiempo puede cruzar la medianoche.
     * 
     * @param time  la hora a verificar
     * @param start el inicio del rango de tiempo
     * @param end   el final del rango de tiempo
     * @return true si la hora está dentro del rango, false en caso contrario
     */
    private boolean isTimeInRange(LocalTime time, LocalTime start, LocalTime end) {
        if (end.isBefore(start)) {
            return time.isAfter(start) || time.isBefore(end);
        } else {
            return time.isAfter(start) && time.isBefore(end);
        }
    }

    /**
     * Busca un rango basado en el LandUse y el TimeFrame especificados.
     * 
     * @param landUseId   el ID del LandUse
     * @param timeFrameId el ID del TimeFrame
     * @return el Range correspondiente
     */
    public OptimalRange findByLandUseAndTimeFrame(Long landUseId, Long timeFrameId) {
        return rangeService.findByLandUseAndTimeFrame(landUseId, timeFrameId);
    }

    public List<Observation> findLastMetricOfActiveSensors() {
        return observationService.findLastMetricOfActiveSensors();
    }

    /**
     * Encuentra métricas de un sensor dentro de un rango de fechas con un intervalo
     * de minutos configurable.
     *
     * @param sensorExternalId el ID externo del sensor
     * @param startDate        la fecha de inicio del rango
     * @param endDate          la fecha de fin del rango
     * @param intervalMinutes  el intervalo en minutos (por ejemplo: 10, 20, 30,
     *                         etc.)
     * @return una lista de métricas que cumplen con los criterios
     */
    public List<Observation> findMetricsBySensorAndDateRangeWithInterval(
            @NotNull String sensorExternalId,
            @NotNull LocalDate startDate,
            @NotNull LocalDate endDate,
            @NotNull Integer intervalMinutes) {

        LOGGER.log(Level.INFO, "Finding observation for sensor: {0}, from {1} to {2} with interval of {3} minutes",
                new Object[] { sensorExternalId, startDate, endDate, intervalMinutes });

        return observationService.findMetricsBySensorAndDateRangeWithInterval(sensorExternalId, startDate, endDate,
                intervalMinutes);
    }

    public List<Observation> findMetricsByDayOrNight() {
        LocalDate today = LocalDate.now();
        return observationService.findMaxMetricsByDayAndNight(today);
    }
    // UnitType

    // Método para guardar un UnitType
    public UnitType saveUnitType(UnitType unitType) {
        LOGGER.log(Level.INFO, "Saving UnitType entity: {0}", unitType);
        return unitTypeService.save(unitType);
    }

    // Método para buscar UnitType por nombre y abreviatura
    public UnitType findUnitTypeByNameAndAbbreviation(String name, String abbreviation) {
        LOGGER.log(Level.INFO, "Searching UnitType by name: {0} and abbreviation: {1}",
                new Object[] { name, abbreviation });
        return unitTypeService.findByNameAndAbbreviation(name, abbreviation);
    }

    // QualitativeScaleService

    @Inject
    QualitativeScaleService qualitativeScaleService;

    public QualitativeScale saveQualitativeScale(QualitativeScale qualitativeScale) {
        return qualitativeScaleService.save(qualitativeScale);
    }

}