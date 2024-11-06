package unl.feirnnr.cc.decibelio.sensor.boundary;

import jakarta.inject.Inject;
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
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

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
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "List consulted successfully", Metric.class, metrics);
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
        RestResult result = new RestResult(RestResultStatus.SUCCESS, "List consulted successfully", Metric.class, metrics);
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
                RestResult result = new RestResult(RestResultStatus.FAILURE, "File part is missing", "FileUpload", null);
                return Response.status(Response.Status.BAD_REQUEST).entity(result).build();
            }

            LOGGER.info("File part received");
            InputStream uploadedInputStream = filePart.getInputStream();
            if (uploadedInputStream == null) {
                LOGGER.severe("Input stream is null");
                RestResult result = new RestResult(RestResultStatus.FAILURE, "Error retrieving input stream", "FileUpload", null);
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(result).build();
            }

            LOGGER.info("Input stream successfully obtained");
            List<String> errors = decibelioFacade.loadMetricFileCSV(uploadedInputStream);

            if (errors.isEmpty()) {
                RestResult result = new RestResult(RestResultStatus.SUCCESS, "File uploaded and processed successfully", "FileUpload", errors);
                return Response.ok(result).build();
            } else {
                String errorMessage = String.join("\n", errors);
                RestResult result = new RestResult(RestResultStatus.FAILURE, "Errors occurred while processing the file:\n" + errorMessage, "FileUpload", errors);
                return Response.status(Response.Status.BAD_REQUEST).entity(result).build();
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing file", e);
            RestResult result = new RestResult(RestResultStatus.FAILURE, "Error processing file", "FileUpload", null);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(result).build();
        }
    }
}
