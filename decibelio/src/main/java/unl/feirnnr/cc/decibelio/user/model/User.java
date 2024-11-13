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
    private String email;

    @Column(nullable = false)
    private Boolean status = true;

    public User(){

    }

    public User(@NotBlank String firstName, @NotBlank String lastName, @Email @NotBlank String email) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
    }

    public User(Long id, @NotBlank String firstName, @NotBlank String lastName, @Email @NotBlank String email,
            Boolean status) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.status = status;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Boolean getsStatus() {
        return status;
    }

    public void setStatus(Boolean status) {
        this.status = status;
    }
 
}
