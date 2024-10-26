package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.json.bind.annotation.JsonbDateFormat;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.time.LocalTime;
import java.util.Objects;

/**
 * @author wduck
 * Clase que representa el Periodo de Tiempo
 * Por ejemplo:
 * Diurna
 * Nocturna
 *
 */

@Entity
@TableGenerator(
        name = "TimeFrameGenerator",
        table = "IdentityGenerator",
        pkColumnName = "name",
        valueColumnName = "value",
        pkColumnValue = "TimeFrame",
        initialValue = 1, allocationSize = 1
)
public class TimeFrame implements Serializable {

    @Id
    @GeneratedValue(generator = "TimeFrameGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @Column(unique = true)
    @NotEmpty
    private String name;

    @Column
    //@Temporal(TemporalType.TIME)
    @NotNull
    @JsonbDateFormat(value = "HH:mm:ss")
    private LocalTime startTime;

    @Column
    //@Temporal(TemporalType.TIME)
    @NotNull
    @JsonbDateFormat(value = "HH:mm:ss")
    private LocalTime endTime;

    public void setId(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public @NotEmpty String getName() {
        return name;
    }

    public void setName(@NotEmpty String name) {
        this.name = name;
    }

    public @NotNull LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(@NotNull LocalTime startTime) {
        this.startTime = startTime;
    }

    public @NotNull LocalTime getEndTime() {
        return endTime;
    }

    public void setEndTime(@NotNull LocalTime endTime) {
        this.endTime = endTime;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TimeFrame timeFrame = (TimeFrame) o;
        return Objects.equals(id, timeFrame.id) && Objects.equals(name, timeFrame.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name);
    }

    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer("TimeFrame{");
        sb.append("id=").append(id);
        sb.append(", name='").append(name).append('\'');
        sb.append(", startTime=").append(startTime);
        sb.append(", endTime=").append(endTime);
        sb.append('}');
        return sb.toString();
    }
}
