package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.time.LocalTime;
import java.util.Objects;

@Entity
@TableGenerator(
        name = "QuantityGenerator",
        table = "IdentityGenerator",
        pkColumnName = "name",
        valueColumnName = "value",
        pkColumnValue = "Quantity",
        initialValue = 1, allocationSize = 1
)
public class Quantity implements Serializable {

    @Id
    @GeneratedValue(generator = "QuantityGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @NotNull
    @Column
    private float amount;

    @NotNull
    @Column
    private Long unitTypeId;

    @NotNull
    @Column
    private LocalTime time;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
    public @NotNull LocalTime getTime() {
        return time;
    }

    public void setTime(@NotNull LocalTime time) {
        this.time = time;
    }

    @NotNull
    public float getAmount() {
        return amount;
    }

    public void setAmount(@NotNull float amount) {
        this.amount = amount;
    }

    public void setUnitTypeId(Long unitTypeId) {
        this.unitTypeId = unitTypeId;
    }

    public Long getUnitTypeId() {
        return unitTypeId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, time, amount, unitTypeId);
    }


    @Override
    public String toString() {
        return "Quantity{" +
                "id=" + id +
                ", amount=" + amount +
                ", unitTypeId=" + unitTypeId + 
                ", time=" + time +
                '}';
    }
}
