package unl.feirnnr.cc.decibelio.common.rest.util;

import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonArrayBuilder;
import jakarta.json.JsonObject;
import jakarta.json.JsonObjectBuilder;
import jakarta.json.JsonReader;
import jakarta.json.JsonStructure;
import jakarta.json.JsonValue;
import java.io.StringReader;
import java.util.List;
import java.util.Map.Entry;


/**
 * Utilería para transformar a Objetos JSON
 *
 * @author wduck
 */
public class JsonUtil {

    public static JsonStructure transformToJson(String jsonString) {
        JsonReader jsonReader = Json.createReader(new StringReader(jsonString));
        return jsonReader.read();
    }

    public static JsonObject transformToJsonObject(String jsonString) {
        JsonReader jsonReader = Json.createReader(new StringReader(jsonString));
        return jsonReader.readObject();
    }

    public static JsonArray transformToJsonArray(String jsonString) {
        JsonReader jsonReader = Json.createReader(new StringReader(jsonString));
        return jsonReader.readArray();
    }

    public static JsonArray transformToJsonArray(List<JsonObject> jsonObjects) {
        JsonArrayBuilder builder = Json.createArrayBuilder();
        jsonObjects.forEach(builder::add);
        return builder.build();
    }

    public static JsonObjectBuilder jsonObjectToBuilder(JsonObject jo) {
        JsonObjectBuilder job = Json.createObjectBuilder();

        for (Entry<String, JsonValue> entry : jo.entrySet()) {
            job.add(entry.getKey(), entry.getValue());
        }

        return job;
    }

}