SELECT * FROM audit_patients;

-- Manejo de TRIGGERS
-- Ejemplo1
-- Crear un TRIGGER que permita validar si una edad es correcta.
-- Caso contrario generar un EXCEPTION-ERROR.

CREATE OR REPLACE TRIGGER tr_validate_age   --nombre del trigger
    BEFORE INSERT ON PATIENTS               --antes de insertar un registro en la tabla patiens
    FOR EACH ROW                            -- por cada registro
    DECLARE
        age_value NUMBER := 0;              --se inicializa valor de la variable
    BEGIN
        -- se calcula la edad 
        SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE(:NEW.PATIENT_DATE_OF_BIRTH)) / 12)
        INTO age_value FROM DUAL;

        --- se valida que la edad sea valida al fin respecto al valor calculado

        if age_value != :NEW.PATIENTS_AGE
        then
            --no se cumple la condicion genera error

            RAISE_APPLICATION_ERROR(-20001, 'El valor de la edad es incorrecto!!!');
        end if;
    END;
/
--se inserta valor valido
declare
    new_ID NUMBER := 1;
begin
    patients_row_create(new_ID, 'm', DATE '2000-06-10', 'William3', 'Barra3', 160, 200, '76531214', 210);
end;

SELECT * FROM PATIENTS;



--*********************************+
-- Ejemplo 2
-- Crear un TRIGGER de auditoria para la tabla DOCTORS
SELECT * FROM DOCTORS;

SELECT USER FROM DUAL;
SELECT sys_context('USERENV', 'SERVER_HOST') FROM DUAL;
SELECT to_char(SYSDATE) FROM DUAL;

--  crear tabla de auditoria

CREATE TABLE audit_doctors
(
    USER_NAME       VARCHAR2(25),
    SERVER_HOST     VARCHAR2(25),
    DATE_ACTION     VARCHAR2(25),
    EVENT_NAME      VARCHAR2(25),
    DOCTOR_NAME     VARCHAR2(25),
    DOCTOR_LASTNAME VARCHAR2(25)
);

--preparando sentencias

SELECT USER FROM DUAL;
SELECT sys_context('USERENV', 'SERVER_HOST') FROM DUAL;
SELECT to_char(SYSDATE) FROM DUAL;



CREATE OR REPLACE TRIGGER tr_audit_doctors  --nombre del trigger
    BEFORE UPDATE OR DELETE ON DOCTORS      --antes de insertar o actualizar la tabla DOCTORS
    FOR EACH ROW                            --para cada fila o registro
    DECLARE
    -- se declaran variables 
        user_name_value     VARCHAR2(25);
        server_host_value   VARCHAR2(25);
        sys_date_value      VARCHAR2(25);
        event_name          VARCHAR2(25);
    BEGIN

        -- sentencias a ejecutar

        SELECT USER INTO user_name_value FROM DUAL;
        SELECT sys_context('USERENV', 'SERVER_HOST') INTO server_host_value FROM DUAL;
        SELECT to_char(SYSDATE) INTO sys_date_value FROM DUAL;

        event_name := CASE  -- se establecen los dos escenarios
            WHEN DELETING THEN 'DELETE'     ---cuando se elimine un registro
            WHEN UPDATING THEN 'UPDATE'     --- cuando se actualice un registro
        END;

        -- se inserta el regsitro correspondiente
        INSERT INTO audit_doctors (USER_NAME, SERVER_HOST, DATE_ACTION, EVENT_NAME, DOCTOR_NAME, DOCTOR_LASTNAME)
        VALUES (user_name_value, server_host_value, sys_date_value, event_name, :OLD.DOCTOR_NAME, :OLD.DOCTOR_LASTNAME);

    END;
/

SELECT * FROM audit_doctors;
SELECT * FROM DOCTORS;

INSERT INTO DOCTORS (DOCTOR_NAME, DOCTOR_LASTNAME, DOCTOR_DATE_OF_BIRTH, DOCTOR_AGE) VALUES
    ('Juan', 'Misael', DATE '1975-12-10', 38);

UPDATE DOCTORS SET DOCTOR_NAME = 'Yuan' WHERE STAFF_ID = 70;
DELETE doctors WHERE staff_id = 70;

-- EJERCICIO FINAl
-- Crear un TRIGGER que use una función en su lógica.
-- Podría crear una función que valide si la edad es correcta. De ser correcta retorna 1 caso contrario retorna 0.

CREATE FUNCTION fn_validate_correct_age(    ---nombre de la funcion
        DATE_OF_BIRTH    IN VARCHAR2,       --variables
        AGE_DATA        IN NUMBER
    )
    RETURN NUMBER   --retorna un tipo numerico 0 o 1
    AS
        age_value NUMBER := 0;          --inicializando variables
        response NUMBER := 0;          
    BEGIN
        --se obtine la edad actual
        SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE(DATE_OF_BIRTH)) / 12)
        INTO age_value FROM DUAL;       -- se asigna en  la variable age_value el valor obtenido

        --- si valor calculado es igual a edad real
        if age_value = AGE_DATA then
            response := 1;      --retorna 1
        end if;

        RETURN response;        --retorna valor del response
    END;
/

CREATE OR REPLACE TRIGGER tr_validate_age_v2    --Se crea trigger
    BEFORE INSERT ON PATIENTS                   --se ejecuta despues de un insert        
    FOR EACH ROW                                --para todas las columnas
    BEGIN
        --se calcula edad
        if fn_validate_correct_age(:NEW.PATIENT_DATE_OF_BIRTH, :NEW.PATIENTS_AGE) = 0
        then
            --falla validacion manda mensaje

            RAISE_APPLICATION_ERROR(-20001, 'El valor de la edad es incorrecto!!!');
        end if;
    END;
/

-- se ejecuta el trigger
declare
    new_ID NUMBER := 1;
begin
    patients_row_create(new_ID, 'm', DATE '2000-06-10', 'William5', 'Barra5', 160, 200, '76531214', 21);
end;

SELECT * FROM PATIENTS;





























