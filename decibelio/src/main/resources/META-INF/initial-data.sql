-- INICIACIÓN DE GENERADORES DE IDS (UNA SOLA VEZ)
INSERT INTO public.identitygenerator(name, value) VALUES ('TimeFrame', 1);
INSERT INTO public.identitygenerator(name, value) VALUES ('LandUse', 1);
INSERT INTO public.identitygenerator(name, value) VALUES ('OptimalRange', 1);
INSERT INTO public.identitygenerator(name, value) VALUES ('UserRol', 1);

-- INICIACIÓN DE Periodos de Tiempo (UNA SOLA VEZ)
INSERT INTO public.timeframe(id, name, starttime, endtime) VALUES (1, 'DIURNO', '07:01:00', '21:00:00');
INSERT INTO public.timeframe(id, name, starttime, endtime) VALUES (2, 'NOCTURNO', '21:00:00', '07:00:00');
-- ACTUALIZACIÓN DE ID del Periodos de Tiempo
UPDATE public.identitygenerator SET value=(SELECT MAX(id) FROM public.timeframe)  WHERE name LIKE 'TimeFrame';

-- INICIACIÓN DE USO DE SUELO
INSERT INTO public.landuse(id, name, description) VALUES (1, 'RESIDENCIAL', '');
INSERT INTO public.landuse(id, name, description) VALUES (2, 'EQUIPAMIENTO DE SERVICIOS SOCIALES', '');
INSERT INTO public.landuse(id, name, description) VALUES (3, 'EQUIPAMIENTO DE SERVICIOS PÚBLICOS', '');
INSERT INTO public.landuse(id, name, description) VALUES (4, 'COMERCIAL', '');
INSERT INTO public.landuse(id, name, description) VALUES (5, 'AGRÍCOLA RESIDENCIAL', '');
INSERT INTO public.landuse(id, name, description) VALUES (6, 'INDUSTRIAL ID1/ID2', '');
INSERT INTO public.landuse(id, name, description) VALUES (7, 'INDUSTRIAL ID3/ID4', '');
-- ACTUALIZACIÓN DE ID del Uso de Suelo
UPDATE public.identitygenerator SET value=(SELECT MAX(id) FROM public.landuse) WHERE name LIKE 'LandUse';

-- INICIACIÓN DE RANGOS PARA CADA USO DE SUELO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (1, 55.0, 1, 1); -- RESIDENCIAL, DIURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (2, 45.0, 2, 1); -- RESIDENCIAL, NOCTURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (3, 55.0, 1, 2); -- EQ1, DIURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (4, 45.0, 2, 2); -- EQ1, NOCTURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (5, 60.0, 1, 3); -- EQ2, DIURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (6, 50.0, 2, 3); -- EQ2, NOCTURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (7, 60.0, 1, 4); -- COMERCIAL, DIURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (8, 50.0, 2, 4); -- COMERCIAL, NOCTURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (9, 65.0, 1, 5); -- AR, DIURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (10, 45.0, 2, 5); -- AR, NOCTURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (11, 65.0, 1, 6); -- ID1/ID2, DIURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (12, 55.0, 2, 6); -- ID1/ID2, NOCTURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (13, 70.0, 1, 7); -- ID3/ID4, DIURNO
INSERT INTO public.optimalrange(id, value, timeframe_id, landuse_id) VALUES (14, 65.0, 2, 7); -- ID3/ID4, NOCTURNO

-- ACTUALIZACIÓN DE ID del RANGO
UPDATE public.identitygenerator SET value=(SELECT MAX(id) FROM public.optimalrange) WHERE name LIKE 'OptimalRange';

-- INICIACIÓN DE ROLES (UNA SOLA VEZ)
INSERT INTO public.rol(id, type, status) VALUES (1, 'ADMINISTRADOR', true);
INSERT INTO public.rol(id, type, status) VALUES (2, 'VISOR_GENERAL', true);

-- ACTUALIZACIÓN DE ID de Roles
UPDATE public.identitygenerator SET value=(SELECT MAX(id) FROM public.rol) WHERE name LIKE 'Rol';