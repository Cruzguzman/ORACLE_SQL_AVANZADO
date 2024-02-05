-- En base al uso de CURSORES generar todos los registros de la tabla DOCTORS_ASSIGNED_TO_PATIENTS.
-- Asignar al DOCTOR de nombre a todos los pacientes que se tiene.

-- 1er paso
CREATE TYPE row_DATP AS OBJECT
(
    PATIENT_ID NUMBER,
    STAFF_ID   NUMBER,
    DATE_FROM  DATE,
    DATE_TO    DATE
);

-- 2do paso
CREATE TYPE DATA_DATP AS TABLE OF row_DATP;

-- Paso 3
-- Obteniendo el doctor
SELECT *
FROM DOCTORS doc
WHERE doc.STAFF_ID = 65;
-- Obteniendo todos los patients
SELECT *
FROM PATIENTS pa;


-------------------
CREATE OR REPLACE FUNCTION generate_data_for_datp(  --se crea funcion
        id_doctor NUMBER    --se declara variable para id
    )
    RETURN DATA_DATP IS     --retorna un valor de tipo estructura
    filas DATA_DATP := DATA_DATP();     --se declara variable y se asigna valor a retornar-inicializar
    --se recorre la tabla y se obtine el id
    CURSOR cursor_doctor IS SELECT * FROM DOCTORS doc WHERE doc.STAFF_ID = id_doctor;
    --se obtinen los pacientes
    CURSOR cursor_patients IS SELECT * FROM PATIENTS pa;
BEGIN

    for fila_doctors IN cursor_doctor loop  --se itera primera fila de id
        for fila_patients IN cursor_patients loop   --se itera otra fila de pacientes

        -- se inserta los valores acorde al id asignado a los pacientes
            insert into DOCTORS_ASSIGNED_TO_PATIENTS (PATIENT_ID, STAFF_ID, DATE_FROM, DATE_TO)
            VALUES (fila_patients.PATIENT_ID, fila_doctors.STAFF_ID, SYSDATE, SYSDATE);
            filas.extend;
            filas(filas.COUNT) := row_DATP(fila_patients.PATIENT_ID, fila_doctors.STAFF_ID, SYSDATE, SYSDATE);
        end loop;
    end loop;
    COMMIT;
    return filas;
END;
/




SELECT *
FROM table (generate_data_for_datp(65));

declare
    all_data DATA_DATP;
begin
    all_data := generate_data_for_datp(65);
end;

SELECT *
FROM DOCTORS_ASSIGNED_TO_PATIENTS;



-- En base al uso de CURSORES generar un reporte que muestre los doctores mayores a 35 años.
-- Mostra nombres, apellidos y edad
-- v1
DECLARE
    CURSOR cursor_doctors IS SELECT * FROM DOCTORS;
BEGIN
    FOR fila_doctors IN cursor_doctors
        loop
            DBMS_OUTPUT.PUT_LINE(
                fila_doctors.DOCTOR_NAME || ' ' ||
                fila_doctors.DOCTOR_LASTNAME || ' ' ||
                fila_doctors.DOCTOR_AGE
            );
        end loop;
END;

-- v2
DECLARE
    CURSOR cursor_doctors(data_age NUMBER) IS
        SELECT * FROM DOCTORS
         WHERE DOCTOR_AGE > data_age;
BEGIN
    FOR fila_doctors IN cursor_doctors(40)
        loop
            DBMS_OUTPUT.PUT_LINE(
                fila_doctors.DOCTOR_NAME || ' ' ||
                fila_doctors.DOCTOR_LASTNAME || ' ' ||
                fila_doctors.DOCTOR_AGE
            );
    end loop;
END;

-- v3
DECLARE
    name VARCHAR2(25);
    lastname VARCHAR2(25);
    age NUMBER;
    CURSOR cursor_doctors(data_age NUMBER) IS
        SELECT DOCTOR_NAME, DOCTOR_LASTNAME, DOCTOR_AGE
        FROM DOCTORS
        WHERE DOCTOR_AGE > data_age;
BEGIN
    open cursor_doctors(40);
    loop
        fetch cursor_doctors INTO name, lastname, age;
        EXIT WHEN cursor_doctors%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(name || ' ' || lastname || ' ' || age);
    end loop;
    CLOSE cursor_doctors;
END;
/

-- Replicar el ejemplo del video anterior utilizando cursores de retorno.
-- v4
CREATE OR REPLACE PROCEDURE pr_doctors_by_age(
    age IN NUMBER,
    cursor_doctors IN OUT SYS_REFCURSOR
) IS
    BEGIN
        OPEN cursor_doctors FOR
            SELECT DOCTOR_NAME, DOCTOR_LASTNAME, DOCTOR_AGE
            FROM DOCTORS
            WHERE DOCTOR_AGE > age;
    END;
/

DECLARE
    name VARCHAR2(25);
    lastname VARCHAR2(25);
    age NUMBER;
    cursor_doctors SYS_REFCURSOR;
BEGIN
    pr_doctors_by_age(35, cursor_doctors);
    loop
        fetch cursor_doctors INTO name, lastname, age;
        EXIT WHEN cursor_doctors%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(name || ' ' || lastname || ' ' || age);
    end loop;
    CLOSE cursor_doctors;
END;
/













