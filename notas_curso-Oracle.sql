--alterar sesion para crear usuarios
ALTER SESSION SET "_ORACLE_SCRIPT"= TRUE

--crear usuarios

CREATE USER test IDENTIFIED BY TEST123;

--asignar roles
GRANT DBA TO test;  orcl2---orclpdb  orcl
L de Oracle Enterprise Manager Database Express: https://localhost:5500/em

user: SYSTEM pass:Oracle123

CREATE USER edteam IDENTIFIED BY Edteam123;

--privilegios dba

GRANT DBA to edteam;

--crear tablas del archivo de recursos del modulo 1

---********************MODULO 2***********
-- funcion. recibe argumentos(entrada o salida) y puede retornar un valor.

---SINGLE ROW FUNCTIONS(FUNCIONES DEL SISTEMA)


CREATE FUNCTION get_current_year--nombre de la funcion
    RETURN DATE IS              ---devolvera un valor de tipo date
        current_year DATE;      ---nombre de la variable y aca se declaran las variables
    BEGIN                       --palabra reservada
        SELECT to_char(sysdate, 'YYYY') 
        INTO current_year    --se asigna el valor obtenido en la variable
        FROM DUAL;              --- funcion dual

        return current_year;    -- retorna el valor respecto a la variable
    END;                        --fin

SELECT get_current_year FROM DUAL;--llamamos l funcion

--FUNCIONES DE CONVERSION CONVERSION DE FORMATOS DE ENTRADA Y SALIDA
--FUNBCIONES DE CONVERSION---DEFINIDAS POR EL USUARIO

---sp con parametros de entrada(in) salida(ount) y entrada-salida(in-out)


---trigger
---se aplican a tablas o vistas
--eventos insert, update o delete
--se invoca nates o despues

--FLUJO DE UN CURSOR

--declaracion        ->varibles
--abrir             ->inicializar
--recuperar datos   ->datos fila a fila recorrido
--cerrar el cursor  ->cierre
--desalojar         ->liberar memoria

