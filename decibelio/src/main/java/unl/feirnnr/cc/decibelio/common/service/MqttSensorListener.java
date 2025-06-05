package unl.feirnnr.cc.decibelio.common.service;

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
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Map;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@Singleton
@Startup
public class MqttSensorListener implements MqttCallback {

    private static final int QOS = 1;

    @Inject
    @ConfigProperty(name = "mqtt.broker.url")
    String brokerUrl;

    @Inject
    @ConfigProperty(name = "mqtt.clientId")
    String clientId;

    @Inject
    @ConfigProperty(name = "mqtt.topic.ibelium")
    String topicTemplate;

    @Inject
    @ConfigProperty(name = "mqtt.sensors")
    String sensorIds;

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
            MqttConnectOptions options = new MqttConnectOptions();
            options.setAutomaticReconnect(true);
            options.setCleanSession(true);
            // options.setConnectionTimeout(10); // Timeout en segundos
            client.setCallback(this);

            client.connect(options);

            for (String sensorId : sensorService.getAllExternalIdsActive()) {
                String topic = topicTemplate.replace("{param}", sensorId);
                client.subscribe(topic, QOS);
                System.out.println("Suscrito al topic: " + topic);
            }
        } catch (MqttException e) {
            System.err.println("Error al conectar al broker MQTT: " + e.getMessage());
            e.printStackTrace();
            handleConnectionFailure(e);
        }
    }

    private void handleConnectionFailure(MqttException e) {
        // Lógica para manejar errores iniciales
        System.err.println("🔥 Error crítico en conexión inicial: " + e.getMessage());
        // Podrías agregar aquí notificaciones o reintentos programados
    }

    @Override
    public void connectionLost(Throwable cause) {
        System.err.println("⚠️ Conexión MQTT perdida: " + cause.getMessage());
        cause.printStackTrace();
        // Lógica de reconexión automática
        reconnect();
    }

    @Override
    public void messageArrived(String topic, MqttMessage message) {
        System.out.println("📬 Mensaje recibi [" + topic + "]: " + new String(message.getPayload()));
        String payload = new String(message.getPayload());
        try {
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> payloadMap = mapper.readValue(payload, new TypeReference<>() {
            });

            String[] parts = topic.split("/");
            String externalIdPart = parts[2];
            String externalId = externalIdPart.split("_")[0];

            float sonLaeq = Float.parseFloat(payloadMap.getOrDefault("son_laeq", "0").toString());
            String timeInstant = payloadMap.get("TimeInstant").toString();
            LocalDate date = LocalDate.parse(timeInstant.substring(0, 10));
            LocalTime time = LocalTime.parse(timeInstant.substring(11, 19));

            ObservationDTO observationDTO = new ObservationDTO();
            observationDTO.setDate(date);
            observationDTO.setSensorExternalId(externalId);
            observationDTO.setValue(sonLaeq);
            observationDTO.setTime(time);
            decibelioFacade.insert(observationDTO);

        } catch (Exception e) {
            e.printStackTrace();
        }
        // Aquí tu lógica de procesamiento
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
                    System.out.println("↩️ Intentando reconexión (" + attempt + "/" + maxAttempts + ")");
                    client.reconnect();
                    System.out.println("✅ Reconexión exitosa");
                    return;
                }
            } catch (MqttException e) {
                System.err.println("❌ Intento " + attempt + " fallido: " + e.getMessage());
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
