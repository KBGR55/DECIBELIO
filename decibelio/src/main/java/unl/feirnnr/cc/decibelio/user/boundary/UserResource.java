package unl.feirnnr.cc.decibelio.user.boundary;

import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

import jakarta.inject.Inject;
import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import unl.feirnnr.cc.decibelio.common.rest.RestResult;
import unl.feirnnr.cc.decibelio.common.rest.RestResultStatus;
import unl.feirnnr.cc.decibelio.user.business.UserFacade;
import unl.feirnnr.cc.decibelio.user.model.User;

@Path("/user")
@APIResponses(value = {
        @APIResponse(responseCode = "400", description = "Invalid input"),
        @APIResponse(responseCode = "404", description = "Error: Not found"),
})
public class UserResource {

    @Inject 
    UserFacade userFacade;
    
    @POST
    @Path("/create/visor_general")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Create user with default role")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "User successfully created with default role"),
            @APIResponse(responseCode = "400", description = "Invalid input")
    })
    public Response createUserWithDefaultRole(JsonObject userJson) {
        String firstName = userJson.getString("firstName");
        String lastName = userJson.getString("lastName");
        String email = userJson.getString("email");
        User user = userFacade.createUserWithDefaultRole(firstName, lastName, email);
        JsonObject userJsonResponse = Json.createObjectBuilder()
                .add("id", user.getId())
                .add("firstName", user.getFirstName())
                .add("lastName", user.getLastName())
                .add("email", user.getEmail())
                .build();

        RestResult result = new RestResult(RestResultStatus.SUCCESS, "User created with default role", User.class.getSimpleName(), userJsonResponse);
        return Response.ok().entity(result).build();
    }
}
