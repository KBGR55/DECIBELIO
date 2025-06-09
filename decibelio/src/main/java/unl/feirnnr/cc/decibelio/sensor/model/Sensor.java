package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.util.LinkedHashSet;
import java.util.Objects;
import java.util.Set;

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
    private String referenceLocation;

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

    @ManyToOne
    @JoinColumn(name = "unit_type_id")
    private UnitType unitType;

    @OneToMany(targetEntity = QualitativeScale.class, orphanRemoval = true, cascade = CascadeType.ALL)
    @JoinColumn(name = "qualitativeScale_id")
    private Set<QualitativeScale> qualitativeScale;

    public Sensor() {
        sensorStatus = SensorStatus.ACTIVE;
        sensorType = SensorType.SOUND_LEVEL_METER;
        qualitativeScale = new LinkedHashSet<>();
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

    public String getReferenceLocation() {
        return referenceLocation;
    }

    public void setReferenceLocation(String referenceLocation) {
        this.referenceLocation = referenceLocation;
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

    public void setUnitType(UnitType unitType) {
        this.unitType = unitType;
    }

    public UnitType getUnitType() {
        return unitType;
    }
    public Set<QualitativeScale> getQualitativeScale() {
        return qualitativeScale;
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
        return Objects.hash(id, name, sensorType, sensorStatus, geoLocation, referenceLocation,externalId);
    }

    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer("Sensor{");
        sb.append("id=").append(id);
        sb.append(", name='").append(name).append('\'');
        sb.append(", sensorType=").append(sensorType);
        sb.append(", sensorStatus=").append(sensorStatus);
        sb.append(", geoLocation=").append(geoLocation);
        sb.append(", referenceLocation='").append(referenceLocation).append('\'');
        sb.append(", externalId='").append(externalId).append('\'');
        sb.append(", landUse=").append(landUse);
        sb.append(", territorialReference=").append(territorialReference);
        sb.append(", qualitativeScale=").append(qualitativeScale);
        sb.append('}');
        return sb.toString();
    }
}
