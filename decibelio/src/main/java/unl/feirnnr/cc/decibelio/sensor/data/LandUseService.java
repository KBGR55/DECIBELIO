package unl.feirnnr.cc.decibelio.sensor.data;

import java.util.List;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.LandUse;

@Stateless
public class LandUseService {
    @Inject
    CrudService crudService;

    public LandUse save(@NotNull LandUse landuse) {
        return landuse.getId() == null ? crudService.create(landuse) : crudService.update(landuse);
    }

    public LandUse findById(@NotNull Long id) {
        LandUse entity = crudService.find(LandUse.class, id);
        if (entity != null) {
            return entity;
        }
        throw new EntityNotFoundException("LandUse not found [" + id + "]");
    }

    public List<LandUse> findAll() {
        return crudService.findWithNativeQuery("select * from landuse",LandUse.class);
    }
}
