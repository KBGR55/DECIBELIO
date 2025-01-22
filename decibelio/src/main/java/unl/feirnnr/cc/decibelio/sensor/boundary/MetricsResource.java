package unl.feirnnr.cc.decibelio.sensor.boundary;

import jakarta.inject.Inject;
import jakarta.json.JsonObject;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
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
import unl.feirnnr.cc.decibelio.sensor.model.Metric;

import java.io.InputStream;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Path("metrics")
@APIResponses(value = {
                @APIResponse(responseCode = "400", description = "Invalid input"),
                @APIResponse(responseCode = "404", description = "Error: Not found"),
})
@RegisterProvider(RuntimeExceptionMapper.class)
public class MetricsResource {

        static final Logger LOGGER = Logger.getLogger(MetricsResource.class.getSimpleName());

        @Inject
        DecibelioFacade decibelioFacade;

        @GET
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Get all metrics")
        @APIResponses(value = {
                        @APIResponse(responseCode = "200", description = "Successful operation"),
                        @APIResponse(responseCode = "404", description = "Error: Not found"),
        })
        public Response getAllMetrics() {
                List<Metric> metrics = decibelioFacade.findAllMetrics();
                RestResult result = new RestResult(RestResultStatus.SUCCESS, "List consulted successfully",
                                Metric.class,
                                metrics);
                return Response.ok(result).build();
        }

        @GET
        @Path("/last")
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Get find last metrics")
        @APIResponses(value = {
                        @APIResponse(responseCode = "200", description = "Successful operation"),
                        @APIResponse(responseCode = "404", description = "Error: Not found"),
        })
        public Response getAllMetricsFind() {
                List<Metric> metrics = decibelioFacade.findLastMetricOfActiveSensors();
                RestResult result = new RestResult(RestResultStatus.SUCCESS, "List consulted successfully",
                                Metric.class,
                                metrics);
                return Response.ok(result).build();
        }

        @POST
        @Path("/upload")
        @Consumes(MediaType.MULTIPART_FORM_DATA)
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Upload a CSV file with metrics")
        @APIResponses(value = {
                        @APIResponse(responseCode = "200", description = "File uploaded successfully"),
                        @APIResponse(responseCode = "500", description = "Internal server error"),
        })
        public Response uploadCSVFile(@Context HttpServletRequest request) {
                try {
                        Part filePart = request.getPart("file");
                        if (filePart == null) {
                                LOGGER.severe("No file part found in the request");
                                RestResult result = new RestResult(RestResultStatus.FAILURE, "File part is missing",
                                                "FileUpload",
                                                null);
                                return Response.status(Response.Status.BAD_REQUEST).entity(result).build();
                        }

                        LOGGER.info("File part received");
                        InputStream uploadedInputStream = filePart.getInputStream();
                        if (uploadedInputStream == null) {
                                LOGGER.severe("Input stream is null");
                                RestResult result = new RestResult(RestResultStatus.FAILURE,
                                                "Error retrieving input stream",
                                                "FileUpload", null);
                                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(result).build();
                        }

                        LOGGER.info("Input stream successfully obtained");
                        List<String> errors = decibelioFacade.loadMetricFileCSV(uploadedInputStream);

                        if (errors.isEmpty()) {
                                RestResult result = new RestResult(RestResultStatus.SUCCESS,
                                                "File uploaded and processed successfully",
                                                "FileUpload", errors);
                                return Response.ok(result).build();
                        } else {
                                String errorMessage = String.join("\n", errors);
                                RestResult result = new RestResult(RestResultStatus.FAILURE,
                                                "Errors occurred while processing the file:\n" + errorMessage,
                                                "FileUpload", errors);
                                return Response.status(Response.Status.BAD_REQUEST).entity(result).build();
                        }
                } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "Error processing file", e);
                        RestResult result = new RestResult(RestResultStatus.FAILURE, "Error processing file",
                                        "FileUpload", null);
                        return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(result).build();
                }
        }

        @GET
        @Path("/sensor")
        @Consumes(MediaType.APPLICATION_JSON)
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Get metrics for a sensor within a date range")
        @APIResponses(value = {
                        @APIResponse(responseCode = "200", description = "Successful operation"),
                        @APIResponse(responseCode = "400", description = "Invalid input"),
                        @APIResponse(responseCode = "404", description = "Metrics not found"),
        })
        public Response getMetricsBySensorAndDateRange(JsonObject json, @Context UriInfo uriInfo) {
                try {
                        String sensorExternalId = json.containsKey("sensorExternalId")
                                        ? json.getString("sensorExternalId")
                                        : "";
                        String startDate = json.containsKey("startDate") ? json.getString("startDate") : null;
                        String endDate = json.containsKey("endDate") ? json.getString("endDate") : null;
                        Integer intervalMinutes = json.containsKey("intervalMinutes") ? json.getInt("intervalMinutes")
                                        : 30;

                        LocalDateTime now = LocalDateTime.now();

                        LocalDateTime start = (startDate == null)
                                        ? now.withHour(7).withMinute(0).withSecond(0).withNano(0)
                                        : LocalDateTime.parse(startDate);

                        LocalDateTime end = (endDate == null)
                                        ? now
                                        : LocalDateTime.parse(endDate);

                        LOGGER.info(String.format(
                                        "Fetching metrics for sensor: %s from %s to %s with interval of %d minutes",
                                        sensorExternalId, start, end, intervalMinutes));

                        List<Metric> metrics = decibelioFacade.findMetricsBySensorAndDateRangeWithInterval(
                                        sensorExternalId,
                                        start.toLocalDate(), end.toLocalDate(), intervalMinutes);

                        if (metrics.isEmpty()) {
                                RestResult result = new RestResult(RestResultStatus.SUCCESS,
                                                "No metrics found for the specified criteria", Metric.class, metrics);
                                return Response.status(Response.Status.NOT_FOUND).entity(result).build();
                        }
                        // Agrupar las métricas por sensorExternalId
                        Map<String, List<Metric>> groupedMetrics = metrics.stream()
                                        .collect(Collectors.groupingBy(Metric::getSensorExternalId));

                        // Crear la respuesta
                        List<Map<String, Object>> responsePayload = new ArrayList<>();
                        for (Map.Entry<String, List<Metric>> entry : groupedMetrics.entrySet()) {
                                String sensorId = entry.getKey();
                                List<Metric> sensorMetrics = entry.getValue();

                                // Obtener detalles del sensor (solo una vez)
                                Metric firstMetric = sensorMetrics.get(0);
                                Map<String, Object> geoLocation = new HashMap<>();
                                geoLocation.put("latitude", firstMetric.getGeoLocation().getLatitude());
                                geoLocation.put("longitude", firstMetric.getGeoLocation().getLongitude());

                                // Preparar el objeto para la respuesta
                                Map<String, Object> sensor = new HashMap<>();
                                sensor.put("sensorExternalId", sensorId);
                                sensor.put("geoLocation", geoLocation);

                                // Crear la lista de métricas sin los detalles del sensor
                                List<Map<String, Object>> metricsList = new ArrayList<>();
                                for (Metric metric : sensorMetrics) {
                                        Map<String, Object> metricData = new HashMap<>();
                                        metricData.put("date", metric.getDate());
                                        metricData.put("id", metric.getId());
                                        metricData.put("range", metric.getRange());
                                        metricData.put("time", metric.getTime());
                                        metricData.put("value", metric.getValue());
                                        metricsList.add(metricData);
                                }
                                sensor.put("metrics", metricsList);
                                responsePayload.add(sensor);
                        }

                        RestResult result = new RestResult(RestResultStatus.SUCCESS, "Metrics retrieved successfully",
                                        Metric.class, responsePayload);
                        return Response.ok(result).build();
                } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "Error fetching metrics", e);
                        RestResult result = new RestResult(RestResultStatus.FAILURE, "Error fetching metrics",
                                        "Metrics", null);
                        return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(result).build();
                }
        }

}
