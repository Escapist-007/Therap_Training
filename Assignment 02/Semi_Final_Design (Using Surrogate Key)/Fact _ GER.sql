  SELECT * FROM DIMENSION_TIME
  ORDER BY TIME_KEY;
  
  SELECT * FROM DIMENSION_INJURY
  ORDER BY INJURY_CAUSE;
  
  SELECT * FROM prod7.GER;
  SELECT * FROM prod7.GER_GENERAL_EVENT;
  SELECT * FROM prod7.GER_EVENT_DEATH;
  
  DESCRIBE DIMENSION_DEATH;
  
  
  SELECT to_char( SYSDATE, 'DD/MM/YYYY HH24:MI:SS' ) AS CURRENT_DATE
  FROM DUAL;



-------------------------------- FACT TABLE ---------------------------------------------------------

 -- Fact Table creation
 
  CREATE TABLE FACT_GER
  (
      Injury_Key      NUMBER(10,0),
      Mer_Key         NUMBER(10,0),
      Death_Key       NUMBER(10,0),
      
      Time_Key        NUMBER(38),      
      Pgm_Id          NUMBER(10),       
      Individual_Id   NUMBER(10),
      Prov_Id         NUMBER(10)
    
      
  --          CONSTRAINT FACT_INJURY FOREIGN KEY(Injury_Key) REFERENCES DIMENSION_INJURY (INJURY_KEY),
  --          CONSTRAINT FACT_MER    FOREIGN KEY(Mer_Key)    REFERENCES DIMENSION_MER (MER_KEY),
  --          CONSTRAINT FACT_DEATH  FOREIGN KEY(Death_Key)  REFERENCES DIMENSION_DEATH (DEATH_KEY),          
  --          CONSTRAINT FACT_TIME   FOREIGN KEY(Time_Key)   REFERENCES DIMENSION_TIME_V1 (TIME_KEY)
     
  )
  NOLOGGING; 
    
  
  -- PROCEDURE FOR INSERTING DATA INTO FACT TABLE FROM SOURCE TABLE 
  
     -- OLD query -- WRONG
     
 CREATE OR REPLACE PROCEDURE POPULATE_GER_FACT
AS
BEGIN
  INSERT
  INTO
    FACT_GER
    (
      Injury_Key,
      Mer_Key,
      Death_Key,
      Time_Key,
      Pgm_Id,
      Individual_Id,
      Prov_Id
    )
  SELECT
    DI.INJURY_KEY,
    '',
    '',
    DT.TIME_KEY,
    G.PGM_ID,
    G.INDIVIDUAL_ID,
    G.PROV_ID
  FROM
    prod7.GER G
  JOIN prod7.GER_GENERAL_EVENT GGE
  ON
    G.ID = GGE.GER_ID
  JOIN DIMENSION_INJURY DI
  ON
    DI.INJURY_ID = GGE.ID
  JOIN DIMENSION_TIME DT
  ON
    DT.DATE_TIME_INT = ( TO_NUMBER ( G.EVENT_DATE_INT
    || EXTRACT ( HOUR FROM G.EVENT_DATE ) ) )
  WHERE
    GGE.EVENT_TYPE = 1;
  COMMIT;
END POPULATE_GER_FACT;
  
  
  -- WRONG --
  
CREATE OR REPLACE PROCEDURE POPULATE_GER_FACT
AS
BEGIN
  INSERT
  INTO FACT_GER
    (
      Injury_Key,
      Mer_Key,
      Death_Key,
      Time_Key,
      Pgm_Id,
      Individual_Id,
      Prov_Id
    )
  SELECT DI.INJURY_KEY,
    '',
    '',
    DT.TIME_KEY,
    G.PGM_ID,
    G.INDIVIDUAL_ID,
    G.PROV_ID
  FROM prod7.GER G
  JOIN prod7.GER_GENERAL_EVENT GGE
  ON G.ID = GGE.GER_ID
  JOIN prod7.GER_EVENT_INJURY GEI
  ON GEI.ID = GGE.ID
  JOIN DIMENSION_INJURY DI
  ON DI.INJURY_ID = GGE.ID
  JOIN DIMENSION_TIME DT
  ON DT.DATE_TIME_INT = TO_NUMBER( TO_CHAR(G.EVENT_DATE_INT)
    || TO_CHAR(GEI.INJURY_HOUR ) );
  --WHERE GGE.EVENT_TYPE = 1;
  
  COMMIT;
END POPULATE_GER_FACT;
  
  
  
  
  
--------------------------------------------------------------------- CORRECT QUERY ---------------------------------------------------------------------------
  
  
  --- VERSION 01 -- ( using cursor ) 
  
  CREATE OR REPLACE PROCEDURE POPULATE_GER_FACT
  AS
    TK NUMBER(10,0);
    IK NUMBER(10,0);
    MK NUMBER(10,0);
    DK NUMBER(10,0);
    HR VARCHAR2(255 BYTE);
    --EE NUMBER(10);
    
  BEGIN
  
    FOR CUR_REC IN
      ( SELECT GGE.ID ,
               G.PGM_ID ,
               G.INDIVIDUAL_ID ,
               G.PROV_ID ,
               GGE.EVENT_TYPE ,
               G.EVENT_DATE_INT
       FROM PROD7.GER G
       JOIN PROD7.GER_GENERAL_EVENT GGE
        ON G.ID  = GGE.GER_ID
      WHERE  GGE.EVENT_TYPE IN (1,2,5) --AND ( TO_NUMBER(SUBSTR(TO_CHAR(G.EVENT_DATE_INT),1,4)) < 2000 or TO_NUMBER(SUBSTR(TO_CHAR(G.EVENT_DATE_INT),1,4)) > 2020 )
      )
    LOOP
      CASE
      WHEN CUR_REC.EVENT_TYPE = 1 THEN --INJURy
      
        SELECT INJURY_KEY
        INTO IK
        FROM DIMENSION_INJURY
        WHERE INJURY_ID = CUR_REC.ID;
        
        SELECT INJURY_HOUR INTO HR FROM PROD7.GER_EVENT_INJURY WHERE ID = CUR_REC.ID;
        DBMS_OUTPUT.PUT_LINE(CUR_REC.ID);
        MK := NULL;
        DK := NULL;
        
        --EE := cur_rec.EVENT_DATE_INT;
        SELECT TIME_KEY
        INTO TK
        FROM DIMENSION_TIME
        WHERE DATE_TIME_INT = TO_NUMBER( TO_CHAR(CUR_REC.EVENT_DATE_INT) || LPAD(TO_CHAR(NVL(HR,12)),2,'0') );
          
      WHEN CUR_REC.EVENT_TYPE = 2 THEN -- MER
      
        SELECT MER_KEY INTO MK FROM DIMENSION_MER WHERE MER_ID = CUR_REC.ID;
        SELECT DISCOVERED_HOUR INTO HR FROM PROD7.GER_EVENT_MER WHERE ID = CUR_REC.ID;
        IK := NULL;
        DK := NULL;
        
        SELECT TIME_KEY
        INTO TK
        FROM DIMENSION_TIME
        WHERE DATE_TIME_INT = TO_NUMBER( TO_CHAR(CUR_REC.EVENT_DATE_INT) || LPAD(TO_CHAR(NVL(HR,12)),2,'0') );
          
          
      WHEN CUR_REC.EVENT_TYPE = 5 THEN --DEATH
      
        SELECT DEATH_KEY,
          DEATH_HOUR
        INTO DK,
          HR
        FROM DIMENSION_DEATH
        WHERE DEATH_ID = CUR_REC.ID;
        IK            := NULL;
        MK            := NULL;
        
        SELECT TIME_KEY
        INTO TK
        FROM DIMENSION_TIME
        WHERE DATE_TIME_INT = TO_NUMBER( TO_CHAR(CUR_REC.EVENT_DATE_INT) || LPAD(TO_CHAR(NVL(HR,12)),2,'0') );
      ELSE
         DBMS_OUTPUT.PUT_LINE('-1');
      END CASE;
      
      INSERT
      INTO FACT_GER
        (
          INJURY_KEY,
          MER_KEY,
          DEATH_KEY,
          TIME_KEY,
          PGM_ID,
          INDIVIDUAL_ID,
          PROV_ID
        )
        VALUES
        (
          IK,
          MK,
          DK,
          TK ,
          CUR_REC.PGM_ID,
          CUR_REC. INDIVIDUAL_ID,
          CUR_REC.PROV_ID
        );
      COMMIT;
    END LOOP;
    
  EXCEPTION
  
        WHEN NO_DATA_FOUND THEN
        --DBMS_OUTPUT.PUT_LINE('No DATA found  ' || TO_NUMBER( TO_CHAR(EE) || LPAD(TO_CHAR(NVL(HR,12)),2,'0') ) ) ;
          DBMS_OUTPUT.PUT_LINE('DK--' || NVL(DK,10) || ' ' || 'IK - ' || NVL(IK,11) || ' ' || 'MK - ' || NVL(MK,12) || ' ' || 'TK - ' || NVL(TK,13) || ' HR --' || HR);
          
        WHEN TOO_MANY_ROWS THEN
          DBMS_OUTPUT.PUT_LINE('TOO MANY DATA FAOUND.') ;
          DBMS_OUTPUT.PUT_LINE('DK--' || NVL(DK,10) || ' ' || 'IK - ' || NVL(IK,11) || ' ' || 'MK - ' || NVL(MK,12) || ' ' || 'TK - ' || NVL(TK,13) || ' HR --' || HR);
          
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Some unknown error occurred.') ;
          
  END POPULATE_GER_FACT;
  
  
  -- Version 02 ( Without cursor But there is a problem when same injury id will be multiple times having different injury_key  )---
  -- "Star Transformation' will not work if there is null value. So, we have to replace null values by -1 for number and 'N/A' for string
  
  CREATE OR REPLACE PROCEDURE populate_ger_fact_final
  AS
  BEGIN
  INSERT
  INTO fact_ger
    (
      injury_key,
      mer_key,
      death_key,
      time_key,
      pgm_id,
      individual_id,
      prov_id
    )
  SELECT
    (SELECT nvl(injury_key,-1) FROM dimension_injury WHERE injury_id = gei.ID),
    (SELECT nvl(mer_key,-1)    FROM dimension_mer WHERE mer_id = gem.ID),
    (SELECT nvl(death_key,-1)  FROM dimension_death WHERE death_id = ged.ID),
    CASE
      WHEN gge.event_type = 1
      THEN
        ( SELECT nvl(time_key,-1)
          FROM dimension_time
          WHERE date_time_int = to_number( to_char(g.event_date_int) || lpad(to_char(nvl(injury_hour,12)),2,'0') )
        )
      WHEN gge.event_type = 2
      THEN
        ( SELECT nvl(time_key,-1)
          FROM dimension_time
          WHERE date_time_int = to_number( to_char(g.event_date_int) || lpad(to_char(nvl(discovered_hour,12)),2,'0') )
        )
      WHEN gge.event_type = 5
      THEN
        ( SELECT nvl(time_key,-1)
          FROM dimension_time
          WHERE date_time_int = to_number( to_char(g.event_date_int) || lpad(to_char(nvl(time_hour,12)),2,'0') )
        )
    END AS "TIME_KEY",
    nvl(g.pgm_id,-1),
    nvl(g.individual_id,-1) ,
    nvl(g.prov_id,-1)
  
  FROM prod7.ger g
  JOIN prod7.ger_general_event gge
  ON g.ID = gge.ger_id
  LEFT JOIN prod7.ger_event_injury gei
  ON gge.ID = gei.ID
  LEFT JOIN prod7.ger_event_death ged
  ON gge.ID = ged.ID
  LEFT JOIN prod7.ger_event_mer gem
  ON gge.ID = gem.ID ;
  COMMIT;
  END populate_ger_fact_final;
  
  
  
  -- Procedure Execution
  
  EXEC POPULATE_GER_FACT_FINAL;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

