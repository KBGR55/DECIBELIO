package unl.feirnnr.cc.decibelio.sensor.data;

import java.util.List;
import java.util.stream.Collectors;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.Sensor;

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

    public List<String> getAllExternalIds() {
        List<?> results = em.createNativeQuery("SELECT externalid FROM sensor")
                .getResultList();

        return results.stream()
                .map(Object::toString)
                .collect(Collectors.toList());
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

}
