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
import unl.feirnnr.cc.decibelio.sensor.model.Observation;
import unl.feirnnr.cc.decibelio.sensor.model.Sensor;

import java.io.InputStream;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Path("observation")
@APIResponses(value = {
        @APIResponse(responseCode = "400", description = "Invalid input"),
        @APIResponse(responseCode = "404", description = "Error: Not found"),
})
@RegisterProvider(RuntimeExceptionMapper.class)
public class ObservationsResource {

    static final Logger LOGGER = Logger.getLogger(ObservationsResource.class.getSimpleName());

    @Inject
    DecibelioFacade decibelioFacade;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get all observation")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation"),
            @APIResponse(responseCode = "404", description = "Error: Not found"),
    })
    public Response getAllMetrics() {
        List<Observation> observation = decibelioFacade.findAllMetrics();
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "List consulted successfully",
                Observation.class,
                observation);
        return Response.ok(result).build();
    }

    @GET
    @Path("/last")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get find last observation")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation"),
            @APIResponse(responseCode = "404", description = "Error: Not found"),
    })
    public Response getAllMetricsFind() {
        List<Observation> observation = decibelioFacade.findLastMetricOfActiveSensors();
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "List consulted successfully",
                Observation.class,
                observation);
        return Response.ok(result).build();
    }

    @POST
    @Path("/upload")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Upload a CSV file with observation")
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

    @POST
    @Path("/sensor")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get observation for a sensor within a date range")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation"),
            @APIResponse(responseCode = "400", description = "Invalid input"),
            @APIResponse(responseCode = "404", description = "Observations not found"),
    })
    public Response getMetricsBySensorAndDateRange(JsonObject json, @Context UriInfo uriInfo) {
        try {
            // 1. Extraer parámetros JSON
            String sensorExternalId = json.containsKey("sensorExternalId")
                    ? json.getString("sensorExternalId")
                    : "";
            String startDateStr = json.containsKey("startDate") ? json.getString("startDate") : null;
            String endDateStr = json.containsKey("endDate") ? json.getString("endDate") : null;
            Integer intervalMinutes = json.containsKey("intervalMinutes") ? json.getInt("intervalMinutes") : 30;

            LocalDateTime now = LocalDateTime.now();

            // 2. Parse de startDate
            LocalDateTime start;
            if (startDateStr == null || startDateStr.isEmpty()) {
                // Si no se envía, usamos hoy a las 07:00
                start = now.withHour(7).withMinute(0).withSecond(0).withNano(0);
            } else if (startDateStr.contains("T")) {
                // Viene con componente de tiempo "YYYY-MM-DDTHH:MM:SS"
                start = LocalDateTime.parse(startDateStr);
            } else {
                // Solo fecha "YYYY-MM-DD", se añade hora 07:00
                LocalDate ld = LocalDate.parse(startDateStr);
                start = ld.atTime(7, 0);
            }

            // 3. Parse de endDate
            LocalDateTime end;
            if (endDateStr == null || endDateStr.isEmpty()) {
                // Si no se envía, usamos hora actual
                end = now;
            } else if (endDateStr.contains("T")) {
                end = LocalDateTime.parse(endDateStr);
            } else {
                // Solo fecha "YYYY-MM-DD", se asume hasta las 23:59:59 de ese día
                LocalDate ld = LocalDate.parse(endDateStr);
                end = ld.atTime(23, 59, 59);
            }

            LOGGER.info(String.format(
                    "Fetching observation for sensor: %s from %s to %s with interval of %d minutes",
                    sensorExternalId, start, end, intervalMinutes));

            // 4. Llamar al servicio pasándole solo las fechas (sin horas)
            List<Observation> observations = decibelioFacade
                    .findMetricsBySensorAndDateRangeWithInterval(
                            sensorExternalId,
                            start.toLocalDate(),
                            end.toLocalDate(),
                            intervalMinutes);

            // 5. Si no hay resultados, devolvemos 404
            if (observations.isEmpty()) {
                RestResult result = new RestResult(
                        RestResultStatus.SUCCESS,
                        "No observation found for the specified criteria",
                        Observation.class,
                        observations);
                return Response.status(Response.Status.NOT_FOUND).entity(result).build();
            }

            // 6. Agrupar por sensorExternalId
            Map<String, List<Observation>> groupedMetrics = observations.stream()
                    .collect(Collectors.groupingBy(Observation::getSensorExternalId));

            // 7. Construir payload de respuesta
            List<Map<String, Object>> responsePayload = new ArrayList<>();
            for (Map.Entry<String, List<Observation>> entry : groupedMetrics.entrySet()) {
                String sensorId = entry.getKey();
                List<Observation> sensorMetrics = entry.getValue();

                Observation firstMetric = sensorMetrics.get(0);
                Map<String, Object> geoLocation = new HashMap<>();
                geoLocation.put("latitude", firstMetric.getGeoLocation().getLatitude());
                geoLocation.put("longitude", firstMetric.getGeoLocation().getLongitude());

                Map<String, Object> sensorMap = new HashMap<>();
                sensorMap.put("sensorExternalId", sensorId);
                sensorMap.put("geoLocation", geoLocation);

                List<Map<String, Object>> metricsList = new ArrayList<>();
                for (Observation metric : sensorMetrics) {
                    Map<String, Object> metricData = new HashMap<>();
                    metricData.put("id", metric.getId());
                    metricData.put("date", metric.getDate());
                    // Extraemos hora y valor desde el embebido Quantity:
                    metricData.put("time", metric.getQuantity().getTime());
                    metricData.put("value", metric.getQuantity().getValue());
                    metricsList.add(metricData);
                }
                sensorMap.put("observation", metricsList);
                responsePayload.add(sensorMap);
            }

            RestResult result = new RestResult(
                    RestResultStatus.SUCCESS,
                    "Observations retrieved successfully",
                    Observation.class,
                    responsePayload);
            return Response.ok(result).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching observation", e);
            RestResult result = new RestResult(
                    RestResultStatus.FAILURE,
                    "Error fetching observation",
                    "Observations",
                    null);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(result).build();
        }
    }

    @GET
    @Path("/max")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get observation by day or night")
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Successful operation"),
            @APIResponse(responseCode = "404", description = "Error: Not found")
    })
    public Response getMetricsByDayOrNight() {
        List<Observation> observation = decibelioFacade.findMetricsByDayOrNight();

        Map<String, List<Observation>> groupedMetrics = observation.stream()
                .collect(Collectors.groupingBy(Observation::getSensorExternalId));

        List<Map<String, Object>> responsePayload = new ArrayList<>();
        for (Map.Entry<String, List<Observation>> entry : groupedMetrics.entrySet()) {
            String sensorId = entry.getKey();
            List<Observation> sensorMetrics = entry.getValue();

            Observation firstMetric = sensorMetrics.get(0);
            Map<String, Object> geoLocation = new HashMap<>();
            geoLocation.put("latitude", firstMetric.getGeoLocation().getLatitude());
            geoLocation.put("longitude", firstMetric.getGeoLocation().getLongitude());

            Map<String, Object> sensor = new HashMap<>();
            sensor.put("sensorExternalId", sensorId);
            sensor.put("geoLocation", geoLocation);

            List<Map<String, Object>> metricsList = new ArrayList<>();
            for (Observation metric : sensorMetrics) {
                Map<String, Object> metricData = new HashMap<>();
                metricData.put("date", metric.getDate());
                metricData.put("id", metric.getId());
                metricData.put("max", metric.getQuantity().getValue());
                metricData.put("range", metric.getQualitativeScaleValue());
                metricData.put("time", metric.getQuantity().getTime());
                metricsList.add(metricData);
            }
            sensor.put("observation", metricsList);
            responsePayload.add(sensor);
        }

        RestResult result = new RestResult(
                RestResultStatus.SUCCESS,
                "Observations retrieved successfully",
                Observation.class,
                responsePayload);
        return Response.ok(result).build();
    }

    @GET
    @Path("/export")
    @Produces("text/csv")
    @Operation(summary = "Export observations between dates as CSV")
    public Response exportCsv(
            @QueryParam("sensorExternalId") String sensorExternalId,
            @QueryParam("startDate") String startDateStr,
            @QueryParam("endDate") String endDateStr) {

        // 1. Parsear fechas (igual a como lo haces en getMetricsBySensorAndDateRange)
        LocalDate start = (startDateStr == null || startDateStr.isEmpty())
                ? LocalDate.now().withDayOfMonth(1)
                : LocalDate.parse(startDateStr);
        LocalDate end = (endDateStr == null || endDateStr.isEmpty())
                ? LocalDate.now()
                : LocalDate.parse(endDateStr);

        // 2. Recuperar todas las observaciones (intervalo 1 minuto para que no filtre
        // nada adicional)
        List<Observation> list = decibelioFacade.findMetricsBySensorAndDateRangeWithInterval("", start, end, 1);
        Sensor sensor = decibelioFacade.findByExternalId(list.get(0).getSensorExternalId());

        // 3. Generar el CSV como StreamingOutput
        StreamingOutput stream = output -> {
            PrintWriter writer = new PrintWriter(output);
            // Cabecera
            writer.println("id,date,sensor,sensorType,latitude,longitude,time,value,abbreviation,qualitativeScale");
            // Filas
            for (Observation o : list) {
                StringBuilder row = new StringBuilder()
                        .append(o.getId()).append(',')
                        .append(o.getDate()).append(',')
                        .append(sensor.getName()).append(',')
                        .append(sensor.getSensorType()).append(',')
                        .append(o.getGeoLocation().getLatitude()).append(',')
                        .append(o.getGeoLocation().getLongitude()).append(',')
                        .append(o.getQuantity().getTime()).append(',')
                        .append(o.getQuantity().getValue()).append(',')
                        .append(o.getQuantity().getAbbreviation()).append(',')
                        .append(o.getQualitativeScaleValue() != null
                                ? o.getQualitativeScaleValue().getName()
                                : "");
                writer.println(row.toString());
            }
            writer.flush();
        };

        // 4. Devolver con header para descarga
        return Response.ok(stream)
                .header("Content-Disposition", "attachment; filename=\"observations.csv\"")
                .build();
    }

}
