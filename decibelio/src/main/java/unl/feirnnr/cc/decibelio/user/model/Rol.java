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
    private String tipo;

    public Rol(@NotNull String tipo) {
        this.tipo = tipo;
    }

    @Column(nullable = false)
    private Boolean estado = true;

    public Rol(Long id, @NotNull String tipo, Boolean estado) {
        this.id = id;
        this.tipo = tipo;
        this.estado = estado;
    }

    public Rol() {
    }
    
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public Boolean getEstado() {
        return estado;
    }

    public void setEstado(Boolean estado) {
        this.estado = estado;
    }

    

}
