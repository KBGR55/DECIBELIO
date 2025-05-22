package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Objects;

@Entity
@TableGenerator(
        name = "ObservationGenerator",
        table = "IdentityGenerator",
        pkColumnName = "name",
        valueColumnName = "value",
        pkColumnValue = "Observation",
        initialValue = 1, allocationSize = 1
)
public class Observation implements Serializable {

    @Id
    @GeneratedValue(generator = "ObservationGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @NotNull
    @Column
    private LocalDate date;

    @NotNull
    @Column
    private float value;

    @Column
    private String sensorExternalId;

    @Column
    private Long timeFrameId;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "latitude", column = @Column(name = "geo_latitude")),
            @AttributeOverride(name = "longitude", column = @Column(name = "geo_longitude"))
    })
    
    @NotNull
    private GeoLocation geoLocation;

    @ManyToOne
    @JoinColumn(name = "qualitative_scale_value_id")
    @NotNull   
    private QualitativeScaleValue qualitativeScaleValue;

    @ManyToOne
    @JoinColumn(name = "quantity_id")
    private Quantity quantity;


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public @NotNull LocalDate getDate() {
        return date;
    }

    public void setDate(@NotNull LocalDate date) {
        this.date = date;
    }

    @NotNull
    public float getValue() {
        return value;
    }

    public void setValue(@NotNull float value) {
        this.value = value;
    }

    public Long gettimeFrameId() {
        return timeFrameId;
    }

    public void settimeFrameId(Long timeFrameId) {
        this.timeFrameId = timeFrameId;
    }

    public GeoLocation getGeoLocation() {
        return geoLocation;
    }

    public void setGeoLocation(GeoLocation geoLocation) {
        this.geoLocation = geoLocation;
    }

    public void setQualitativeScaleValue(QualitativeScaleValue qualitativeScaleValue) {
        this.qualitativeScaleValue = qualitativeScaleValue;
    }

    public QualitativeScaleValue getQualitativeScaleValue() {
        return qualitativeScaleValue;
    }

    public void setQuantity(Quantity quantity) {
        this.quantity = quantity;
    }

    public Quantity getQuantity() {
        return quantity;
    }

    public Long getTimeFrameId() {
        return timeFrameId;
    }

    public String getSensorExternalId() {
        return sensorExternalId;
    }

    public void setSensorExternalId(String sensorExternalId) {
        this.sensorExternalId = sensorExternalId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Observation observation = (Observation) o;
        return Float.compare(value, observation.value) == 0 && Objects.equals(id, observation.id) && Objects.equals(date, observation.date) && Objects.equals(timeFrameId, observation.timeFrameId) && Objects.equals(qualitativeScaleValue, observation.qualitativeScaleValue) && Objects.equals(quantity, observation.quantity) && Objects.equals(geoLocation, observation.geoLocation) && Objects.equals(sensorExternalId, observation.sensorExternalId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, date, qualitativeScaleValue, quantity, value, geoLocation, sensorExternalId);
    }

    @Override
    public String toString() {
        return "Observation{" +
                "id=" + id +
                ", date=" + date +
                ", value=" + value +
                ", timeFrameId='" + timeFrameId + '\'' +
                ", geoLocation=" + geoLocation +
                ", sensorExternalId='" + sensorExternalId + '\'' +
                ", qualitativeScaleValue=" + qualitativeScaleValue.toString() +
                ", quantity=" + quantity.toString() +
                '}';
    } 
}
