package unl.feirnnr.cc.decibelio.common.rest;

/**
 *
 * @author wduck
 * @param <T>
 */
public class HttpResponse<T> {

    int status;
    Throwable exception;
    T body;

    public HttpResponse() {
    }

    public HttpResponse(int status, Throwable exception, T body) {
        this.status = status;
        this.exception = exception;
        this.body = body;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public Throwable getException() {
        return exception;
    }

    public void setException(Throwable exception) {
        this.exception = exception;
    }

    public T getBody() {
        return body;
    }

    public void setBody(T body) {
        this.body = body;
    }
}
