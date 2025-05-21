package unl.feirnnr.decibelio.common.service;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.inject.Inject;
import org.eclipse.paho.client.mqttv3.*;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@Singleton
@Startup
public class MqttSensorListener {

    @Inject
    @ConfigProperty(name = "mqtt.broker.url")
    String brokerUrl;

    @Inject
    @ConfigProperty(name = "mqtt.topic")
    String topic;

    private MqttClient client;

    @PostConstruct
    public void init() {
        System.out.println("Broker URL: " + brokerUrl); // <-- DEBUG
        System.out.println("Topic: " + topic);
        try {
            client = new MqttClient(brokerUrl, "decibelio_backend");
            MqttConnectOptions options = new MqttConnectOptions();
            options.setCleanSession(true);
            client.connect(options);

            client.subscribe(topic, (t, msg) -> {
                String payload = new String(msg.getPayload());
                System.out.println("Mensaje recibido: " + payload);
                // Aquí puedes insertar el mensaje en tu base de datos
            });

            System.out.println("Suscripción MQTT activa en: " + topic);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }
}
