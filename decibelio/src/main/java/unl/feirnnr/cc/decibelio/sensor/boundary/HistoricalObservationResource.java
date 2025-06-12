package unl.feirnnr.cc.decibelio.sensor.boundary;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;

import unl.feirnnr.cc.decibelio.common.rest.RestResult;
import unl.feirnnr.cc.decibelio.common.rest.RestResultStatus;
import unl.feirnnr.cc.decibelio.common.rest.exception.RuntimeExceptionMapper;
import unl.feirnnr.cc.decibelio.sensor.business.DecibelioFacade;
import unl.feirnnr.cc.decibelio.sensor.model.HistoricalObservation;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@Path("historical/observation")
@APIResponses(value = {
        @APIResponse(responseCode = "400", description = "Invalid input"),
        @APIResponse(responseCode = "404", description = "Error: Not found"),
})
@RegisterProvider(RuntimeExceptionMapper.class)
public class HistoricalObservationResource {
   @Inject
    DecibelioFacade decibelioFacade;

    private static final Logger LOGGER = Logger.getLogger(HistoricalObservationResource.class.getName());

    
    @GET
    @Path("/{sensorExternalId}")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Retrieve historical observations for a specific sensor")
    public RestResult getHistoricalObservations(
            @PathParam("sensorExternalId") String sensorExternalId) {
        
        try {
            // Llamar al método para obtener las métricas
            List<HistoricalObservation> historicalObservations = decibelioFacade.findMetricsByDayOrNight(sensorExternalId);      
            // Retornar las observaciones como un resultado exitoso
            return new RestResult(RestResultStatus.SUCCESS, "List consulted successfully",HistoricalObservation.class, historicalObservations);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error while retrieving historical observations", e);
            return new RestResult(RestResultStatus.FAILURE, "Error retrieving historical observations", HistoricalObservation.class,null);
        }
    }

    
}
