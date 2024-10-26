package unl.feirnnr.cc.decibelio.sensor.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;

import java.io.Serializable;
import java.util.Objects;

@Entity

public class TerritorialReference implements Serializable {

    @Id
    @GeneratedValue
    private Long id;

    @Column
    private String country;

    @Column
    private String city;

    @Column
    private String parish; //parroquia

    @Column
    private String locality; // barrio

    @Column
    private String street;  // calles

    public void setId(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getParish() {
        return parish;
    }

    public void setParish(String parish) {
        this.parish = parish;
    }

    public String getLocality() {
        return locality;
    }

    public void setLocality(String locality) {
        this.locality = locality;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TerritorialReference that = (TerritorialReference) o;
        return Objects.equals(id, that.id) && Objects.equals(country, that.country) && Objects.equals(city, that.city) && Objects.equals(parish, that.parish) && Objects.equals(locality, that.locality) && Objects.equals(street, that.street);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, country, city, parish, locality, street);
    }

    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer("TerritorialReference{");
        sb.append("id=").append(id);
        sb.append(", country='").append(country).append('\'');
        sb.append(", city='").append(city).append('\'');
        sb.append(", parish='").append(parish).append('\'');
        sb.append(", locality='").append(locality).append('\'');
        sb.append(", street='").append(street).append('\'');
        sb.append('}');
        return sb.toString();
    }
}
