package unl.feirnnr.cc.decibelio.sensor.boundary;

import jakarta.inject.Inject;
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
import unl.feirnnr.cc.decibelio.sensor.model.HistoricalObservation;
import unl.feirnnr.cc.decibelio.sensor.model.Sensor;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Path("historical/observation")
@APIResponses(value = {
                @APIResponse(responseCode = "400", description = "Invalid input"),
                @APIResponse(responseCode = "404", description = "Error: Not found"),
})
@RegisterProvider(RuntimeExceptionMapper.class)
public class HistoricalObservationResource {
        @Inject
        DecibelioFacade decibelioFacade;

        private static final Logger LOGGER = Logger.getLogger(HistoricalObservationResource.class.getName());

        @GET
        @Path("/{sensorExternalId}")
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Retrieve historical observations for a specific sensor")
        @APIResponses(value = {
                        @APIResponse(responseCode = "200", description = "Historical observations retrieved successfully"),
                        @APIResponse(responseCode = "500", description = "Internal server error")
        })
        public RestResult getHistoricalObservations(
                        @PathParam("sensorExternalId") String sensorExternalId) {

                try {
                        // Llamar al método para obtener las métricas
                        List<HistoricalObservation> historicalObservations = decibelioFacade
                                        .findMetricsByDayOrNight(sensorExternalId, LocalDate.now());
                        // Retornar las observaciones como un resultado exitoso
                        return new RestResult(RestResultStatus.SUCCESS, "List consulted successfully",
                                        HistoricalObservation.class,
                                        historicalObservations);
                } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "Error while retrieving historical observations", e);
                        return new RestResult(RestResultStatus.FAILURE, "Error retrieving historical observations",
                                        HistoricalObservation.class, null);
                }
        }

        @GET
        @Path("/{sensorExternalId}/range")
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Retrieve historical observations for a sensor in a date range, grouped by timeframe")
        @APIResponses(value = {
                        @APIResponse(responseCode = "200", description = "Historical observations retrieved successfully"),
                        @APIResponse(responseCode = "400", description = "Invalid date format"),
                        @APIResponse(responseCode = "500", description = "Internal server error")
        })
        public Response getBySensorAndDateRange(
                        @PathParam("sensorExternalId") String sensorExternalId,
                        @QueryParam("startDate") String startDateStr,
                        @QueryParam("endDate") String endDateStr) {
                try {
                        LocalDate startDate = LocalDate.parse(startDateStr);
                        LocalDate endDate = LocalDate.parse(endDateStr);

                        List<HistoricalObservation> flatList = decibelioFacade.findHistoricalBySensorAndDateRange(
                                        sensorExternalId,
                                        startDate, endDate);

                        // Agrupar por timeframe name (DIURNO / NOCTURNO)
                        Map<String, List<HistoricalObservation>> grouped = flatList.stream()
                                        .collect(Collectors.groupingBy(
                                                        h -> h.getTimeFrame().getName(),
                                                        // Para mantener el orden de aparición:
                                                        LinkedHashMap::new,
                                                        Collectors.toList()));

                        RestResult result = new RestResult(
                                        RestResultStatus.SUCCESS,
                                        "Historical observations retrieved successfully",
                                        HistoricalObservation.class,
                                        grouped);
                        return Response.ok(result).build();

                } catch (DateTimeParseException ex) {
                        RestResult err = new RestResult(
                                        RestResultStatus.FAILURE,
                                        "Invalid date format: use YYYY-MM-DD",
                                        "DateParse",
                                        null);
                        return Response.status(Response.Status.BAD_REQUEST).entity(err).build();

                } catch (Exception e) {
                        RestResult err = new RestResult(
                                        RestResultStatus.FAILURE,
                                        "Error retrieving historical observations",
                                        HistoricalObservation.class,
                                        null);
                        return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(err).build();
                }
        }

        @GET
        @Path("create")
        @Produces(MediaType.APPLICATION_JSON)
        @Operation(summary = "Get all history")
        @APIResponses(value = {
                        @APIResponse(responseCode = "200", description = "Successful operation")
        })
        public Response getAllHistory(@QueryParam("date") String dateStr) {
                // Si la fecha no es proporcionada, se usa la fecha de hoy
                LocalDate date = dateStr != null ? LocalDate.parse(dateStr) : LocalDate.now();

                List<Sensor> sensors = decibelioFacade.findAllSensorsActive();
                List<HistoricalObservation> allHistoricalObservations = new ArrayList<>(); // Declarar la lista para
                                                                                           // todas las observaciones

                for (Sensor sensor : sensors) {
                        List<HistoricalObservation> historicalObservations = decibelioFacade
                                        .findMetricsByDayOrNight(sensor.getExternalId(), date);
                        allHistoricalObservations.addAll(historicalObservations); // Agregar las observaciones del
                                                                                  // sensor actual
                        System.out.println("Historical observations for sensor " + sensor.getName() + " on " + date
                                        + ": " + historicalObservations.size());
                }

                // Devuelves el resultado con todas las observaciones
                RestResult result = new RestResult(RestResultStatus.SUCCESS, "List consulted successfully",
                                HistoricalObservation.class, allHistoricalObservations); // Usamos la lista completa
                return Response.ok(result).build();
        }

}
