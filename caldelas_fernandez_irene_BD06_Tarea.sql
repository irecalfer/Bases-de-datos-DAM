--APARTADO 1
-- Al utilizar un cursor variable ya detecta de forma automática cuando alguno de los familias no existe
-- así que solo ha hecho falta implementar el caso de que ambas familias son iguales. Simplemente hemos tenido
-- que hacer un if igualando ambos parametros y de ahi que salte la excepcion. 
create or replace PROCEDURE CambiarAgentesFamilia( id_FamiliaOrigen NUMBER, id_FamiliaDestino NUMBER)
IS 
    --Declaramos las variables
    numeroAgentes NUMBER := 0;
    TYPE cursor_agentes IS REF CURSOR RETURN agentes%ROWTYPE;
    cAgentes cursor_agentes;
    agente cAgentes%ROWTYPE;

BEGIN
        OPEN cAgentes FOR SELECT * FROM agentes WHERE familia = id_FamiliaOrigen;
        LOOP
            FETCH cAgentes INTO agente;
            EXIT WHEN cAgentes%NOTFOUND;
            IF (id_FamiliaOrigen = id_FamiliaDestino) THEN
                RAISE_APPLICATION_ERROR(-20111,'La familia de origen y la del destino es la misma');
            END IF;    
            UPDATE agentes SET familia = id_FamiliaDestino WHERE familia = id_FamiliaOrigen;
            numeroAgentes:= numeroAgentes+1;
    END LOOP;
     dbms_output.put_line('Se han trasladado ' || numeroAgentes || ' agentes de la familia '  || id_FamiliaOrigen || ' a la familia ' || id_FamiliaDestino);
close cAgentes;
END cambiarAgentesFamilia;

-- APARTADO 2

--La longitud de la clave de un agente no puede ser inferior a 6.
--La habilidad de un agente debe estar comprendida entre 0 y 9 (ambos inclusive).
--La categoría de un agente sólo puede ser igual a 0, 1 o 2.
--Si un agente tiene categoría 2 no puede pertenecer a ninguna familia y debe pertenecer a una oficina.  
--Si un agente tiene categoría 1 no puede pertenecer a ninguna oficina y debe pertenecer  a una familia.  
--Todos los agentes deben pertenecer  a una oficina o a una familia pero nunca a ambas a la vez.

CREATE OR REPLACE TRIGGER integridad_agentes
BEFORE INSERT OR UPDATE ON agentes
FOR EACH ROW
BEGIN
    IF length(:new.clave)< 6 THEN
        RAISE_APPLICATION_ERROR(-20201, 'La longitud de clave no puede ser menor a 6');
    ELSIF (:new.habilidad<0 or :new.habilidad >9) THEN
        RAISE_APPLICATION_ERROR(-20202, 'La habilidad de un agente debe de estar comprendida entre 0 y 9');
    ELSIF (:new.categoria != 0 or :new.categoria != 1) OR (:new.categoria != 2) THEN   
        RAISE_APPLICATION_ERROR(-20203, 'La categoría de un agente sólo puede ser igual a 0, 1 o 2');
    ELSIF (:new.categoria = 2 and :new.familia IS NOT NULL) THEN
        RAISE_APPLICATION_ERROR(-20204, 'Un agente de categoria 2 no puede pertener a una familia');
    ELSIF (:new.categoria = 2 and :new.oficina IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20205, 'Un agente de categoría 2 debe pertenecer a una oficina');
    ELSIF (:new.categoria = 1 and :new.familia IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20206, 'Un agente de categoría 1 debe pertener a una familia');
    ELSIF (:new.categoria = 1 and :new.oficina IS NOT NULL) THEN
        RAISE_APPLICATION_ERROR(-20207, 'Un agente de categoria 1 no debe pertener a ninguna oficina');
    ELSIF (:new.familia IS NOT NULL and :new.oficina IS NOT NULL) THEN
        RAISE_APPLICATION_ERROR(-20208, 'Un agente no puede pertener a una familia y a una oficina a la vez');
    ELSIF (:new.familia IS NULL and :new.oficina IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20209, 'Un agente debe pertenecer a una oficina o a una familia');
    END IF;
END;      
    
