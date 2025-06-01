package unl.feirnnr.cc.decibelio.user.boundary;

import java.net.URI;
import java.util.List;
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
import jakarta.json.JsonArray;
import jakarta.json.JsonArrayBuilder;
import jakarta.json.JsonObject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
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

        @GET
        @Path("/active")
        @Produces(MediaType.APPLICATION_JSON)
        public Response listAllActiveUsers() {
                List<User> activos = userFacade.findAllActiveUsers();
                // Construir JSON de respuesta…
                JsonArrayBuilder arrayBuilder = Json.createArrayBuilder();
                for (User u : activos) {
                        arrayBuilder.add(
                                        Json.createObjectBuilder()
                                                        .add("id", u.getId())
                                                        .add("firstName", u.getFirstName())
                                                        .add("lastName", u.getLastName())
                                                        .add("email", u.getEmail())
                                                        .add("photo", u.getPhoto() == null ? "" : u.getPhoto())
                                                        .add("status", u.getStatus())
                                                        .build());
                }
                JsonArray resultArray = arrayBuilder.build();
                RestResult result = new RestResult(
                                RestResultStatus.SUCCESS,
                                "Lista de usuarios activos",
                                User.class.getSimpleName(),
                                resultArray);
                return Response.ok(result).build();
        }

        @GET
        @Path("/inactive")
        @Produces(MediaType.APPLICATION_JSON)
        public Response listAllInactiveUsers() {
                List<User> inactivos = userFacade.findAllInactiveUsers();
                JsonArrayBuilder arrayBuilder = Json.createArrayBuilder();
                for (User u : inactivos) {
                        arrayBuilder.add(
                                        Json.createObjectBuilder()
                                                        .add("id", u.getId())
                                                        .add("firstName", u.getFirstName())
                                                        .add("lastName", u.getLastName())
                                                        .add("email", u.getEmail())
                                                        .add("photo", u.getPhoto() == null ? "" : u.getPhoto())
                                                        .add("status", u.getStatus())
                                                        .build());
                }
                JsonArray resultArray = arrayBuilder.build();
                RestResult result = new RestResult(
                                RestResultStatus.SUCCESS,
                                "Lista de usuarios inactivos",
                                User.class.getSimpleName(),
                                resultArray);
                return Response.ok(result).build();
        }

        /**
         * PUT /user/deactivate?email={email}
         * Si el usuario existe y su status = true, lo actualiza a false.
         * Devuelve el usuario actualizado o un error 404 si no existe.
         */
        @PUT
        @Path("/deactivate")
        @Produces(MediaType.APPLICATION_JSON)
        public Response deactivateUser(@QueryParam("email") String email) {
                if (email == null || email.isBlank()) {
                        JsonObject errorJson = Json.createObjectBuilder()
                                        .add("status", "FAILURE")
                                        .add("message", "Parametro 'email' es requerido")
                                        .build();
                        return Response.status(Response.Status.BAD_REQUEST).entity(errorJson).build();
                }

                User user = userFacade.findByEmailTrueFalse(email);
                if (user == null) {
                        JsonObject notFoundJson = Json.createObjectBuilder()
                                        .add("status", "FAILURE")
                                        .add("message", "Usuario no encontrado para email: " + email)
                                        .build();
                        return Response.status(Response.Status.NOT_FOUND).entity(notFoundJson).build();
                }

                // Si ya está inactivo (false), devolvemos un mensaje informando que ya está
                // desactivado
                if (!user.getStatus()) {
                        JsonObject alreadyJson = Json.createObjectBuilder()
                                        .add("status", "FAILURE")
                                        .add("message", "Usuario ya está inactivo")
                                        .build();
                        return Response.status(Response.Status.BAD_REQUEST).entity(alreadyJson).build();
                }

                // Cambiamos a false y guardamos
                user.setStatus(false);
                User updated = userFacade.save(user);

                // Construir JSON de usuario:
                JsonObject userJson = Json.createObjectBuilder()
                                .add("id", updated.getId())
                                .add("firstName", updated.getFirstName())
                                .add("lastName", updated.getLastName())
                                .add("email", updated.getEmail())
                                .add("photo", updated.getPhoto() == null ? "" : updated.getPhoto())
                                .add("status", updated.getStatus())
                                .build();

                RestResult result = new RestResult(
                                RestResultStatus.SUCCESS,
                                "Usuario desactivado exitosamente",
                                User.class.getSimpleName(),
                                userJson);
                return Response.ok(result).build();
        }

        /**
         * PUT /user/activate?email={email}
         * Si el usuario existe y su status = false, lo actualiza a true.
         * Devuelve el usuario actualizado o un error 404 si no existe.
         */
        @PUT
        @Path("/activate")
        @Produces(MediaType.APPLICATION_JSON)
        public Response activateUser(@QueryParam("email") String email) {
                if (email == null || email.isBlank()) {
                        JsonObject errorJson = Json.createObjectBuilder()
                                        .add("status", "FAILURE")
                                        .add("message", "Parametro 'email' es requerido")
                                        .build();
                        return Response.status(Response.Status.BAD_REQUEST).entity(errorJson).build();
                }

                User user = userFacade.findByEmailTrueFalse(email);
                if (user == null) {
                        JsonObject notFoundJson = Json.createObjectBuilder()
                                        .add("status", "FAILURE")
                                        .add("message", "Usuario no encontrado para email: " + email)
                                        .build();
                        return Response.status(Response.Status.NOT_FOUND).entity(notFoundJson).build();
                }

                // Si ya está activo (true), devolvemos un mensaje informando que ya está activo
                if (user.getStatus()) {
                        JsonObject alreadyJson = Json.createObjectBuilder()
                                        .add("status", "FAILURE")
                                        .add("message", "Usuario ya está activo")
                                        .build();
                        return Response.status(Response.Status.BAD_REQUEST).entity(alreadyJson).build();
                }

                // Cambiamos a true y guardamos
                user.setStatus(true);
                User updated = userFacade.save(user);

                // Construir JSON de usuario:
                JsonObject userJson = Json.createObjectBuilder()
                                .add("id", updated.getId())
                                .add("firstName", updated.getFirstName())
                                .add("lastName", updated.getLastName())
                                .add("email", updated.getEmail())
                                .add("photo", updated.getPhoto() == null ? "" : updated.getPhoto())
                                .add("status", updated.getStatus())
                                .build();

                RestResult result = new RestResult(
                                RestResultStatus.SUCCESS,
                                "Usuario activado exitosamente",
                                User.class.getSimpleName(),
                                userJson);
                return Response.ok(result).build();
        }

        @PUT
        @Path("/assign/role")
        @Produces(MediaType.APPLICATION_JSON)
        public Response assignRoleToUser(
                @QueryParam("email") String email,
                @QueryParam("roleId") Long roleId) 
        {
            // 1) Validar parámetros
            if (email == null || email.isBlank() || roleId == null) {
                JsonObject errorJson = Json.createObjectBuilder()
                    .add("status", "FAILURE")
                    .add("message", "Parámetros 'email' y 'roleId' son requeridos")
                    .build();
                return Response.status(Response.Status.BAD_REQUEST).entity(errorJson).build();
            }
    
            try {
                // 2) Delegar en facade
                UserRol userRol = userFacade.assignRoleToUser(email, roleId);
    
                // 3) Construir JSON de la relación
                JsonObject userRolJson = Json.createObjectBuilder()
                    .add("id", userRol.getId())
                    .add("userId", userRol.getUser().getId())
                    .add("email", userRol.getUser().getEmail())
                    .add("roleId", userRol.getRol().getId())
                    .add("roleType", userRol.getRol().getType())
                    .add("status", userRol.getStatus())
                    .build();
    
                RestResult result = new RestResult(
                    RestResultStatus.SUCCESS,
                    "Rol asignado correctamente",
                    UserRol.class.getSimpleName(),
                    userRolJson
                );
                return Response.ok(result).build();
    
            } catch (IllegalArgumentException ex) {
                // 4) Si usuario o rol no se encontró, o rol inactivo
                JsonObject errorJson = Json.createObjectBuilder()
                    .add("status", "FAILURE")
                    .add("message", ex.getMessage())
                    .build();
                return Response.status(Response.Status.BAD_REQUEST).entity(errorJson).build();
            } catch (Exception ex) {
                // 5) Cualquier otro error inesperado
                JsonObject errorJson = Json.createObjectBuilder()
                    .add("status", "FAILURE")
                    .add("message", "Error interno al asignar rol: " + ex.getMessage())
                    .build();
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(errorJson).build();
            }
        }
}