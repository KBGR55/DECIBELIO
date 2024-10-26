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
import unl.feirnnr.cc.decibelio.sensor.model.Range;

import java.util.List;
import java.util.logging.Logger;

@Path("ranges")
@APIResponses(value = {
        @APIResponse(responseCode = "400", description = "Invalid input"),
        @APIResponse(responseCode = "404", description = "Error: Not found"),
})
@RegisterProvider(RuntimeExceptionMapper.class)
public class RangesResource {

    static final Logger LOGGER = Logger.getLogger(RangesResource.class.getSimpleName());

    @Inject
    DecibelioFacade decibelioFacade;
    
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get all ranges")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation"),
            @APIResponse(responseCode = "404", description = "Error: Not found"),
    })
    public Response getAllRanges() {
        List<Range> ranges = decibelioFacade.findAllRanges();
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "List consulted successfully", Range.class, ranges);
        return Response.ok(result).build();
    }
}
