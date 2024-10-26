package unl.feirnnr.cc.decibelio.sensor.boundary;

import java.net.URI;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.eclipse.microprofile.faulttolerance.Retry;
import org.eclipse.microprofile.faulttolerance.Timeout;
import org.eclipse.microprofile.metrics.annotation.Counted;
import org.eclipse.microprofile.metrics.annotation.Timed;
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
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PATCH;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.HttpHeaders;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.UriInfo;
import unl.feirnnr.cc.decibelio.common.rest.RestResult;
import unl.feirnnr.cc.decibelio.common.rest.RestResultStatus;
import unl.feirnnr.cc.decibelio.common.rest.exception.RuntimeExceptionMapper;
import unl.feirnnr.cc.decibelio.sensor.business.DecibelioFacade;
import unl.feirnnr.cc.decibelio.sensor.model.GeoLocation;
import unl.feirnnr.cc.decibelio.sensor.model.LandUse;
import unl.feirnnr.cc.decibelio.sensor.model.Sensor;
import unl.feirnnr.cc.decibelio.sensor.model.SensorStatus;
import unl.feirnnr.cc.decibelio.sensor.model.SensorType;
import unl.feirnnr.cc.decibelio.sensor.model.TerritorialReference;

@Path("sensors")
@APIResponses(value = {
        @APIResponse(responseCode = "400", description = "Invalid input"),
        @APIResponse(responseCode = "404", description = "Error: Not found"),
})
@Counted(name = "sensorEndpointCount", description = "Count of calls to the sensor endpoint")
@Timed(name = "sensorEndpointTime", description = "Time taken to execute the sensor endpoint")
@Timeout(3000) // Timeout after 3 seconds
@Retry(maxRetries = 3) // Retry the request up to 3 times on failure
@RegisterProvider(RuntimeExceptionMapper.class)
public class SensorsResource {

    static final Logger LOGGER = Logger.getLogger(SensorsResource.class.getSimpleName());

    @Inject
    DecibelioFacade decibelioFacade;

    @Context
    HttpHeaders headers;

    @Path("{id}")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation"),
    })
    public SensorResource find(@PathParam("id") Long id) {
        return new SensorResource(id, decibelioFacade);
    }
        
    @POST
    @Path("/create")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Create a sensor")
    @APIResponses(value = {
            @APIResponse(responseCode = "201", description = "Successful operation"),
    })
    @RequestBody(
        description = "JSON object containing the sensor details",
        required = true,
        content = @Content(
                schema = @Schema(
                        type = SchemaType.OBJECT,
                        properties = {
                                @SchemaProperty(name = "name", type = SchemaType.STRING, description = "Name of the sensor"),
                                @SchemaProperty(name = "sensorStatus", type = SchemaType.STRING, description = "Status of the sensor"),
                                @SchemaProperty(name = "sensorType", type = SchemaType.STRING, description = "Type of the sensor"),
                                @SchemaProperty(name = "latitude", type = SchemaType.NUMBER, format = "double", description = "Latitude of the sensor location"),
                                @SchemaProperty(name = "longitude", type = SchemaType.NUMBER, format = "double", description = "Longitude of the sensor location"),
                                @SchemaProperty(name = "externalID", type = SchemaType.STRING, description = "External ID of the sensor"),
                                @SchemaProperty(name = "landUseID", type = SchemaType.INTEGER, format = "int64", description = "ID of the land use")
                        }
                )
        )
    )
    //@Fallback(fallbackMethod = "fallbackMethodCreated")
    public Response create(JsonObject json, @Context UriInfo uriInfo){
        Sensor sensor = new Sensor();
        sensor.setName(json.getString("name"));
    sensor.setSensorStatus(SensorStatus.valueOf(json.getString("sensorStatus")));
    sensor.setSensorType(SensorType.valueOf(json.getString("sensorType")));

    GeoLocation geoLocation = new GeoLocation();
    geoLocation.setLatitude(((float)json.getJsonNumber("latitude").doubleValue()));
    geoLocation.setLongitude(((float)json.getJsonNumber("longitude").doubleValue()));
    sensor.setGeoLocation(geoLocation);

    sensor.setExternalId(json.getString("externalId"));

    //LandUse landUse = decibelioFacade.findByLandUseId((json.getJsonNumber("landUseID").longValue()));
    Long landUseId = json.getJsonNumber("landUseID").longValue();
    LandUse landUse = decibelioFacade.findByLandUseId(landUseId);
    if (landUse == null) {
        return Response.status(Response.Status.BAD_REQUEST)
                .entity(new RestResult(RestResultStatus.FAILURE, "Invalid land use ID", "LandUse", null))
                .build();
    }
    sensor.setLandUse(landUse);

    // Persistir el sensor
    Sensor saved = decibelioFacade.save(sensor);
    LOGGER.log(Level.INFO, "Method POST, Sensor created: {0}", saved);
    Long id = saved.getId();
    URI uri = uriInfo.getAbsolutePathBuilder().path("/" + id).build();
    RestResult result = new RestResult(RestResultStatus.SUCCESS, "Entity created", Sensor.class.getSimpleName(), saved);
    return Response.created(uri).entity(result).build();
    }

    @PATCH
    @Path("/status/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Deactivate or activate a sensor")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation")
    })
    public Response deactivateSensor(@PathParam("id") Long id) {
        Sensor sensor = decibelioFacade.findBySensorId(id);
        String message;
        if (sensor != null) {
            if (sensor.getSensorStatus() == SensorStatus.ACTIVE) {
                sensor.setSensorStatus(SensorStatus.DESACTIVE);
                message = "Sensor is deactivated";
            } else{
                sensor.setSensorStatus(SensorStatus.ACTIVE);
                message = "Sensor is active";
            }
            decibelioFacade.save(sensor);
            Sensor saved = decibelioFacade.findBySensorId(id);
            LOGGER.log(Level.INFO, "....IN. SensorResource SAVING WITH PUT by {0}", saved.getId());
            RestResult result = new RestResult(RestResultStatus.SUCCESS, message, Sensor.class.getSimpleName(), saved.getId());
            return Response.ok().entity(result).build();
        } else {
            return Response.status(Response.Status.NOT_FOUND).entity("Sensor not found").build();
        }
    }

    @PATCH
    @Path("/territorialreference/{id}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Add territorial reference")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation")
    })
    @RequestBody(
        description = "JSON object containing the sensor details",
        required = true,
        content = @Content(
                schema = @Schema(
                        type = SchemaType.OBJECT,
                        properties = {
                                @SchemaProperty(name = "country", type = SchemaType.STRING),
                                @SchemaProperty(name = "city", type = SchemaType.STRING),
                                @SchemaProperty(name = "parish", type = SchemaType.STRING),
                                @SchemaProperty(name = "locality", type = SchemaType.STRING),
                                @SchemaProperty(name = "street", type = SchemaType.STRING),
                        }
                )
        )
    )
    public Response addTerritorialReference(@PathParam("id") Long id, @Valid TerritorialReference territorialReference) {
        Sensor sensor = decibelioFacade.findBySensorId(id);
        String message;
        RestResultStatus resStatus;
        if (sensor != null) {

            if (sensor.getTerritorialReference() != null) {
                message = "The sensor already has an associated territorial reference";
                resStatus = RestResultStatus.FAILURE;
            } else{
                sensor.setTerritorialReference(territorialReference);
                message = "Territorial Reference was successfully added ";
                resStatus = RestResultStatus.SUCCESS;
            }

            decibelioFacade.save(sensor);
            Sensor saved = decibelioFacade.findBySensorId(id);
            LOGGER.log(Level.INFO, "....IN. SensorResource SAVING WITH PUT by {0}", saved.getId());
            RestResult result = new RestResult(resStatus, message, Sensor.class.getSimpleName(), saved.getId());
            return Response.ok().entity(result).build();
        } else {
            return Response.status(Response.Status.NOT_FOUND).entity("Sensor not found").build();
        }
    }

    @GET
    @Path("/active")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get all sensors with ACTIVE status")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation")
    })
    public Response getAllSensorsActive() {
        List<Sensor> sensors = decibelioFacade.findAllSensorsActive();
        JsonArrayBuilder arrayBuilder = Json.createArrayBuilder();

        for (Sensor sensor : sensors) {
            JsonObject sensorJson = Json.createObjectBuilder()
                    .add("id", sensor.getId())
                    .add("name", sensor.getName())
                    .add("externalID", sensor.getExternalId())
                    .add("latitude", ((float)sensor.getGeoLocation().getLatitude()))
                    .add("longitude", ((float)sensor.getGeoLocation().getLongitude()))
                    .add("sensorType", sensor.getSensorType().name())
                    .add("landUseName", sensor.getLandUse().getName())
                    .build();
            arrayBuilder.add(sensorJson);
        }

        JsonArray sensorArray = arrayBuilder.build();
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "List of active Sensors", Sensor.class.getSimpleName(), sensorArray);
        //return Response.ok(sensorArray).build();
        return Response.ok().entity(result).build();
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get all sensors")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation")
    })
    public Response getAllSensors() {
        List<Sensor> sensors = decibelioFacade.findAllSensors();
        JsonArrayBuilder arrayBuilder = Json.createArrayBuilder();

        for (Sensor sensor : sensors) {
            
            JsonObject sensorJson = Json.createObjectBuilder()
                    .add("id", sensor.getId())
                    .add("name", sensor.getName())
                    .add("externalID", sensor.getExternalId())
                    .add("latitude", ((float)sensor.getGeoLocation().getLatitude()))
                    .add("longitude", ((float)sensor.getGeoLocation().getLongitude()))
                    .add("sensorType", sensor.getSensorType().name())
                    .add("sensorStatus", sensor.getSensorStatus().toString())
                    .add("landUseName", sensor.getLandUse().getName())
                    .build();
            arrayBuilder.add(sensorJson);
        }

        JsonArray sensorArray = arrayBuilder.build();
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "List of all Sensors", Sensor.class.getSimpleName(), sensorArray);
        //return Response.ok(sensorArray).build();
        return Response.ok().entity(result).build();
    }

    @GET
    @Path("/landuse")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get all landuse")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation")
    })
    public Response getAllLandUse() {
        List<LandUse> landUses = decibelioFacade.findAllLandUse();
        JsonArrayBuilder arrayBuilder = Json.createArrayBuilder();

        for (LandUse landUse : landUses) {
            JsonObject sensorJson = Json.createObjectBuilder()
                    .add("id", landUse.getId())
                    .add("name", landUse.getName())
                    .build();
            arrayBuilder.add(sensorJson);
        }

        JsonArray landUseArray = arrayBuilder.build();
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "List of all landuse", LandUse.class.getSimpleName(), landUseArray);
        //return Response.ok(sensorArray).build();
        return Response.ok().entity(result).build();
    }
}
