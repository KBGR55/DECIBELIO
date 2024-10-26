package unl.feirnnr.cc.decibelio.common.rest;

import java.io.Serializable;
/**
 *
 * @author wduck
 */
public class CountResult implements Serializable{

    Number total;

    public CountResult(Number total) {
        this.total = total;
    }

    public Number getTotal() {
        return total;
    }

    public void setTotal(Number total) {
        this.total = total;
    }

}
