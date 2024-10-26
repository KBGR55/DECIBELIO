package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Objects;

@Entity
@TableGenerator(
        name = "RangeGenerator",
        table = "IdentityGenerator",
        pkColumnName = "name",
        valueColumnName = "value",
        pkColumnValue = "Range",
        initialValue = 1, allocationSize = 1
)
public class Range implements Serializable {

    @Id
    @GeneratedValue(generator = "Range", strategy = GenerationType.TABLE)
    private Long id;

    @Column
    @NotNull
    private BigDecimal value;

    @NotNull
    @ManyToOne(fetch = FetchType.EAGER)
    private TimeFrame timeFrame;

    public void setId(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public @NotNull BigDecimal getValue() {
        return value;
    }

    public void setValue(@NotNull BigDecimal value) {
        this.value = value;
    }

    public @NotNull TimeFrame getTimeFrame() {
        return timeFrame;
    }

    public void setTimeFrame(@NotNull TimeFrame timeFrame) {
        this.timeFrame = timeFrame;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Range range = (Range) o;
        return Objects.equals(id, range.id) && Objects.equals(value, range.value) && Objects.equals(timeFrame, range.timeFrame);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, value, timeFrame);
    }

    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer("Range{");
        sb.append("id=").append(id);
        sb.append(", value=").append(value);
        sb.append(", timeFrame=").append(timeFrame);
        sb.append('}');
        return sb.toString();
    }
}
