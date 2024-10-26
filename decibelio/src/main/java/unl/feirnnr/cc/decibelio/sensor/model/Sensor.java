package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.util.Objects;

@Entity
@TableGenerator(
        name = "SensorGenerator",
        table = "IdentityGenerator",
        pkColumnName = "name",
        valueColumnName = "value",
        pkColumnValue = "Sensor",
        initialValue = 1, allocationSize = 1
)
public class Sensor implements Serializable {

    @Id
    @GeneratedValue(generator = "SensorGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @Column(unique = true)
    @NotEmpty
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    @NotNull
    private SensorType sensorType;

    @Column
    @NotNull
    private SensorStatus sensorStatus;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "latitude", column = @Column(name = "geo_latitude")),
            @AttributeOverride(name = "longitude", column = @Column(name = "geo_longitude"))
    })
    //@NotNull
    private GeoLocation geoLocation;

    @Column
    private String externalId;

    @ManyToOne(fetch = FetchType.LAZY)
    private LandUse landUse; // Uso de Suelo

    @ManyToOne(fetch = FetchType.LAZY)
    private TerritorialReference territorialReference;

    public Sensor() {
        sensorStatus = SensorStatus.ACTIVE;
        sensorType = SensorType.SOUND_LEVEL_METER;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public @NotEmpty String getName() {
        return name;
    }

    public void setName(@NotEmpty String name) {
        this.name = name;
    }

    public @NotNull SensorType getSensorType() {
        return sensorType;
    }

    public void setSensorType(@NotNull SensorType sensorType) {
        this.sensorType = sensorType;
    }

    public @NotNull SensorStatus getSensorStatus() {
        return sensorStatus;
    }

    public void setSensorStatus(@NotNull SensorStatus sensorStatus) {
        this.sensorStatus = sensorStatus;
    }

    public GeoLocation getGeoLocation() {
        return geoLocation;
    }

    public void setGeoLocation(GeoLocation geoLocation) {
        this.geoLocation = geoLocation;
    }

    public String getExternalId() {
        return externalId;
    }

    public void setExternalId(String externalId) {
        this.externalId = externalId;
    }

    public LandUse getLandUse() {
        return landUse;
    }

    public void setLandUse(LandUse landUse) {
        this.landUse = landUse;
    }

    public TerritorialReference getTerritorialReference() {
        return territorialReference;
    }

    public void setTerritorialReference(TerritorialReference territorialReference) {
        this.territorialReference = territorialReference;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Sensor sensor = (Sensor) o;
        return Objects.equals(id, sensor.id) && Objects.equals(name, sensor.name)
                && sensorType == sensor.sensorType && sensorStatus == sensor.sensorStatus
                && Objects.equals(geoLocation, sensor.geoLocation)
                && Objects.equals(externalId, sensor.externalId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name, sensorType, sensorStatus, geoLocation, externalId);
    }

    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer("Sensor{");
        sb.append("id=").append(id);
        sb.append(", name='").append(name).append('\'');
        sb.append(", sensorType=").append(sensorType);
        sb.append(", sensorStatus=").append(sensorStatus);
        sb.append(", geoLocation=").append(geoLocation);
        sb.append(", externalId='").append(externalId).append('\'');
        sb.append(", landUse=").append(landUse);
        sb.append(", territorialReference=").append(territorialReference);
        sb.append('}');
        return sb.toString();
    }
}
