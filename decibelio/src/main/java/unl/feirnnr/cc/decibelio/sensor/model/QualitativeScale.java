package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;

import java.io.Serializable;
import java.util.Objects;

/**
 * @author wduck
 *         Clase que representa el Uso de Suelo para establecer los rangos
 *         permitidos
 *         de acuerdo a las leyes de la República del Ecuador
 *
 */
@Entity
@TableGenerator(name = "QualitativeScaleGenerator", table = "IdentityGenerator", pkColumnName = "name", valueColumnName = "value", pkColumnValue = "QualitativeScale", initialValue = 1, allocationSize = 1)
public class QualitativeScale implements Serializable {
    @Id
    @GeneratedValue(generator = "QualitativeScaleGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @Column(unique = true)
    @NotEmpty
    private String name;

    @Column
    private String description;


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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof QualitativeScale qualitativeScale))
            return false;
        return Objects.equals(id, qualitativeScale.id) && Objects.equals(name, qualitativeScale.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name);
    }

    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer("QualitativeScale{");
        sb.append("id=").append(id);
        sb.append(", name='").append(name).append('\'');
        sb.append(", description='").append(description).append('\'');
        sb.append('}');
        return sb.toString();
    }
}
