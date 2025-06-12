package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;


public class HistoricalObservation extends Observation {

    @NotNull
    @Column
    private MeasurementType measurementType;

    public void setMeasurementType(MeasurementType measurementType) {
        this.measurementType = measurementType;
    }

    public MeasurementType getMeasurementType() {
        return measurementType;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("HistoricalObservation{");
        sb.append(", measurementType=").append(measurementType);
        sb.append('}');
        return sb.toString();
    }

}
