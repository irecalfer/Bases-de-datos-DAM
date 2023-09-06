--APARTADO 1
-- Crea el tipo de objetos "Personal"
CREATE OR REPLACE TYPE Personal AS OBJECT
(
    codigo INTEGER,
    dni VARCHAR2(10),
    nombre VARCHAR2(30),
    apellidos VARCHAR2(30),
    sexo VARCHAR(1),
    fecha_nac DATE
) NOT FINAL;

-- Crea, como tipo heredado de "Personal", el tipo de objeto "Responsable" 
CREATE OR REPLACE TYPE Responsable UNDER Personal
(
    tipo CHAR,
    antiguedad INTEGER,
    /*Declaracion de los métodos para los apartados más adelante*/
    CONSTRUCTOR FUNCTION Responsable(codigo INTEGER, nombre VARCHAR2, apellido1 VARCHAR2, apellido2 VARCHAR2, tipo CHAR) RETURN SELF AS RESULT,
    MEMBER FUNCTION getNombreCompleto RETURN VARCHAR2
    
);

-- Crea el tipo de objeto "Zonas"
CREATE OR REPLACE TYPE Zonas AS OBJECT
(
        codigo INTEGER,
        nombre VARCHAR2(20),
        refRespon REF Responsable,
        codigoPostal CHAR(5),
        /*Añadimos el metodo map al principio porque posteriormente me da problemas*/
        MAP MEMBER FUNCTION ordenarZonas RETURN VARCHAR2
)NOT FINAL;

-- Crea, como tipo heredado de "Personal", el tipo de objeto "Comercial"
CREATE OR REPLACE TYPE Comercial UNDER Personal
(
    zonaComercial Zonas
);

--APARTADO 2
-- Crea un método constructor para el tipo de objetos "Responsable", 
-- en el que se indiquen como parámetros código, nombre, primer apellido, 
-- segundo apellido y tipo. Este método debe asignar al atributo apellidos los 
-- datos de primer apellido y segundo apellido que se han pasado como parámetros, 
-- uniéndolos con un espacio entre ellos.

-- Cuerpo del tipo de objeto Responsable    
CREATE OR REPLACE TYPE BODY Responsable AS
    /*Implementacion del método constructor*/
    CONSTRUCTOR FUNCTION Responsable(codigo INTEGER, nombre VARCHAR2, apellido1 VARCHAR2, apellido2 VARCHAR2, tipo CHAR)
        RETURN SELF AS RESULT
    IS
        BEGIN
            SELF.codigo := codigo;
            SELF.nombre := nombre;
            SELF.apellidos := (apellido1 || ' ' || apellido2);
            SELF.codigo := codigo;
            RETURN;
        END;
END;   

-- APARTADO 3
--Crea un método getNombreCompleto para el tipo de objetos Responsable que permita 
--obtener su nombre completo con el formato apellidos nombre


CREATE OR REPLACE TYPE BODY Responsable AS
    /*Implementacion del método constructor*/
    CONSTRUCTOR FUNCTION Responsable(codigo INTEGER, nombre VARCHAR2, apellido1 VARCHAR2, apellido2 VARCHAR2, tipo CHAR)
        RETURN SELF AS RESULT
    IS
        BEGIN
            SELF.codigo := codigo;
            SELF.nombre := nombre;
            SELF.apellidos := CONCAT(apellido1, apellido2);
            SELF.tipo := tipo;
            RETURN;
        END;
        
    /*Método get*/
    MEMBER FUNCTION getNombreCompleto RETURN VARCHAR2 IS
    BEGIN
        RETURN (apellidos || ' ' || nombre);
    END getNombreCompleto;
END;   

-- APARTADO 4
--Crea un tabla TablaResponsables de objetos  Responsable. Inserta en dicha tabla 
-- dos objetos  Responsable.

CREATE TABLE TablaResponsables OF Responsable;

--Hacemos la inserccion
INSERT INTO TablaResponsables VALUES(Responsable(5, null, 'ELENA', 'POSTA LLANOS', 'F', '31/03/1975', 'N', 4));

-- El segundo objeto "Responsable" debes crearlo usando el método constructor que has realizado anteriormente. 
DECLARE
    /*Declaracion de una variable de tipo Responsable*/
    r1 Responsable;
BEGIN
    /*Creación de un objeto Responsable*/
    r1 := NEW Responsable(6, 'JAVIER', 'JARAMILLO', 'HERNANDEZ', 'C');
    INSERT INTO tablaresponsables VALUES (r1);
END;    

-- APARTADO 5
-- Crea una colección VARRAY llamada ListaZonas en la que se puedan almacenar hasta 10 objetos Zonas. 
-- Guarda en una instancia listaZonas1 de dicha lista, dos Zonas

DECLARE
    TYPE ListaZonas IS VARRAY(10) OF Zonas;
    listaZonas1 ListaZonas;
    zona1 Zonas;
    zona2 Zonas;
    refResponsable REF Responsable;
BEGIN
    /*Guardamos en una instancia liztaZonas1 dos zonas*/
    SELECT REF(p) into refResponsable FROM TablaResponsables p WHERE  codigo = 5;
    zona1 := Zonas(1, 'zona 1', refresponsable, '06834');
    SELECT REF(p) into refResponsable FROM TablaResponsables p WHERE dni = '51083099F';
    zona2 := Zonas(2, 'zona 2', refResponsable, '28003');
    listaZonas1 := ListaZonas(zona1, zona2);
END;

-- APARTADO 6
-- Crea una tabla TablaComerciales de objetos Comercial. 
-- Hacemos el procedimiento anterior añadiendo los comerciales.
CREATE TABLE TablaComerciales OF Comercial;
DECLARE
    -- Antiguo
    TYPE ListaZonas IS VARRAY(10) OF Zonas;
    listaZonas1 ListaZonas;
    zona1 Zonas;
    zona2 Zonas;
    refResponsable REF Responsable;
    unComercial Comercial;
BEGIN
    -- Antiguo
    SELECT REF(p) into refResponsable FROM TablaResponsables p WHERE  codigo = 5;
    zona1 := Zonas(1, 'zona 1', refresponsable, '06834');
    --SELECT REF(p) into refresponsable FROM tablaresponsables p WHERE dni = '51083099F';
    zona2 := Zonas(2, 'zona 2', refResponsable, '28003');
    listaZonas1 := ListaZonas(zona1, zona2);
    
    -- Nuevo
    INSERT INTO TablaComerciales VALUES(Comercial(100,'23401092Z', 'MARCOS', 'SUAREZ LOPEZ', 'M', '30/3/1990',zona1));
    INSERT INTO TablaComerciales VALUES(Comercial(102, '6932288V', 'ANASTASIA', 'GOMES PEREZ', 'F', '28/11/1984', listaZonas1(2)));
    
    -- APARTADO 7
    -- Obtener, de la tabla TablaComerciales, el Comercial que tiene el código 100, 
    -- asignándoselo a una variable unComercial
    SELECT VALUE(c) INTO unComercial FROM TablaComerciales c WHERE c.codigo = 100;
    
    -- APARTADO 8
    -- Modifica el código del Comercial guardado en esa variable unComercial asignando 
    -- el valor 101, y su zona debe ser la segunda que se había creado anteriormente. 
    --Inserta ese Comercial en la tabla TablaComerciales 
    
    /*Seleccionamos el comercial que tiene el codigo 100 que es el que hemos 
    utilizado en el apartado anterior*/
    SELECT VALUE(c) INTO unComercial FROM TablaComerciales c WHERE c.codigo = 100;
    /*Modificamos el codigo del comercial*/
    unComercial.codigo := 101;
    /*Modificamos la zona a la segunda*/
    unComercial.ZonaComercial := zona2;
    /*Lo insertamos en la tabla*/
    INSERT INTO TablaComerciales VALUES (unComercial);
END;   

 -- APARTADO 9
 -- Crea un método MAP ordenarZonas para el tipo Zonas. Este método debe retornar 
 -- el nombre completo del Responsable al que hace referencia cada zona. Para obtener 
 -- el nombre debes utilizar el método getNombreCompleto que se ha creado anteriormente
 
 -- Deberiamos borrar el objeto Zonas para poder añadirle el MAP ya que no se puede borrar
 -- Ni sustituir un tipo que tenga dependientes de tipo o tabla


--Creamos el metodo MAP y devolvemos el nombre haciendo una llamada a la funcion
CREATE OR REPLACE TYPE BODY Zonas AS
    MAP MEMBER FUNCTION ordenarZonas RETURN VARCHAR2 IS
        referencia Responsable;
    BEGIN
        SELECT DEREF(refRespon) INTO referencia FROM Dual;
        RETURN referencia.getNombreCompleto();
    END ordenarZonas;
END;    

-- APARTADO 10
--Realiza una consulta de la tabla TablaComerciales ordenada por zonaComercial 
-- para comprobar el funcionamiento del método MAP.  
SELECT * FROM TablaComerciales ORDER BY zonacomercial;