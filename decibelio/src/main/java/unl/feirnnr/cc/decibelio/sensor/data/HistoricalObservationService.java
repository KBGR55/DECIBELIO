package unl.feirnnr.cc.decibelio.sensor.data;

import java.util.List;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.HistoricalObservation;

@Stateless
public class HistoricalObservationService {
   
    @Inject
    CrudService crudService;

    public HistoricalObservation save(HistoricalObservation historicalObservation) {
       return historicalObservation.getId() == null ? crudService.create(historicalObservation) : crudService.update(historicalObservation);
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
    
}
