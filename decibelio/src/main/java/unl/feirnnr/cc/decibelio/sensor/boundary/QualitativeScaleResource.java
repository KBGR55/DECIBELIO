package unl.feirnnr.cc.decibelio.sensor.boundary;

import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import unl.feirnnr.cc.decibelio.common.rest.RestResult;
import unl.feirnnr.cc.decibelio.common.rest.RestResultStatus;
import unl.feirnnr.cc.decibelio.sensor.business.DecibelioFacade;
import unl.feirnnr.cc.decibelio.sensor.model.QualitativeScale;

@Path("qualitativeScales")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class QualitativeScaleResource {

    @Inject
    DecibelioFacade decibelioFacade;

    @POST
    @Path("/create")
    public Response create(@Valid QualitativeScale qualitativeScale) {
        QualitativeScale saved = decibelioFacade.saveQualitativeScale(qualitativeScale);
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "Qualitative Scale created", QualitativeScale.class.getSimpleName(), saved);
        return Response.status(Response.Status.CREATED).entity(result).build();
    }
}
