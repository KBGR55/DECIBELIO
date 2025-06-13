package unl.feirnnr.cc.decibelio.common.service;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Singleton
@Startup
@TransactionAttribute(TransactionAttributeType.REQUIRED)
public class SchemaInitializer {

    @PersistenceContext(unitName = "decibelioPU")
    private EntityManager em;

    @PostConstruct
    public void fixExistingRows() {
        em.createNativeQuery(
            "UPDATE observation SET DTYPE = 'Observation' WHERE DTYPE IS NULL"
        ).executeUpdate();
    }
}
