package unl.feirnnr.cc.decibelio.common.rest;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@Path("/auth")
@APIResponses(value = {
        @APIResponse(responseCode = "400", description = "Invalid input"),
        @APIResponse(responseCode = "404", description = "Not Found"),
})
public class GoogleAuthResource {

    private static final Logger LOGGER = Logger.getLogger(GoogleAuthResource.class.getName());
    private static final HttpClient CLIENT = HttpClient.newHttpClient();

    @Inject
    @ConfigProperty(name = "CLIENT_ID")
    private String clientId;

    @Inject
    @ConfigProperty(name = "CLIENT_SECRET")
    private String clientSecret;

    @Inject
    @ConfigProperty(name = "REDIRECT_URI")
    private String redirectUri;

    @GET
    @Path("/google/login")
    @Operation(summary = "Initiate Google login")
    public Response googleLogin() {
        String authorizationUrl = String.format(
                "https://accounts.google.com/o/oauth2/auth?client_id=%s&redirect_uri=%s&response_type=code&scope=email%%20profile",
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
            LOGGER.log(Level.INFO, "Received authorization code: {0}", code);
            String accessToken = requestAccessToken(code);
            JsonObject userInfo = fetchUserInfo(accessToken);

            RestResult result = new RestResult(RestResultStatus.SUCCESS, "User authenticated successfully", "Authentication", extractUserInfo(userInfo));
            return Response.ok(result).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error during Google authentication: {0}", e.getMessage());
            RestResult result = new RestResult(RestResultStatus.FAILURE, "Error during authentication", "Authentication", null);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(result).build();
        }
    }

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
        return JsonParser.parseString(response.body()).getAsJsonObject().get("access_token").getAsString();
    }

    private JsonObject fetchUserInfo(String accessToken) throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://people.googleapis.com/v1/people/me?personFields=names,emailAddresses,photos&access_token=" + accessToken))
                .GET()
                .build();

        HttpResponse<String> response = CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
        return JsonParser.parseString(response.body()).getAsJsonObject();
    }

    private Map<String, Object> extractUserInfo(JsonObject userInfo) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("email", userInfo.get("emailAddresses").getAsJsonArray().get(0).getAsJsonObject().get("value").getAsString());
        payload.put("picture", userInfo.get("photos").getAsJsonArray().get(0).getAsJsonObject().get("url").getAsString());
        payload.put("name", userInfo.get("names").getAsJsonArray().get(0).getAsJsonObject().get("displayName").getAsString());
        return payload;
    }

    @GET
    @Path("/google/logout")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Logout user")
    public Response googleLogout() {
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "User logged out successfully", "Authentication", null);
        return Response.ok(result).build();
    }
}
