package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.time.LocalTime;
import java.util.Objects;

@Embeddable
public class Quantity implements Serializable {

    @NotNull
    @Column
    private float value;

    @NotNull
    @Column
    private String abbreviation;

    @NotNull
    @Column
    private LocalTime time;

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

    public String getAbbreviation() {
        return abbreviation;
    }

    public void setAbbreviation(@NotNull String abbreviation) {
        this.abbreviation = abbreviation;
    }


    @Override
    public int hashCode() {
        return Objects.hash(time, value,abbreviation);
    }

    @Override
    public String toString() {
        return "Quantity{" +
                ", value=" + value +
                ", abbreviation='" + abbreviation + '\'' +
                ", time=" + time +
                '}';
    }
}
