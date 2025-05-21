package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.Column;
import jakarta.validation.constraints.NotNull;

public class HistoricalObservation extends Observation {

    @NotNull
    @Column
    private MeasurementType measurementType;

    
}
