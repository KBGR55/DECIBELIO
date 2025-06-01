package unl.feirnnr.cc.decibelio.common.security;

import java.util.Map;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import jakarta.enterprise.context.ApplicationScoped;
import java.security.Key;
import java.util.Date;


@ApplicationScoped
public class JwtService {
        private static final String SECRET_KEY = System.getenv("JWT_SECRET") != null
            ? System.getenv("JWT_SECRET")
            : "CAMBIAR_A_UNA_CADENA_MUY_LARGA_PARASEGURIDAD1234567890"; // mínimo 256 bits

    // 2. Tiempo de expiración del token (por ejemplo, 1 hora = 3600_000 ms)
    private static final long EXPIRATION_MS = 3600_000;

    private Key getSigningKey() {
        // Convierte la cadena Base64 o Raw en una Key
        // Aquí asumimos texto sin codificación Base64; para Base64, usar io.jsonwebtoken.io.Decoders.BASE64.decode(...)
        byte[] keyBytes = SECRET_KEY.getBytes();
        return Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * Genera un JWT firmado con HMAC SHA-256 que incluye:
     *   - Subject (usamos el ID o email del usuario)
     *   - Claims adicionales (roles, nombre, etc.)
     *   - Fecha de expiración
     */
    public String generateToken(String subject, Map<String, Object> extraClaims) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + EXPIRATION_MS);

        return Jwts.builder()
                .setSubject(subject)                       // típicamente el userId o email
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .addClaims(extraClaims)                    // aquí ponemos roles u otros datos
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * Valida y parsea el token retornando el mapa de Claims (si es válido),
     * o lanza excepción si está expirado o alterado.
     */
    public Map<String, Object> parseToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    
}
