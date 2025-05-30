package unl.feirnnr.cc.decibelio.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;

import jakarta.validation.constraints.NotNull;

public class ObservationDTO implements Serializable {
    
    @NotNull
    private LocalDate date;

    @NotNull
    private String sensorExternalId;

    @NotNull
    private float value;

    @NotNull
    private LocalTime  time;

    public ObservationDTO() {}

    public ObservationDTO(LocalDate date, String sensorExternalId, float value, LocalTime time) {
        this.date = date;
        this.sensorExternalId = sensorExternalId;
        this.value = value;
        this.time = time;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public float getValue() {
        return value;
    }

    public void setValue(float value) {
        this.value = value;
    }

    public LocalTime getTime() {
        return time;
    }

    public void setTime(LocalTime time) {
        this.time = time;
    }

    public String getSensorExternalId() {
        return sensorExternalId;
    }   

    public void setSensorExternalId(String sensorExternalId) {
        this.sensorExternalId = sensorExternalId;
    }
    
}
