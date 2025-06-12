package unl.feirnnr.cc.decibelio.common.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.inject.Inject;
import unl.feirnnr.cc.decibelio.dto.ObservationDTO;
import unl.feirnnr.cc.decibelio.sensor.business.DecibelioFacade;
import unl.feirnnr.cc.decibelio.sensor.data.ObservationService;
import unl.feirnnr.cc.decibelio.sensor.data.SensorService;

import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Map;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@Singleton
@Startup
public class MqttSensorListener implements MqttCallback {

    @Inject
    @ConfigProperty(name = "mqtt.url")
    String brokerUrl;

    @Inject
    @ConfigProperty(name = "mqtt.clientId")
    String clientId;

    @Inject
    @ConfigProperty(name = "mqtt.qos")
    int qos;

    @Inject
    @ConfigProperty(name = "mqtt.topic.ibelium")
    String topicTemplate;

    @Inject
    @ConfigProperty(name = "mqtt.sensors")
    String sensorIds;

    @Inject
    @ConfigProperty(name = "mqtt.options.timeout")
    int timeOut;

    @Inject
    @ConfigProperty(name = "mqtt.options.keepAliveInterval")
    int keepAliveInterval;

    @Inject
    @ConfigProperty(name = "mqtt.options.maxReconnectDelay")
    int maxReconnectDelay;

    @Inject
    SensorService sensorService;

    @Inject
    ObservationService observationService;

    @Inject
    DecibelioFacade decibelioFacade;

    private MqttClient client;

    @PostConstruct
    public void init() {
        try {
            client = new MqttClient(brokerUrl, clientId, new MemoryPersistence());
            MqttConnectOptions options = buildMqttConnectOptions();
            client.connect(options);
            client.setCallback(this);

            for (String sensorId : sensorService.getAllExternalIdsActive()) {
                String topic = topicTemplate.replace("{param}", sensorId);
                client.subscribe(topic, qos);
                //client.subscribe(topic, qos, this::handleMessage);
                System.out.println("Suscrito al topic: " + topic);
            }
        } catch (MqttException e) {
            System.err.println("Error al conectar al broker MQTT: " + e.getMessage());
            e.printStackTrace();
            handleConnectionFailure(e);
        }
    }

    private MqttConnectOptions buildMqttConnectOptions() {
        MqttConnectOptions options = new MqttConnectOptions();
        // TIEMPO DE ESPERA DE CONEXIÓN
        options.setConnectionTimeout(timeOut); // 15 segundos
        // INTERVALO DE KEEP-ALIVE (Frecuenca de mensajes)
        options.setKeepAliveInterval(keepAliveInterval); // 300 segundos (5 minutos)
        // RETRASO MÁXIMO DE RECONEXIÓN
        options.setMaxReconnectDelay(maxReconnectDelay); // 120 segundos, 2 minutos
        // Configuraciones complementarias
        options.setAutomaticReconnect(true); // Reconexión automática habilitada
        options.setCleanSession(false);      // Mantener sesión entre reconexiones
        return options;
    }

    private void handleConnectionFailure(MqttException e) {
        // Lógica para manejar errores iniciales
        System.err.println("Error crítico en conexión inicial: " + e.getMessage());
        e.printStackTrace();
        // Podrías agregar aquí notificaciones o reintentos programados
    }

    @Override
    public void connectionLost(Throwable cause) {
        System.err.println("Conexión MQTT perdida: " + cause.getMessage());
        cause.printStackTrace();
        // Lógica de reconexión automática
        reconnect();
    }

    private void handleMessage(String topic, MqttMessage message) throws JsonProcessingException {
        String payload = new String(message.getPayload());
        System.out.println("Mensaje recibido desde [" + topic + "]: " + payload);

        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> payloadMap = mapper.readValue(payload, new TypeReference<>() {});

        String[] parts = topic.split("/");
        String externalIdPart = parts[2];
        String externalId = externalIdPart.split("_")[0];

        float sonLaeq = Float.parseFloat(payloadMap.getOrDefault("son_laeq", "0").toString());
        // Obtener la zona horaria del servidor
        String timeInstantStr = payloadMap.get("TimeInstant").toString();
        Instant instant = Instant.parse(timeInstantStr);
        ZonedDateTime ecuadorZdt = instant.atZone(ZoneId.of("America/Guayaquil"));
        LocalDate date = ecuadorZdt.toLocalDate();
        LocalTime time = ecuadorZdt.toLocalTime();

        ObservationDTO observationDTO = buildInstanceObservationDTO(externalId, date, time, sonLaeq);
        decibelioFacade.insert(observationDTO);
    }

    private ObservationDTO buildInstanceObservationDTO(String externalId, LocalDate date, LocalTime time, float value) {
        ObservationDTO observationDTO = new ObservationDTO();
        observationDTO.setDate(date);
        observationDTO.setSensorExternalId(externalId);
        observationDTO.setValue(value);
        observationDTO.setTime(time);
        return observationDTO;
    }

    @Override
    public void messageArrived(String topic, MqttMessage message) {
        try {
            handleMessage(topic,message);
        } catch (JsonProcessingException e) {
            System.err.println("Error al procesar el tópico a Json: " + e.getMessage());
            //throw new RuntimeException(e);
            e.printStackTrace();
        }
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
        // No necesario para suscripciones
    }

    private void reconnect() {
        int maxAttempts = 5;
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            try {
                if (!client.isConnected()) {
                    System.out.println(" Intentando reconexión (" + attempt + "/" + maxAttempts + ")");
                    client.reconnect();
                    System.out.println(" Reconexión exitosa");
                    return;
                }
            } catch (MqttException e) {
                System.err.println("Intento " + attempt + " fallido: " + e.getMessage());
                try {
                    Thread.sleep(5000); // Espera 5 segundos entre intentos
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                }
            }
        }
        System.err.println("🔥 Reconexión fallida después de " + maxAttempts + " intentos");
    }

    @PreDestroy
    public void cleanup() {
        try {
            if (client != null && client.isConnected()) {
                client.disconnect();
                client.close();
            }
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

}
