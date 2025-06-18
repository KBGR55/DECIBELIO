package unl.feirnnr.cc.decibelio.common.service;

import jakarta.annotation.PostConstruct;

import jakarta.inject.Inject;
import jakarta.ejb.Singleton;
import jakarta.ejb.Schedule;
import jakarta.ejb.Startup;
import unl.feirnnr.cc.decibelio.sensor.business.DecibelioFacade;
import unl.feirnnr.cc.decibelio.sensor.model.HistoricalObservation;
import unl.feirnnr.cc.decibelio.sensor.model.Sensor;

import java.time.LocalDate;
import java.util.List;

@Singleton
@Startup 
public class AutomaticHistoricalObservation {

    @Inject
    DecibelioFacade decibelioFacade;

    public AutomaticHistoricalObservation() {}

    @PostConstruct
    public void init() {
        System.out.println("AutomaticSensorFetcher initialized.");
    }

    // Esta es la tarea programada que se ejecutará automáticamente todos los días a medianoche
    @Schedule(hour = "0", minute = "0", persistent = false) // A medianoche todos los días
    public void fetchSensors() {
        try {
            List<Sensor> sensors = decibelioFacade.findAllSensorsActive();
            LocalDate today = LocalDate.now();
            for (Sensor sensor : sensors) {
                List<HistoricalObservation> historicalObservations = decibelioFacade.findMetricsByDayOrNight(sensor.getExternalId(), today);
                System.out.println("Historical observations for sensor " + sensor.getName() + ": " + historicalObservations.size());
            }

        } catch (Exception e) {
            System.err.println("🔥 Error  while retrieving sensors or historical observations");
        }
    }
}
