package unl.feirnnr.cc.decibelio.common.service;

import jakarta.ejb.Stateless;
import jakarta.persistence.*;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaDelete;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.CriteriaUpdate;
import jakarta.validation.constraints.NotNull;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Logger;

/**
 * Basado en el servicio descrito por Adam Bien
 * http://www.adam-bien.com/roller/abien/entry/generic_crud_service_aka_dao
 * @author wduck (wilman at loxageek dot com)
 */

@Stateless
public class CrudService {

    static final Logger LOGGER = Logger.getLogger(CrudService.class.getSimpleName());
    public static final String PERSISTENCE_FETCHGRAPH = "javax.persistence.fetchgraph";
    public static final String PERSISTENCE_LOADGRAPH = "javax.persistence.loadgraph";

    @PersistenceContext//(name = "decibelioPU")
    EntityManager em;

    public <T> T create(T t) {
        //LOGGER.log(Level.INFO, "sing in create: {0}", t);
        this.em.persist(t);
        this.em.flush();
        this.em.refresh(t);
        return t;
    }

    public <T> T update(T t) {
        //LOGGER.log(Level.INFO, "sing in update: {0}", t);
        T updated = this.em.merge(t);
        this.em.flush();
        return updated;
    }

    public <T> T find(Class<T> type, Object id) {
        return (T) this.em.find(type, id);
    }

    /**
     * find T wiht relashionShip Lazy
     *
     * @param <T>
     * @param type
     * @param id
     * @param nameNodeGraphMaps
     * @param typeGraph is javax.persistence.loadgraph for relashionShip
     * ManyToOne or javax.persistence.fetchgraph for relashionShip OneToMany
     * @return
     */
    public <T> T findWithEntityGraph(Class<T> type, Object id, String nameNodeGraphMaps, String typeGraph) {
        EntityGraph graph = this.em.getEntityGraph(nameNodeGraphMaps);
        Map hints = new HashMap();
        hints.put(typeGraph, graph);
        return (T) this.em.find(type, id, hints);
    }

    /**
     * find List T wiht relashionShip Lazy
     *
     * @param <T>
     * @param namedQueryName
     * @param parameters
     * @param nameNodeGraphMaps
     * @param typeGraph
     * @return
     */
    @SuppressWarnings("unchecked")
    public <T> List<T> findWithEntityGraph(String namedQueryName, Map<String, Object> parameters, String nameNodeGraphMaps, String typeGraph) {
        EntityGraph graph = this.em.getEntityGraph(nameNodeGraphMaps);
        Query query = this.em.createNamedQuery(namedQueryName);
        query.setHint(typeGraph, graph);
        if (!parameters.isEmpty()) {
            setParameters(query, parameters, 0, 0);
        }
        return query.getResultList();
    }

    public <T> List<T> findWithEntityGraph(String namedQueryName, Map<String, Object> parameters,
                                           int pageSize, String nameNodeGraphMaps, String typeGraph) {
        EntityGraph graph = this.em.getEntityGraph(nameNodeGraphMaps);
        Query query = this.em.createNamedQuery(namedQueryName);
        query.setHint(typeGraph, graph);
        setParameters(query, parameters, 0, pageSize);
        return query.getResultList();
    }

    public <T> List<T> findWithEntityGraph(String namedQueryName, Map<String, Object> parameters,
                                           int page, int pageSize, String nameNodeGraphMaps, String typeGraph) {
        EntityGraph graph = this.em.getEntityGraph(nameNodeGraphMaps);
        Query query = this.em.createNamedQuery(namedQueryName);
        query.setHint(typeGraph, graph);
        setParameters(query, parameters, page, pageSize);
        return query.getResultList();
    }

    /**
     * find List T wiht relashionShip Lazy
     *
     * @param <T>
     * @param namedQueryName
     * @param nameNodeGraphMaps
     * @param typeGraph is javax.persistence.loadgraph for relashionShip
     * ManyToOne or javax.persistence.fetchgraph for relashionShip OneToMany
     * @return List T
     */
    @SuppressWarnings("unchecked")
    public <T> List<T> findWithEntityGraph(String namedQueryName ,String nameNodeGraphMaps, String typeGraph) {
        EntityGraph graph = this.em.getEntityGraph(nameNodeGraphMaps);
        Query query = this.em.createNamedQuery(namedQueryName);
        query.setHint(typeGraph, graph);
        return query.getResultList();
    }

    public <T> T findSingleWithEntityGraph(String namedQueryName,
                                           Map<String, Object> parameters, String nameNodeGraphMaps, String typeGraph) {
        List<T> results = findWithEntityGraph(namedQueryName, parameters, 0, nameNodeGraphMaps, typeGraph);
        if (results.isEmpty()) {
            return null;
        } else if (results.size() == 1) {
            return results.get(0);
        }
        throw new NonUniqueResultException();
    }

    public <T> void delete(Class<T> type, Object id) {
        Object ref = this.em.getReference(type, id);
        this.em.remove(ref);
    }

    public <T> List<T> findWithQuery(String queryString) {
        Query query = this.em.createQuery(queryString);
        return query.getResultList();
    }

    @SuppressWarnings("unchecked")
    public <T> List<T> findWithQuery(String queryString, Map<String, Object> parameters) {
        Query query = this.em.createQuery(queryString);
        setParameters(query, parameters, 0, 0);
        return query.getResultList();
    }

    public int updateOrDeleteWithNamedQuery(String namedQueryName, Map<String, Object> parameters) {
        Query query = this.em.createNamedQuery(namedQueryName);
        setParameters(query, parameters, 0, 0);
        return query.executeUpdate();
    }

    public <T> List<T> findWithNamedQuery(String namedQueryName) {
        return this.em.createNamedQuery(namedQueryName).getResultList();
    }

    public <T> List<T> findWithNamedQuery(String namedQueryName, Map<String, Object> parameters) {
        return findWithNamedQuery(namedQueryName, parameters, 0);
    }

    public <T> List<T> findWithNamedQuery(String namedQueryName, int resultLimit) {
        Query query = this.em.createNamedQuery(namedQueryName);
        setParameters(query, new HashMap<String, Object>(), 0, 0);
        return query.getResultList();
    }

    public <T> List<T> findWithNamedQuery(String namedQueryName, int page, int pageSize) {
        Query query = this.em.createNamedQuery(namedQueryName);
        setParameters(query, new HashMap<String, Object>(), page, pageSize);
        return query.getResultList();
    }

    public <T> List<T> findWithNativeQuery(String sql, Class<T> type) {
        return this.em.createNativeQuery(sql, type).getResultList();
    }

    public <T> List<T> findWithNamedQuery(String namedQueryName,
                                          Map<String, Object> parameters,
                                          int resultLimit) {

        Query query = this.em.createNamedQuery(namedQueryName);
        setParameters(query, parameters, 0, resultLimit);

        return query.getResultList();
    }

    public <T> List<T> findWithNamedQuery(String namedQueryName,
                                          Map<String, Object> parameters,
                                          int page, int pageSize) {

        Query query = this.em.createNamedQuery(namedQueryName);
        setParameters(query, parameters, page, pageSize);

        return query.getResultList();
    }

    public <T> T findSingleWithNamedQuery(String namedQueryName,
                                          Map<String, Object> parameters) {
        List<T> results = findWithNamedQuery(namedQueryName, parameters, 0);
        if (results.isEmpty()) {
            return null;
        } else if (results.size() == 1) {
            return results.get(0);
        }
        throw new NonUniqueResultException();
    }

    private void setParameters(Query query, Map<String, Object> parameters, int page, int pageSize) {
        Set<Map.Entry<String, Object>> rawParameters = parameters.entrySet();
        for (Map.Entry<String, Object> entry : rawParameters) {
            query.setParameter(entry.getKey(), entry.getValue());
        }
        query.setFirstResult(page*pageSize);
        if (pageSize > 0) {
            query.setMaxResults(pageSize);
        }
    }

    public CriteriaBuilder getCriteriaBuilder(){
        return em.getCriteriaBuilder();
    }

    public <T extends Object> TypedQuery<T> createQuery(CriteriaQuery<T> criteriaQuery){
        return em.createQuery(criteriaQuery);
    }

    public <T extends Object> Query createQuery(CriteriaDelete<T> criteriaDelete){
        return em.createQuery(criteriaDelete);
    }

    public <T extends Object> Query createQuery(CriteriaUpdate<T> criteriaUpdate){
        return em.createQuery(criteriaUpdate);
    }

    public Query createNativeQuery(String nativeQuery){
        return em.createNativeQuery(nativeQuery);
    }

    public Query createNativeQuery(String nativeQuery, Class resultClass){
        return em.createNativeQuery(nativeQuery, resultClass);
    }

    public Query createNativeQuery(String nativeQuery, String resultSetMapping){
        return em.createNativeQuery(nativeQuery, resultSetMapping);
    }

    public EntityGraph getEntityGraph(String nameNodeGraphMaps){
        return this.em.getEntityGraph(nameNodeGraphMaps);
    }

    public <T> List<EntityGraph<? super T>> getEntityGraph(Class<T> entityClass){
        return this.em.getEntityGraphs(entityClass);
    }

    public int updateWithNamedQuery(String namedQueryName, Map<String, Object> parameters) {
        Query query = this.em.createNamedQuery(namedQueryName);
        setParameters(query, parameters, 0, 10);
        return query.executeUpdate();
    }

    public int updateWithNativeQuery(@NotNull String sql, Map<String, Object> parameters) {
        Query query = this.em.createNativeQuery(sql);
        setParameters(query, parameters, 0, 0);
        return query.executeUpdate();
    }

    public <T> T findSingleResultOrNullWithNamedQuery(String namedQueryName, Map<String, Object> parameters)
            throws NonUniqueResultException {
        Query query = this.em.createNamedQuery(namedQueryName);
        setParameters(query, parameters, 0, 0);
        return (T) getSingleResultOrNull(query);
    }

    public <T> T findSingleResultOrNullWithNativeQuery(String sql, Class type) {
        Query query = this.em.createNativeQuery(sql, type);
        return (T) getSingleResultOrNull(query);
    }

    public Object getSingleResultOrNull(Query query) throws NonUniqueResultException{
        List results = query.getResultList();
        if (results.isEmpty()) return null;
        else if (results.size() == 1) return results.get(0);
        throw new NonUniqueResultException();
    }

    //@Override
    public EntityManager getEntityManager() {
        return em;
    }

}

