package unl.feirnnr.cc.decibelio.user.boundary;

import java.util.List;

import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

import jakarta.inject.Inject;
import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonArrayBuilder;
import jakarta.json.JsonObject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import unl.feirnnr.cc.decibelio.common.rest.RestResult;
import unl.feirnnr.cc.decibelio.common.rest.RestResultStatus;
import unl.feirnnr.cc.decibelio.user.business.UserFacade;
import unl.feirnnr.cc.decibelio.user.model.Rol;

@Path("/rol")
@APIResponses(value = {
        @APIResponse(responseCode = "400", description = "Invalid input"),
        @APIResponse(responseCode = "404", description = "Error: Not found"),
})
public class RolResource {
    @Inject
    private UserFacade userFacade;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get all rol")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation")
    })
    public Response getAllRoles() {
        List<Rol> roles= userFacade.findAllRoles();
         JsonArrayBuilder arrayBuilder = Json.createArrayBuilder();

        for (Rol rol: roles) {
            JsonObject rolJson = Json.createObjectBuilder()
                    .add("id", rol.getId())
                    .add("type", rol.getType())
                    .add("status", rol.getStatus())
                    .build();
            arrayBuilder.add(rolJson);
        }
        JsonArray rolArray = arrayBuilder.build();
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "List of all rol", Rol.class.getSimpleName(), rolArray);
        return Response.ok().entity(result).build();
    }

    @GET
    @Path("/active")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get all rol with TRUE status")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation")
    })
    public Response getActiveRoles() {
        List<Rol> roles= userFacade.findAllActiveRoles();
        JsonArrayBuilder arrayBuilder = Json.createArrayBuilder();

       for (Rol rol: roles) {
           JsonObject rolJson = Json.createObjectBuilder()
                   .add("id", rol.getId())
                   .add("type", rol.getType())
                   .add("status", rol.getStatus())
                   .build();
           arrayBuilder.add(rolJson);
       }
       JsonArray rolArray = arrayBuilder.build();
       RestResult result = new RestResult(RestResultStatus.SUCCESS, "List of all rol active", Rol.class.getSimpleName(), rolArray);
       return Response.ok().entity(result).build();
    }
}
