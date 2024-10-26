package unl.feirnnr.cc.decibelio.sensor.model;

public enum SensorType {
    SOUND_LEVEL_METER ("SOUND_LEVEL_METER", "SONOMETRO");

    private final String key;
    private final String value;

    SensorType(String key, String value) {
        this.key = key;
        this.value = value;
    }

    public String getKey() {
        return key;
    }
    public String getValue() {
        return value;
    }
}
