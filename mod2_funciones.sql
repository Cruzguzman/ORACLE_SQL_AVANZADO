-- Crear una funcion que me permita saber el año actual

SELECT SYSDATE
FROM DUAL;
select to_char(sysdate, 'YYYY') from dual;

-- Solucion
CREATE FUNCTION get_current_year
    RETURN DATE IS
        current_year DATE;
    BEGIN
        SELECT SYSDATE INTO current_year
        FROM DUAL;

        return current_year;
    END;
/

SELECT get_current_year FROM DUAL;


-- Crear una funcion que me permita generar un reporte(nombres, apellidos y edad) de los doctores registrados.
-- El nombre y apellido debe ser concatenados en una sola columna.
SELECT CONCAT('William', CONCAT(' ', 'Barra')) FROM DUAL;

-- SOLUCION
CREATE OR REPLACE FUNCTION concat_name_and_lastname(--nombre de la funcion
    par1 IN VARCHAR,  --parametro 1 de tipo varchar
    par2 IN VARCHAR   --parametro 2 de tipo varchar
)
    RETURN CLOB IS  --retornan un tipo clob
        response CLOB := ''; -- valor por defecto de tipo clob
    BEGIN
        SELECT CONCAT(par1, CONCAT(' ', par2)) INTO response -- se concatena y e asigna a la variable response
        FROM DUAL;
        RETURN response;  --se retorna el valor concatenado
    END;

SELECT concat_name_and_lastname(doc.DOCTOR_NAME, doc.DOCTOR_LASTNAME) AS FULL_NAME
FROM DOCTORS doc; --se llama a la funcion



-- Vemos cual es el formato de fecha
SELECT
  value
FROM
  V$NLS_PARAMETERS
WHERE
  parameter = 'NLS_DATE_FORMAT';

-- fmDD-MM-RR

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_DATE_FORMAT = 'fmDD-MM-RR';

--obtiene el dia de nacimiento respcto a la fecha
SELECT TO_CHAR(TO_DATE('2000-06-10'), 'Day' )
FROM DUAL;


--funcion que obtiene el dia de nacimiento
CREATE FUNCTION format_table_patients(  --nombre de la funcion
  fecha varchar --parametro
  )
    RETURN CLOB IS
        response CLOB := '';  --se setea vlor inical
        fec_nac DATE;         -- variable de tipo date
    BEGIN
        fec_nac := TO_DATE(fecha);  --conversion de tpos
        SELECT TO_CHAR(fec_nac, 'Day' ) INTO response ---se obtine el dia y ae asigna valor a la variable
        FROM DUAL;  --de la tabla dual
        RETURN response;  --se retorna valor
    END;

CREATE OR REPLACE FUNCTION get_gender(---nombre de la funcion
  gender varchar  --se declara variable de tipo varchar
  )
    return clob is  -- se tetorna un tipo clob por el tamaño de la cadena
        response clob := '';  --se asigna valor por defecto
    begin
        case gender --se declara la variable para  manipular opciones
            when 'f' THEN response := 'femenino'; --cuando sea f retornanr femenino
            when 'm' THEN response := 'masculino';  --cuaando es m retorna masculino
        end case; ---termina el case
        return response;  --retorna el resultado esperado
    end;

SELECT pat.PATIENT_NAME,
       pat.PATIENT_LASTNAME,
       pat.PATIENT_DATE_OF_BIRTH,
       get_gender(pat.PATIENT_GENDER) AS GENDER,
       format_table_patients(pat.PATIENT_DATE_OF_BIRTH) AS DAY  --parametros
FROM PATIENTS pat;---se llaman las funiones y las columnas solicitadas



-- Clase final modulo 2

--primer pas
CREATE TYPE type_row_doctors AS OBJECT  --Se crea un tipo para facilitar la consulta
(
  name      VARCHAR(15),  --selecciona nombre
  lastname  VARCHAR(15),  --seleciona apellio
  age       INTEGER       --selciona edad
);

--segundo paso
CREATE TYPE type_table_doctors  --nombre del tipo
AS TABLE OF type_row_doctors;   --se asigna al nuevo tipo de estructuras

--se crea la funcion
CREATE FUNCTION get_report_doctors  --nombre de la funcion
  RETURN type_table_doctors AS      --retornara un tipo previamente creado
  BEGIN
    return type_table_doctors(
      type_row_doctors('William', 'Barra', 32), --se setan datos
      type_row_doctors('Micaela', 'mar', 24)
    );
  END;  --fin funcion

SELECT get_report_doctors FROM DUAL; --formato de datos incosistente--no tabla
SELECT * FROM get_report_doctors;     --
SELECT * FROM TABLE (get_report_doctors); --muestra datos en foemato de tabla
SELECT info.name, info.lastname
FROM TABLE (get_report_doctors) info; 

CREATE OR REPLACE FUNCTION get_report_doctors_v2
  RETURN type_table_doctors IS
    data_table type_table_doctors := type_table_doctors();
  BEGIN
   data_table.extend;
   data_table(data_table.COUNT) := type_row_doctors('William', 'Barra', 32);

   data_table.extend;
   data_table(data_table.COUNT) := type_row_doctors('Micaela', 'mar', 24);

   RETURN data_table;
  END;

SELECT v2.*
FROM TABLE (get_report_doctors_v2) v2;

SELECT info.name, info.lastname, info.age
FROM TABLE (get_report_doctors_v2) info
WHERE info.age = 32;

