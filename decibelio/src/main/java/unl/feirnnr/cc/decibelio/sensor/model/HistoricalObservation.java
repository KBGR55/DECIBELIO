package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;

@Entity
@Table(name = "historical_observation")
@DiscriminatorValue("HistoricalObservation")
@PrimaryKeyJoinColumn(name = "id")
public class HistoricalObservation extends Observation {

    @NotNull
    @Column(name = "measurement_type")
    @Enumerated(EnumType.STRING)
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
