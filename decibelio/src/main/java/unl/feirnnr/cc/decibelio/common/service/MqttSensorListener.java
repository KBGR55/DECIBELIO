package unl.feirnnr.cc.decibelio.common.service;

import jakarta.annotation.PostConstruct;
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
public class MqttSensorListener {

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
    ObservationService observationService; // Servicio de persistencia

    @Inject
    DecibelioFacade decibelioFacade;

    private MqttClient client;

    @PostConstruct
    public void init() {
        try {
            client = new MqttClient(brokerUrl, clientId, new MemoryPersistence());
            MqttConnectOptions options = new MqttConnectOptions();
            options.setCleanSession(true);
            client.connect(options);

            for (String sensorId : sensorService.getAllExternalIds()) {
                String topic = topicTemplate.replace("{param}", sensorId);
                client.subscribe(topic, (t, msg) -> {
                    String payload = new String(msg.getPayload());
                    System.out.println("Mensaje recibido: " + payload);

                    try {
                        ObjectMapper mapper = new ObjectMapper();
                        Map<String, Object> payloadMap = mapper.readValue(payload, new TypeReference<>() {
                        });

                        String[] parts = t.split("/");
                        String externalIdPart = parts[2]; // ej. HOPb0a7323594a2_NLO
                        String externalId = externalIdPart.split("_")[0]; // extrae HOPb0a7323594a2

                       // observationService.processAndSaveObservation(externalId, payloadMap);
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
                });
                System.out.println("Suscrito a: " + topic);
            }
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

}
