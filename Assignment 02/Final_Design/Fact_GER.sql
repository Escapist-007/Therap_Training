-------------------------------- FACT TABLE ---------------------------------------------------------

 -- Fact Table creation
 
  CREATE TABLE FACT_GER  -- without foreign key
  (
      Injury_Id      NUMBER(10,0),
      Mer_Id         NUMBER(10,0),
      Death_Id       NUMBER(10,0),
      RB_Id          NUMBER(10,0),
      RO_Id          NUMBER(10,0),
      Other_id       NUMBER(10,0),
      
      Time_Id         NUMBER(38), 
      
      Pgm_Id          NUMBER(10),       
      Individual_Id   NUMBER(10),
      Prov_Id         NUMBER(10)
  
      
  )
  NOLOGGING; 
        
        
-- Defining Foreign Key for enabling star tranformation to optimize star queries
-- Star transformation er jonne Foreign key column gulate kno null value rakha jabe na.
-- So, FACT_GER e data insert korar somoi null pele -1 rakhte hbe. Jemon injury_id null hole sekhane -1 rakhbo. But injury_id abar FK so injury_id je value gula nibe segula
-- obossoi Dimension_injury table er injury_id te thaka lagbe. So, Dimension_injury te injury_id -1 insert kore rakhte hobe. 
-- Eivabe 6 ta foreign key r jonne 6 ta dimension table -1 insert kore rakhbo.
        
  CREATE TABLE FACT_GER 
  (
    Injury_Id      NUMBER(10,0) NOT NULL ENABLE,
    Mer_Id         NUMBER(10,0) NOT NULL ENABLE,
    Death_Id       NUMBER(10,0) NOT NULL ENABLE,
    RB_Id          NUMBER(10,0) NOT NULL ENABLE,
    RO_Id          NUMBER(10,0) NOT NULL ENABLE,
    Other_id       NUMBER(10,0) NOT NULL ENABLE,
    
    Time_Id         NUMBER(38) NOT NULL ENABLE, 
    
    Pgm_Id          NUMBER(10),       
    Individual_Id   NUMBER(10),
    Prov_Id         NUMBER(10),
    
    CONSTRAINT FACT_INJURY_FK FOREIGN KEY (Injury_Id)
     REFERENCES DIMENSION_INJURY (INJURY_ID) ENABLE NOVALIDATE, 
     
    CONSTRAINT FACT_MER_FK FOREIGN KEY (Mer_Id)
     REFERENCES DIMENSION_MER (MER_ID) ENABLE NOVALIDATE, 
     
    CONSTRAINT FACT_DEATH_FK FOREIGN KEY (Death_Id)
     REFERENCES DIMENSION_DEATH (DEATH_ID) ENABLE NOVALIDATE, 
    
    CONSTRAINT FACT_RB_FK FOREIGN KEY (RB_Id)
     REFERENCES DIMENSION_RESTRAINT_BEHAVIOR (RESTRAINT_BEHAVIOR_ID) ENABLE NOVALIDATE, 
     
    CONSTRAINT FACT_RO_FK FOREIGN KEY (RO_Id)
     REFERENCES DIMENSION_RESTRAINT_OTHER (RESTRAINT_OTHER_ID) ENABLE NOVALIDATE, 
     
    CONSTRAINT FACT_OTHER_FK FOREIGN KEY (Other_id)
     REFERENCES DIMENSION_OTHER (OTHER_ID) ENABLE NOVALIDATE
        
  )
  NOLOGGING; 
        
        
        
-- PROCEDURE FOR INSERTING DATA INTO FACT TABLE FROM SOURCE TABLE 
  
    
  CREATE OR REPLACE PROCEDURE Populate_Ger_Fact_Final
  AS
  BEGIN
    INSERT
    INTO
      Fact_Ger
      (
        Injury_Id,
        Mer_Id,
        Death_Id,
        Rb_Id,
        Ro_Id,
        Other_Id,
        Time_Id,
        Pgm_Id,
        Individual_Id,
        Prov_Id
      )
    SELECT
      NVL (
      (
        SELECT
          Injury_Id
        FROM
          Dimension_Injury
        WHERE
          Injury_Id = Gei.Id
      )
      , - 1 ),
      NVL (
      (
        SELECT
          Mer_Id
        FROM
          Dimension_Mer
        WHERE
          Mer_Id = Gem.Id
      )
      , - 1 ),
      NVL (
      (
        SELECT
          Death_Id
        FROM
          Dimension_Death
        WHERE
          Death_Id = Ged.Id
      )
      , - 1 ),
      NVL (
      (
        SELECT
          Restraint_Behavior_Id
        FROM
          Dimension_Restraint_Behavior
        WHERE
          Restraint_Behavior_Id = Gerb.Id
      )
      , - 1 ),
      NVL (
      (
        SELECT
          Restraint_Other_Id
        FROM
          Dimension_Restraint_Other
        WHERE
          Restraint_Other_Id = Gero.Id
      )
      , - 1 ),
      NVL (
      (
        SELECT
          Other_Id
        FROM
          Dimension_Other
        WHERE
          Other_Id = Geo.Id
      )
      , - 1 ),
      CASE
        WHEN Gge.Event_Type = 1 --INJURY
        THEN To_Number ( TO_CHAR ( G.Event_Date_Int )
          || Lpad ( TO_CHAR ( NVL ( Injury_Hour, 12 ) ), 2, '0' ) )
        WHEN Gge.Event_Type = 2 -- MER
        THEN To_Number ( TO_CHAR ( G.Event_Date_Int )
          || Lpad ( TO_CHAR ( NVL ( Discovered_Hour, 12 ) ), 2, '0' ) )
        WHEN Gge.Event_Type = 5 -- DEATH
        THEN To_Number ( TO_CHAR ( G.Event_Date_Int )
          || Lpad ( TO_CHAR ( NVL ( Time_Hour, 12 ) ), 2, '0' ) )
        WHEN Gge.Event_Type = 3 -- RESTRAIN BEHAVIOR
        THEN To_Number ( TO_CHAR ( G.Event_Date_Int )
          || Lpad ( TO_CHAR ( NVL ( Gerb.Begin_Time_Hour, 12 ) ), 2, '0' ) )
        WHEN Gge.Event_Type = 4 -- RESTRAIN OTHER
        THEN To_Number ( TO_CHAR ( G.Event_Date_Int )
          || Lpad ( TO_CHAR ( NVL ( Gero.Begin_Time_Hour, 12 ) ), 2, '0' ) )
        WHEN Gge.Event_Type = 9999 --  OTHER
        THEN To_Number ( TO_CHAR ( G.Event_Date_Int )
          || Lpad ( TO_CHAR ( NVL ( Event_Time_Hour, 12 ) ), 2, '0' ) )
      END AS "Time_Id",
      NVL ( G.Pgm_Id,        - 1 ),
      NVL ( G.Individual_Id, - 1 ),
      NVL ( G.Prov_Id,       - 1 )
    FROM
      Prod7.Ger G
    JOIN Prod7.Ger_General_Event Gge
    ON
      G.Id = Gge.Ger_Id
    LEFT JOIN Prod7.Ger_Event_Injury Gei
    ON
      Gge.Id = Gei.Id
    LEFT JOIN Prod7.Ger_Event_Death Ged
    ON
      Gge.Id = Ged.Id
    LEFT JOIN Prod7.Ger_Event_Mer Gem
    ON
      Gge.Id = Gem.Id
    LEFT JOIN Prod7.Ger_Event_Restraint_Behavior Gerb
    ON
      Gge.Id = Gerb.Id
    LEFT JOIN Prod7.Ger_Event_Restraint_Other Gero
    ON
      Gge.Id = Gero.Id
    LEFT JOIN Prod7.Ger_Event_Other Geo
    ON
      Gge.Id = Geo.Id;
    COMMIT;
  END Populate_Ger_Fact_Final;