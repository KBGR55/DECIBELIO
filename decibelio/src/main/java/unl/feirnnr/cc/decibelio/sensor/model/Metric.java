package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Objects;

@Entity
@TableGenerator(
        name = "MetricGenerator",
        table = "IdentityGenerator",
        pkColumnName = "name",
        valueColumnName = "value",
        pkColumnValue = "Metric",
        initialValue = 1, allocationSize = 1
)
public class Metric implements Serializable {

    @Id
    @GeneratedValue(generator = "MetricGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @NotNull
    @Column
    LocalDate date;

    @NotNull
    @Column
    LocalTime time;

    @NotNull
    @Column
    float value;

    @Column
    String range;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "latitude", column = @Column(name = "geo_latitude")),
            @AttributeOverride(name = "longitude", column = @Column(name = "geo_longitude"))
    })
    //@NotNull
    private GeoLocation geoLocation;

    // OJO DESPUES CON LOS ORIGINALES
    @Column
    private String sensorExternalId;

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

    public @NotNull LocalTime getTime() {
        return time;
    }

    public void setTime(@NotNull LocalTime time) {
        this.time = time;
    }

    @NotNull
    public float getValue() {
        return value;
    }

    public void setValue(@NotNull float value) {
        this.value = value;
    }

    public String getRange() {
        return range;
    }

    public void setRange(String range) {
        this.range = range;
    }

    public GeoLocation getGeoLocation() {
        return geoLocation;
    }

    public void setGeoLocation(GeoLocation geoLocation) {
        this.geoLocation = geoLocation;
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
        Metric metric = (Metric) o;
        return Float.compare(value, metric.value) == 0 && Objects.equals(id, metric.id) && Objects.equals(date, metric.date) && Objects.equals(time, metric.time) && Objects.equals(geoLocation, metric.geoLocation) && Objects.equals(sensorExternalId, metric.sensorExternalId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, date, time, value, geoLocation, sensorExternalId);
    }

    @Override
    public String toString() {
        return "Metric{" +
                "id=" + id +
                ", date=" + date +
                ", time=" + time +
                ", value=" + value +
                ", range='" + range + '\'' +
                ", geoLocation=" + geoLocation +
                ", sensorExternalId='" + sensorExternalId + '\'' +
                '}';
    }
}
