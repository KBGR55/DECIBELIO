package unl.feirnnr.cc.decibelio.sensor.data;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.QualitativeScale;

@Stateless
public class QualitativeScaleService {

    @Inject
    CrudService crudService;

    public QualitativeScale save(@NotNull QualitativeScale qualitativeScale) {
        return qualitativeScale.getId() == null ? crudService.create(qualitativeScale) : crudService.update(qualitativeScale);
    }
}
