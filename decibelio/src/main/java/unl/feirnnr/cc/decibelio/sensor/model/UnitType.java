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
@TableGenerator(name = "UnitTypeGenerator", table = "IdentityGenerator", pkColumnName = "name", valueColumnName = "value", pkColumnValue = "UnitType", initialValue = 1, allocationSize = 1)
public class UnitType implements Serializable {
    @Id
    @GeneratedValue(generator = "UnitTypeGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @Column(unique = true)
    @NotEmpty
    private String name;

    @Column
    private String abbreviation;


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

    public String getabbreviation() {
        return abbreviation;
    }

    public void setabbreviation(String abbreviation) {
        this.abbreviation = abbreviation;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof UnitType unitType))
            return false;
        return Objects.equals(id, unitType.id) && Objects.equals(name, unitType.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name);
    }

    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer("UnitType{");
        sb.append("id=").append(id);
        sb.append(", name='").append(name).append('\'');
        sb.append(", abbreviation='").append(abbreviation).append('\'');
        sb.append('}');
        return sb.toString();
    }
}
