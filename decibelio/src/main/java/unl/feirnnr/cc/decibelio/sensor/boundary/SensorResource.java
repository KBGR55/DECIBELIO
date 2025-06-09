package unl.feirnnr.cc.decibelio.sensor.boundary;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import unl.feirnnr.cc.decibelio.common.rest.RestResult;
import unl.feirnnr.cc.decibelio.common.rest.RestResultStatus;
import unl.feirnnr.cc.decibelio.sensor.business.DecibelioFacade;
import unl.feirnnr.cc.decibelio.sensor.model.Sensor;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author wduck
 */
@APIResponses(value = {
        @APIResponse(responseCode = "400", description = "Invalid input"),
        @APIResponse(responseCode = "404", description = "Not Found"),
})
public class SensorResource {

    private static final Logger LOGGER = Logger.getLogger(SensorResource.class.getName());

    private final Long id;
    private final DecibelioFacade decibelioFacade;

    public SensorResource(Long id, DecibelioFacade decibelioFacade) {
        this.id = id;
        this.decibelioFacade = decibelioFacade;
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Find a sensor")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation"),
    })
    public Response find() {
            LOGGER.log(Level.INFO, "..... IN SensorResource FIND BY ID... {0}", id);
            Sensor sensor = decibelioFacade.findBySensorId(id);
            RestResult result = new RestResult(RestResultStatus.SUCCESS, "Found entity", Sensor.class.getSimpleName(), sensor);
            return Response.ok().entity(result).build();
    }

    @PUT 
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    @Operation(summary = "Update a sensor")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation"),
    })
    public Response save(@NotNull @Valid Sensor sensor) {
        sensor.setId(id);
        decibelioFacade.save(sensor);
        Sensor saved = decibelioFacade.findBySensorId(id);
        LOGGER.log(Level.INFO, "....IN. SensorResource SAVING WITH PUT by {0}", saved.getId());
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "Entity updated", Sensor.class.getSimpleName(), saved);
        return Response.ok().entity(result).build();
    }
}
