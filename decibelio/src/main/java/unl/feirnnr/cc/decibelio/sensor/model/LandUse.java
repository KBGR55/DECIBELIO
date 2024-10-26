package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;

import java.io.Serializable;
import java.util.LinkedHashSet;
import java.util.Objects;
import java.util.Set;

/**
 * @author wduck
 *         Clase que representa el Uso de Suelo para establecer los rangos
 *         permitidos
 *         de acuerdo a las leyes de la República del Ecuador
 *
 */
@Entity
@TableGenerator(name = "LandUseGenerator", table = "IdentityGenerator", pkColumnName = "name", valueColumnName = "value", pkColumnValue = "LandUse", initialValue = 1, allocationSize = 1)
public class LandUse implements Serializable {
    @Id
    @GeneratedValue(generator = "LandUseGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @Column(unique = true)
    @NotEmpty
    private String name;

    @Column
    private String description;

    @OneToMany(targetEntity = Range.class, orphanRemoval = true, cascade = CascadeType.ALL)
    @JoinColumn(name = "landUse_id")
    private Set<Range> ranges;

    public LandUse() {
        ranges = new LinkedHashSet<>();
    }

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
        if (!(o instanceof LandUse landUse))
            return false;
        return Objects.equals(id, landUse.id) && Objects.equals(name, landUse.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name);
    }

    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer("LandUse{");
        sb.append("id=").append(id);
        sb.append(", name='").append(name).append('\'');
        sb.append(", description='").append(description).append('\'');
        sb.append(", ranges=").append(ranges);
        sb.append('}');
        return sb.toString();
    }
}
