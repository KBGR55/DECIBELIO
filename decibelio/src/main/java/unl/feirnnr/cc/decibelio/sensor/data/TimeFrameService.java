package unl.feirnnr.cc.decibelio.sensor.data;

import java.time.LocalTime;

import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.Query;
import jakarta.validation.constraints.NotNull;
import unl.feirnnr.cc.decibelio.common.service.CrudService;
import unl.feirnnr.cc.decibelio.sensor.model.TimeFrame;

public class TimeFrameService {

    @Inject
    private CrudService crudService;

    /**
     * Busca el TimeFrame al que pertenece el LocalTime dado, devolviendo un solo
     * resultado.
     *
     * Lógica:
     * - Si starttime <= endtime (caso diurno):
     * devolvemos el registro cuyo time esté entre starttime y endtime.
     * - Si starttime > endtime (caso nocturno que “va cruzando medianoche”):
     * devolvemos el registro cuyo time sea >= starttime O bien <= endtime.
     *
     * @param time Hora a consultar (p. ej. LocalTime.now()).
     * @return TimeFrame correspondiente.
     * @throws EntityNotFoundException si no existe ningún registro que cumpla la
     *                                 condición.
     */
    public TimeFrame findByTime(@NotNull LocalTime time) {
        String sql = ""
                + "SELECT * "
                + "FROM public.timeframe t "
                + "WHERE "
                + "  ( t.starttime <= t.endtime "
                + "    AND ? BETWEEN t.starttime AND t.endtime ) "
                + "  OR "
                + "  ( t.starttime > t.endtime "
                + "    AND ( ? >= t.starttime OR ? <= t.endtime ) )";

        Query query = crudService.createNativeQuery(sql, TimeFrame.class);
        // Se pasan los mismos parámetros en las tres posiciones
        query.setParameter(1, time);
        query.setParameter(2, time);
        query.setParameter(3, time);

        try {
            // getSingleResult() devuelve el único registro (o lanza excepción si no existe)
            return (TimeFrame) query.getSingleResult();
        } catch (jakarta.persistence.NoResultException e) {
            throw new EntityNotFoundException(
                    "No se encontró ningún TimeFrame para la hora: " + time);
        }
    }

}
