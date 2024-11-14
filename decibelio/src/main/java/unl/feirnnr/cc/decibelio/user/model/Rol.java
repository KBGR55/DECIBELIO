package unl.feirnnr.cc.decibelio.user.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.TableGenerator;
import jakarta.validation.constraints.NotNull;

@Entity
@TableGenerator(name = "RolGenerator", table = "IdentityGenerator", pkColumnName = "name", valueColumnName = "value", pkColumnValue = "Rol", initialValue = 1, allocationSize = 1)
public class Rol {
    @Id
    @GeneratedValue(generator = "RolGenerator", strategy = GenerationType.TABLE)
    private Long id;

    @NotNull
    @Column(length = 20, nullable = false)
    private String type;

    public Rol(@NotNull String type) {
        this.type = type;
    }

    @Column(nullable = false)
    private Boolean status = true;

    public Rol(Long id, @NotNull String type, Boolean status) {
        this.id = id;
        this.type = type;
        this.status = status;
    }

    public Rol() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Boolean getStatus() {
        return status;
    }

    public void setStatus(Boolean status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Rol{" +
                "id=" + id +
                ", type='" + type + '\'' +
                ", status=" + status +
                '}';
    }

}
