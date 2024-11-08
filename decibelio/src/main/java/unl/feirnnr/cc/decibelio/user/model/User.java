package unl.feirnnr.cc.decibelio.user.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.TableGenerator;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Entity
@TableGenerator(name = "UserGenerator", table = "IdentityGenerator", pkColumnName = "name", valueColumnName = "value", pkColumnValue = "User", initialValue = 1, allocationSize = 1)
public class User {
    @Id
    @GeneratedValue(generator = "UserGenerator", strategy = GenerationType.TABLE)
    private Long id;
    
    @NotBlank
    private String firstName;

    @NotBlank
    private String lastName;

    @Email
    @NotBlank
    private String correo;

    @Column(nullable = false)
    private Boolean estado = true;

    public User(){

    }

    public User(@NotBlank String firstName, @NotBlank String lastName, @Email @NotBlank String correo) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.correo = correo;
    }

    public User(Long id, @NotBlank String firstName, @NotBlank String lastName, @Email @NotBlank String correo,
            Boolean estado) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.correo = correo;
        this.estado = estado;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public Boolean getEstado() {
        return estado;
    }

    public void setEstado(Boolean estado) {
        this.estado = estado;
    }
 
}
