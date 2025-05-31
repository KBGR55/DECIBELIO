package unl.feirnnr.cc.decibelio.sensor.model;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class QualitativeScaleValue implements Serializable {

    @Column
    @NotNull
    private Long id;

    @Column(unique = true)
    @NotEmpty
    private String name;


    public QualitativeScaleValue() {
       
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

    @Override
    public int hashCode() {
        return Objects.hash(id, name);
    }

    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer("QualitativeScaleValue{");
        sb.append("id=").append(id);
        sb.append(", name='").append(name).append('\'');
        sb.append('}');
        return sb.toString();
    }
}
