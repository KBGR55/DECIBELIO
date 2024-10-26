package unl.feirnnr.cc.decibelio.common.rest.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

/**
 *
 * @author wduck
 */
public class DateTimeUtil {

    public static LocalDate getLocalDate(String dateStr) throws DateTimeParseException{
        LocalDate localDate = null;
        if (dateStr != null && !dateStr.isEmpty()) {
            localDate = LocalDate.parse(dateStr, DateTimeFormatter.ISO_DATE);
        }
        return localDate;
    }

    public static LocalDateTime getLocalDateTime(String dateStr) throws DateTimeParseException{
        LocalDateTime localDateTime = null;
        if (dateStr != null && !dateStr.isEmpty()) {
            localDateTime = LocalDateTime.parse(dateStr, DateTimeFormatter.ISO_DATE_TIME);
        }
        return localDateTime;
    }
}
