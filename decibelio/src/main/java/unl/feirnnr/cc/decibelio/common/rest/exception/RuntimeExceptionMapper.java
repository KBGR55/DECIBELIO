package unl.feirnnr.cc.decibelio.common.rest.exception;

import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.OptimisticLockException;
import jakarta.persistence.PersistenceException;
import jakarta.persistence.RollbackException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import unl.feirnnr.cc.decibelio.common.rest.RestResult;
import unl.feirnnr.cc.decibelio.common.rest.RestResultStatus;

import java.time.format.DateTimeParseException;
import java.util.logging.Level;
import java.util.logging.Logger;


/**
 *
 * @author wduck
 */
@Provider
public class RuntimeExceptionMapper implements ExceptionMapper<RuntimeException> {

    private static final Logger LOGGER = Logger.getLogger(RuntimeExceptionMapper.class.getName());

    @Override
    public Response toResponse(RuntimeException exception) {
        Throwable cause = exception.getCause();
        LOGGER.log(Level.OFF, "================================");
        LOGGER.log(Level.OFF,"CAUSE: " + cause);
        LOGGER.log(Level.OFF,"================================");        
        Throwable origin = exception;
        if (cause != null) {
            origin = findOriginThrowable(cause);
        }
        LOGGER.log(Level.OFF, "Origin Throwable CLASS IN RuntimeExceptionMapper:\n {0}", origin.getClass().getSimpleName());
        LOGGER.log(Level.SEVERE, null, origin);
        if (origin instanceof OptimisticLockException) {
            return buildExceptionResponse(Status.CONFLICT, origin);
        }
        if (origin instanceof EntityNotFoundException) {
            return buildExceptionResponse(Status.BAD_REQUEST, origin);
        }
        if (origin instanceof PersistenceException) {
            return buildExceptionResponse(Status.CONFLICT, origin);
        }
        if (origin instanceof RollbackException) {
            return buildExceptionResponse(Status.CONFLICT, origin);
        }
        if (origin instanceof IllegalArgumentException) {
            return buildExceptionResponse(Status.BAD_REQUEST, origin);
        }
        if (origin instanceof IllegalStateException) {
            return buildExceptionResponse(Status.BAD_REQUEST, origin);
        }
        if (origin instanceof NullPointerException) {
            //LOGGER.log(Level.SEVERE, null, origin);
            return buildExceptionResponse(Status.BAD_REQUEST, origin);
        }
        if (origin instanceof DateTimeParseException) {
            return buildExceptionResponse(Status.BAD_REQUEST, "Any parameters date does not format or value not valid: ", origin);
        }

//        if (origin instanceof ValidationException){
//            return buildExceptionResponse(Status.PRECONDITION_FAILED, origin);
//        }        
        return buildExceptionResponse(Status.INTERNAL_SERVER_ERROR, origin);

    }

    private Response buildExceptionResponse(Status status, Throwable origin) {
        RestResult result = new RestResult(
                RestResultStatus.FAILURE, origin.getLocalizedMessage(), origin.getClass().getSimpleName(), null);
        return Response.status(status).entity(result).build();
    }

    private Response buildExceptionResponse(Status status, String message, Throwable origin) {
        RestResult result = new RestResult(
                RestResultStatus.FAILURE, message + origin.getLocalizedMessage(), origin.getClass().getSimpleName(), null);
        return Response.status(status).entity(result).build();
    }

    private Throwable findOriginThrowable(Throwable cause) {
        Throwable origin = cause;
        Throwable current = cause;
        while (origin != null) {
            current = origin;
//            LOGGER.log(Level.OFF,"================================");
//            LOGGER.log(Level.OFF,"AVANZANDO DESDE EL PADRE ORIGIN: " + origin);
//            LOGGER.log(Level.OFF,"AVANZANDO DESDE EL PADRE message: " + origin.getMessage());
//            LOGGER.log(Level.OFF,"================================");            
            origin = origin.getCause();
        }
        return current;
    }
}

