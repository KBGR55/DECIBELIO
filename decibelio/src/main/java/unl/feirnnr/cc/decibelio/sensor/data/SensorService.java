package unl.feirnnr.cc.decibelio.sensor.data;

import java.util.List;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.Sensor;
import unl.feirnnr.cc.decibelio.sensor.model.UnitType;

@Stateless
public class SensorService {

    @Inject
    CrudService crudService;

    public Sensor save(@NotNull Sensor sensor) {
        return sensor.getId() == null ? crudService.create(sensor) : crudService.update(sensor);
    }

    public Sensor findById(@NotNull Long id) {
        Sensor entity = crudService.find(Sensor.class, id);
        if (entity != null) {
            return entity;
        }
        throw new EntityNotFoundException("Sensor not found [" + id + "]");
    }

    public List<Sensor> findAll() {
        return crudService.findWithNativeQuery("select * from sensor", Sensor.class);
    }

    public List<Sensor> findAllActive() {
        return crudService.findWithNativeQuery("select * from sensor where sensorstatus = 0", Sensor.class);
    }

    @PersistenceContext
    private EntityManager em;

    @SuppressWarnings("unchecked") // Opción alternativa, no recomendada si no hay conversión explícita
    public List<String> getAllExternalIds() {
        return em.createNativeQuery("SELECT externalid FROM sensor WHERE externalid IS NOT NULL")
                .getResultList()
                .stream()
                .map(Object::toString)
                .toList(); // Requiere Java 16+. Si usas Java 8–15, usa .collect(Collectors.toList())
    }

    @SuppressWarnings("unchecked")
    public List<String> getAllExternalIdsActive() {
        return em.createNativeQuery("SELECT externalid FROM sensor WHERE sensorstatus = 0")
                .getResultList()
                .stream()
                .map(Object::toString)
                .toList(); // Requiere Java 16+. Si usas Java 8–15, usa .collect(Collectors.toList())
    }

    /**
     * Busqua el sensor por externalId.
     *
     * @param externalId El externalId del sensor que se va a encontrar.
     * @return El sensor encontrado.
     */
    public Sensor findByExternalId(@NotNull String externalId) {
        String sql = "SELECT * FROM Sensor WHERE externalid = ?";
        Query query = crudService.createNativeQuery(sql, Sensor.class);
        query.setParameter(1, externalId); // Los parámetros en consultas nativas son posicionales
        @SuppressWarnings("unchecked")
        List<Sensor> sensors = query.getResultList();
        if (!sensors.isEmpty()) {
            return sensors.get(0);
        }
        return null;
    }

    /**
     * A partir de un externalId de sensor, obtiene la abreviatura del UnitType asociado.
     *
     * @param externalId Identificador externo del sensor.
     * @return String con la abreviatura (p.ej. "dB", "m", etc.), o null si el Sensor existe pero no tiene UnitType.
     * @throws EntityNotFoundException si no se encuentra ningún Sensor con ese externalId.
     */
    public String findUnitTypeAbbreviationByExternalId(@NotNull String externalId) {
        // 1. Primero buscamos el Sensor
        Sensor sensor = findByExternalId(externalId);

        // 2. Obtenemos el UnitType asociado (puede ser null si no se asignó ninguno)
        UnitType unidad = sensor.getUnitType();
        if (unidad != null) {
            return unidad.getAbbreviation();
        }

        // Si el sensor existe pero no tiene UnitType:
        return null;
    }

}
