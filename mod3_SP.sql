-- Manejo de SP
--puede recibir parametros o no recibirlos
--parametros de entrada y salida
--no retornan un valor 

--******************************************************
-- EJEMPLO 1
-- Crear una SP que me permita generar todos los valores de una nueva columna.
-- Agregar el campo patients_age en la tabla PATIENTS y generar todos sus valores desde un procedimiento almacenado

SELECT SYSDATE FROM DUAL;
SELECT TO_DATE(SYSDATE, 'YY-MM-DD') FROM DUAL;
SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE('2000-06-10', 'YY-MM-DD')) / 12) FROM DUAL;

ALTER TABLE PATIENTS ADD PATIENTS_AGE INTEGER;  --se agreaga nueva columna


-----------------

CREATE PROCEDURE generate_age   --nombre del sp
    AS                          -- no hay parametros de entrada
        CURSOR cursor_patients IS SELECT * FROM PATIENTS;   --se declara cursor para iterar
                                                            --las columnas de la tabla pacientes
        fila cursor_patients%ROWTYPE;                       --tipo de cursosr para acceder columnas
        age_value INTEGER;                                  -- se declara variable de tipo integer
    BEGIN

        FOR fila IN cursor_patients --se inicializa cursr
            loop
                ---se calcula edad respecto a la fecha de nacimiento
                SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE(fila.PATIENT_DATE_OF_BIRTH)) / 12)
                INTO age_value FROM DUAL; -- se almacena edad en la variable
                --se actualiza la columna con losdatos calculados
                UPDATE PATIENTS SET PATIENTS.PATIENTS_AGE = age_value 
                WHERE PATIENT_ID = fila.PATIENT_ID;
            end loop;   ---termina cursor

    END;    --fin procedure
/

-- EXECUTE generate_age; se ejecuta sp y se actualizan datos en la tabla
begin
  generate_age;
end;
--*****************************************
-- EJEMPLO 2
-- Crear una SP que me permita insertar nuevos registros.
-- El SP debe ser capaz de insertar nuevos registros a la tabla PATIENTS.

CREATE OR REPLACE PROCEDURE patients_row_create(    --nobre del SP
    ID              IN OUT INTEGER,     --variable de entrada y salida
    GENDER          IN CHAR,            --variable de entrada igual que las demas
    DATE_OF_BIRTH   IN DATE,
    NAME            IN VARCHAR2,
    LASTNAME        IN VARCHAR2,
    HEIGHT          IN NUMBER,
    WEIGHT          IN NUMBER,
    CELLPHONE       IN VARCHAR2,
    AGE             IN NUMBER
    )
    AS
        validate_id NUMBER;     --se declara variable para almacenar valor maximo
    BEGIN
        SELECT COUNT(pa.PATIENT_ID) INTO validate_id    --se determina valor maximo y se asigna a la variable
        FROM PATIENTS pa                                -- de la tabla
        WHERE pa.PATIENT_ID = ID;                       -- donde el id sea igual al valor de entrada

        if validate_id > 0 then                         --si validate_id es mayor a cero hacer
            SELECT MAX(pa.PATIENT_ID) INTO ID           -- se determina el valor maximo y se le asigna al id
            FROM PATIENTS pa;                           --- de la tabla
            ID := ID + 1;                               -- se suma el valor maximo mas uno
        end if;         --fin if

            --se prepara sentencia de insercion del registro con las variables de entrada y las columnas
        insert into PATIENTS (PATIENT_GENDER, PATIENT_DATE_OF_BIRTH, PATIENT_NAME,
                              PATIENT_LASTNAME, PATIENT_HEIGHT, PATIENT_WEIGHT,
                              PATIENT_CELLPHONE, PATIENTS_AGE) 
        VALUES  --variables de entrada
            (GENDER, DATE_OF_BIRTH, NAME, LASTNAME, HEIGHT, WEIGHT, CELLPHONE, AGE);
    END;    --fin sp
/
---se ejecuta el sp seteando valores iniciales
declare
    new_ID NUMBER := 1; --se incializa valor de entrada
begin
    patients_row_create(new_ID, 'm', DATE '2001-06-10', 'William2', 'Barra2', 160, 200, '76531214', 50);
end;
--*****************************



SELECT * FROM PATIENTS;

-- Crear una SP que me permita insertar nuevos registros.
-- El SP debe ser capaz de insertar nuevos registros a la tabla de auditoría de patients.

SELECT USER FROM DUAL;  --obtine nombre del usuario actual
SELECT sys_context('USERENV', 'SERVER_HOST') FROM DUAL; --obtine el servidor en funcion
SELECT to_char(SYSDATE) FROM DUAL;  --se obtine la fecha

CREATE TABLE audit_patients ---se crea tabla de auditoria
(
    USER_NAME           VARCHAR2(20),  
    HOST_NAME           VARCHAR2(20),
    SYS_DATE            VARCHAR2(15),
    PATIENT_NAME        VARCHAR2(25),
    PATIENT_LASTNAME    VARCHAR2(25)
);


CREATE OR REPLACE PROCEDURE insert_data_to_audit_table
    AS                                -- se declaran variables
        user_name_value VARCHAR2(25);
        host_name_value VARCHAR2(25);
        sys_date_value  VARCHAR2(25);
        sql_string      VARCHAR2(800);
    BEGIN
        --se preparan sentencias
        SELECT USER INTO user_name_value FROM DUAL;
        SELECT sys_context('USERENV', 'SERVER_HOST') INTO host_name_value FROM DUAL;
        SELECT to_char(SYSDATE) INTO sys_date_value FROM DUAL;

        --se prepara cadena de insercion del registro
        sql_string := 'INSERT INTO audit_patients(USER_NAME, HOST_NAME, SYS_DATE, PATIENT_NAME, PATIENT_LASTNAME) ';
        sql_string := sql_string || 'VALUES (:1, :2, :3, :4, :5)';

        --  || se usa para concatenar
        --  se valida, si la cadena es correcta

        EXECUTE IMMEDIATE sql_string USING user_name_value, host_name_value, sys_date_value, 'William2', 'Barra2';

    END;    --fin sp
/

begin   ---se manad a ejecutar sp
    insert_data_to_audit_table;
end;

SELECT * FROM audit_patients;