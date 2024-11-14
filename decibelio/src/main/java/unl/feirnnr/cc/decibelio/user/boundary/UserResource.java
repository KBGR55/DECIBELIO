package unl.feirnnr.cc.decibelio.user.boundary;

import java.net.URI;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.faulttolerance.Retry;
import org.eclipse.microprofile.faulttolerance.Timeout;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.media.SchemaProperty;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;

import jakarta.inject.Inject;
import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.UriInfo;
import unl.feirnnr.cc.decibelio.common.rest.RestResult;
import unl.feirnnr.cc.decibelio.common.rest.RestResultStatus;
import unl.feirnnr.cc.decibelio.common.rest.exception.RuntimeExceptionMapper;
import unl.feirnnr.cc.decibelio.common.service.GoogleAuth;
import unl.feirnnr.cc.decibelio.user.business.UserFacade;
import unl.feirnnr.cc.decibelio.user.model.Rol;
import unl.feirnnr.cc.decibelio.user.model.User;
import unl.feirnnr.cc.decibelio.user.model.UserRol;

@Path("user")
@APIResponses(value = {
                @APIResponse(responseCode = "400", description = "Invalid input"),
                @APIResponse(responseCode = "404", description = "Error: Not found"),
})
@Timeout(3000)
@Retry(maxRetries = 3)
@RegisterProvider(RuntimeExceptionMapper.class)
public class UserResource {

        static final Logger LOGGER = Logger.getLogger(UserResource.class.getSimpleName());

        @Inject
        UserFacade userFacade;

        @Inject
        @ConfigProperty(name = "defaulRol", defaultValue = "VISOR_GENERAL")
        private String defaulRol;

        @Inject
        GoogleAuth googleAuth;
        

        @POST
        @Path("/create")
        @Consumes(MediaType.APPLICATION_JSON)
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Create user with default role")
        @APIResponses(value = {
                        @APIResponse(responseCode = "200", description = "User successfully created with default role"),
                        @APIResponse(responseCode = "400", description = "Invalid input")
        })
        @RequestBody(description = "JSON object containing the sensor details", required = true, content = @Content(schema = @Schema(type = SchemaType.OBJECT, properties = {
                        @SchemaProperty(name = "fristName", type = SchemaType.STRING, description = "Name of the sensor"),
                        @SchemaProperty(name = "lastName", type = SchemaType.STRING, description = "Status of the sensor"),
                        @SchemaProperty(name = "email", type = SchemaType.STRING, description = "Type of the sensor")
        })))
        public Response create(JsonObject userJson, @Context UriInfo uriInfo) {
                User userData = new User(userJson.getString("firstName"), userJson.getString("lastName"),
                                userJson.getString("email"));

                User user = userFacade.save(userData);
                Rol rol = userFacade.findByRol(defaulRol);
                if (rol == null) {
                        throw new IllegalStateException("El rol por defecto 'VISOR_GENERAL' no se encuentra.");
                }
                UserRol userRol = new UserRol(user, rol);
                UserRol saved = userFacade.save(userRol);
                LOGGER.log(Level.INFO, "Method POST, User created: {0}", saved);
                Long id = saved.getId();
                URI uri = uriInfo.getAbsolutePathBuilder().path("/" + id).build();
                RestResult result = new RestResult(RestResultStatus.SUCCESS, "Entity created",
                                User.class.getSimpleName(), saved);
                return Response.created(uri).entity(result).build();

        }
}
