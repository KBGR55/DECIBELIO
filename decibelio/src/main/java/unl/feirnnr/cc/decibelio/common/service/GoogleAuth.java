package unl.feirnnr.cc.decibelio.common.service;

import jakarta.annotation.PostConstruct;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import unl.feirnnr.cc.decibelio.common.rest.RestResult;
import unl.feirnnr.cc.decibelio.common.rest.RestResultStatus;

import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import unl.feirnnr.cc.decibelio.common.security.JwtService;
import unl.feirnnr.cc.decibelio.user.data.UserService;
import unl.feirnnr.cc.decibelio.user.data.UserRolService;
import unl.feirnnr.cc.decibelio.user.model.User;

@Path("/auth")
@APIResponses(value = {
                @APIResponse(responseCode = "400", description = "Invalid input"),
                @APIResponse(responseCode = "404", description = "Not Found"),
})
public class GoogleAuth {
        private static final HttpClient CLIENT = HttpClient.newHttpClient();

        private String clientId;
        private String clientSecret;
        private String redirectUri;

        @PostConstruct
        private void init() {
                clientId = System.getenv("GOOGLE_CLIENT_ID");
                clientSecret = System.getenv("GOOGLE_CLIENT_SECRET");
                redirectUri = System.getenv("GOOGLE_REDIRECT_URI");

                if (clientId == null || clientId.isBlank()
                                || clientSecret == null || clientSecret.isBlank()
                                || redirectUri == null || redirectUri.isBlank()) {
                        throw new IllegalStateException(
                                        "Faltan variables de entorno: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET o GOOGLE_REDIRECT_URI");
                }
        }

        @Inject
        private UserRolService userRolService;

        @Inject
        private UserService userService;

        @Inject
        private JwtService jwtService;

        @GET
        @Path("/google/login")
        public Response googleLogin() {
                if (clientId == null || clientId.isBlank() || redirectUri == null || redirectUri.isBlank()) {
                        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                                        .entity("CLIENT_ID o REDIRECT_URI no definidos")
                                        .build();
                }
                String authorizationUrl = String.format(
                                "https://accounts.google.com/o/oauth2/v2/auth"
                                                + "?client_id=%s"
                                                + "&redirect_uri=%s"
                                                + "&response_type=code"
                                                + "&scope=openid%%20email%%20profile",
                                clientId, redirectUri);
                return Response.seeOther(URI.create(authorizationUrl)).build();
        }

        @GET
        @Path("/google/callback")
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Google authentication callback")
        @APIResponses(value = {
                        @APIResponse(responseCode = "200", description = "User authenticated successfully"),
                        @APIResponse(responseCode = "500", description = "Internal server error"),
        })
        public Response googleCallback(@QueryParam("code") String code) {
                try {
                        // 1. Intercambiar el code por accessToken
                        String accessToken = requestAccessToken(code);

                        // 2. Llamar a People API para obtener datos de perfil
                        JsonObject userInfo = fetchUserInfo(accessToken);
                        String firstName = userInfo.get("names").getAsJsonArray()
                                        .get(0).getAsJsonObject()
                                        .get("givenName").getAsString();
                        String lastName = userInfo.get("names").getAsJsonArray()
                                        .get(0).getAsJsonObject()
                                        .get("familyName").getAsString();
                        String email = userInfo.get("emailAddresses").getAsJsonArray()
                                        .get(0).getAsJsonObject()
                                        .get("value").getAsString();
                        // Si tomas también la foto:
                        String photoUrl = null;
                        try {
                                photoUrl = userInfo.get("photos").getAsJsonArray()
                                                .get(0).getAsJsonObject()
                                                .get("url").getAsString();
                        } catch (Exception ex) {
                                // puede que no exista foto, entonces dejamos photoUrl = null
                        }

                        // 3. Crear o recuperar el usuario en BD y asignar rol
                        User user = userRolService.createUserWithDefaultRole(firstName, lastName, email);
                        user.setPhoto(photoUrl); // si tu entidad User tiene setPhoto(String)
                        userService.save(user); // actualiza en BD la foto si la tienes

                        // 4. Recuperar roles del usuario
                        List<String> rolesList = userRolService.findByUser(user).stream()
                                        .map(ur -> ur.getRol().getType())
                                        .toList();

                        // 5. Construir claims y generar JWT
                        Map<String, Object> claims = new HashMap<>();
                        claims.put("userId", user.getId());
                        claims.put("email", user.getEmail());
                        claims.put("roles", rolesList);
                        String jwt = jwtService.generateToken(user.getId().toString(), claims);

                        // 6. Construir JSON de respuesta
                        Map<String, Object> userMap = new HashMap<>();
                        userMap.put("id", user.getId());
                        userMap.put("firstName", user.getFirstName());
                        userMap.put("lastName", user.getLastName());
                        userMap.put("email", user.getEmail());
                        userMap.put("roles", rolesList);
                        userMap.put("status", user.getStatus());
                        userMap.put("photo", photoUrl);

                        Map<String, Object> payload = new HashMap<>();
                        payload.put("user", userMap);
                        payload.put("token", jwt);

                        Map<String, Object> response = new HashMap<>();
                        response.put("status", "SUCCESS");
                        response.put("message", "User authenticated and token generated successfully");
                        response.put("type", "Authentication");
                        response.put("payload", payload);

                        return Response.ok(response).build();

                } catch (Exception e) {
                        e.printStackTrace();
                        Map<String, Object> error = new HashMap<>();
                        error.put("status", "FAILURE");
                        error.put("message", "Error during authentication: " + e.getMessage());
                        error.put("type", "Authentication");
                        return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(error).build();
                }
        }

        // Solicita a Google el access_token a partir del "code"
        private String requestAccessToken(String code) throws IOException, InterruptedException {
                String body = String.format(
                                "code=%s&client_id=%s&client_secret=%s&redirect_uri=%s&grant_type=authorization_code",
                                code, clientId, clientSecret, redirectUri);

                HttpRequest request = HttpRequest.newBuilder()
                                .uri(URI.create("https://oauth2.googleapis.com/token"))
                                .header("Content-Type", "application/x-www-form-urlencoded")
                                .POST(HttpRequest.BodyPublishers.ofString(body))
                                .build();

                HttpResponse<String> response = CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
                return JsonParser.parseString(response.body())
                                .getAsJsonObject()
                                .get("access_token")
                                .getAsString();
        }

        // ------------------------------------------------------------
        // Recupera el perfil del usuario desde People API
        private JsonObject fetchUserInfo(String accessToken) throws IOException, InterruptedException {
                String url = "https://people.googleapis.com/v1/people/me"
                                + "?personFields=names,emailAddresses,photos"
                                + "&access_token=" + accessToken;

                HttpRequest request = HttpRequest.newBuilder()
                                .uri(URI.create(url))
                                .GET()
                                .build();

                HttpResponse<String> response = CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
                return JsonParser.parseString(response.body()).getAsJsonObject();
        }

        @GET
        @Path("/google/logout")
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Logout user")
        public Response googleLogout() {
                RestResult result = new RestResult(
                                RestResultStatus.SUCCESS,
                                "User logged out successfully",
                                "Authentication",
                                null);
                return Response.ok(result).build();
        }
}
