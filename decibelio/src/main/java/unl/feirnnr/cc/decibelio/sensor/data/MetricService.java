package unl.feirnnr.cc.decibelio.sensor.data;

import java.util.List;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.Metric;

@Stateless
public class MetricService {
    
    @Inject
    CrudService crudService;

    /**
     * Guarda una entidad Metric. Si la entidad no tiene un ID, se creará.
     * De lo contrario, se actualizará la entidad existente.
     * 
     * @param metric la entidad Metric a ser guardada
     * @return la entidad Metric guardada
     */
    public Metric save(@NotNull Metric metric) {
        return metric.getId() == null ? crudService.create(metric) : crudService.update(metric);
    }

    /**
     * Busca una entidad Metric por su ID.
     * 
     * @param id el ID de la entidad Metric a ser encontrada
     * @return la entidad Metric encontrada
     * @throws EntityNotFoundException si no se encuentra ninguna entidad Metric con el ID dado
     */
    public Metric findById(@NotNull Long id) {
        Metric entity = crudService.find(Metric.class, id);
        if (entity != null) {
            return entity;
        }
        throw new EntityNotFoundException("Metric not found [" + id + "]");
    }

    /**
     * Recupera todas las entidades Metric de la base de datos.
     * 
     * @return una lista de todas las entidades Metric
     */
    public List<Metric> findAll() {
        return crudService.findWithNativeQuery("select * from metric", Metric.class);
    }
}
