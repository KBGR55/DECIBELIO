package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.Objects;

@Entity
@Table(name="observation")
@Inheritance(strategy = InheritanceType.JOINED)

//  ─── Aquí añadimos la columna de discriminator ───
@DiscriminatorColumn(
    name="DTYPE",
    discriminatorType=DiscriminatorType.STRING,
    columnDefinition="VARCHAR(31) DEFAULT 'Observation'"
)
@DiscriminatorValue("Observation")
@TableGenerator(
    name = "ObservationGenerator",
    table = "IdentityGenerator",
    pkColumnName = "name",
    valueColumnName = "value",
    pkColumnValue = "Observation",
    initialValue = 1,
    allocationSize = 1
)
public class Observation implements Serializable {

    @Id
    @GeneratedValue(generator = "ObservationGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @NotNull
    @Column
    private LocalDate date;

    @Column
    @NotNull
    private String sensorExternalId;

    @ManyToOne
    @JoinColumn(name = "time_frame_id")
    private TimeFrame timeFrame;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "latitude", column = @Column(name = "geo_latitude")),
            @AttributeOverride(name = "longitude", column = @Column(name = "geo_longitude"))
    })

    @NotNull
    private GeoLocation geoLocation;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "value", column = @Column(name = "quantity_value")),
            @AttributeOverride(name = "abbreviation", column = @Column(name = "quantity_abbreviation")),
            @AttributeOverride(name = "time", column = @Column(name = "quantity_time"))
    })
    private Quantity quantity;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "id", column = @Column(name = "qualitative_scale_value_id")),
            @AttributeOverride(name = "name", column = @Column(name = "qualitative_scale_value_name"))
    })
    private QualitativeScaleValue qualitativeScaleValue;

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

    public GeoLocation getGeoLocation() {
        return geoLocation;
    }

    public void setGeoLocation(GeoLocation geoLocation) {
        this.geoLocation = geoLocation;
    }

    public void setQuantity(Quantity quantity) {
        this.quantity = quantity;
    }

    public Quantity getQuantity() {
        return quantity;
    }

    public String getSensorExternalId() {
        return sensorExternalId;
    }

    public void setSensorExternalId(String sensorExternalId) {
        this.sensorExternalId = sensorExternalId;
    }

    public TimeFrame getTimeFrame() {
        return timeFrame;
    }

    public void setTimeFrame(TimeFrame timeFrame) {
        this.timeFrame = timeFrame;
    }

    public QualitativeScaleValue getQualitativeScaleValue() {
        return qualitativeScaleValue;
    }

    public void setQualitativeScaleValue(QualitativeScaleValue qualitativeScaleValue) {
        this.qualitativeScaleValue = qualitativeScaleValue;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        Observation that = (Observation) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, date, sensorExternalId, timeFrame, geoLocation, quantity, qualitativeScaleValue);
    }

    @Override
    public String toString() {
        return "Observation{" +
                "id=" + id +
                ", date=" + date +
                ", sensorExternalId='" + sensorExternalId + '\'' +
                ", timeFrame=" + timeFrame +
                ", geoLocation=" + geoLocation +
                ", quantity=" + quantity +
                ", qualitativeScaleValue=" + qualitativeScaleValue +
                '}';
    }

}
