package unl.feirnnr.cc.decibelio.common.rest;

import jakarta.json.bind.annotation.JsonbPropertyOrder;
import java.io.Serializable;

/**
 * @author wduck
 */
@JsonbPropertyOrder({"status", "message", "type", "payload"})
public class RestResult implements Serializable {
    String status;
    String message;
    String type;
    Object payload;

    public RestResult(RestResultStatus status, String message, String type, Object payload) {
        this.status = status.name();
        this.message = message;
        this.type = type;
        this.payload = payload;
    }

    public RestResult(RestResultStatus status, String message, Class<?> type, Object payload) {
        this.status = status.name();
        this.message = message;
        this.type = type.getSimpleName();
        this.payload = payload;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Object getPayload() {
        return payload;
    }

    public void setPayload(Object payload) {
        this.payload = payload;
    }

}
