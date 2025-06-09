package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;

import java.io.Serializable;
import java.util.Objects;

@Entity
@TableGenerator(name = "QualitativeScaleGenerator", table = "IdentityGenerator", pkColumnName = "name", valueColumnName = "value", pkColumnValue = "QualitativeScale", initialValue = 1, allocationSize = 1)
public class QualitativeScale implements Serializable {
    @Id
    @GeneratedValue(generator = "QualitativeScaleGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @Column(nullable = false, unique = false)
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
        if (this == o) return true;
        if (!(o instanceof QualitativeScale)) return false;
        QualitativeScale that = (QualitativeScale) o;
        return Objects.equals(name, that.name);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(name);
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
