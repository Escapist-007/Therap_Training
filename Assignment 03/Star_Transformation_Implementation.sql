--- Enabling star tranformation
--- Creating BI and BJI for the queries below
--- /shared/Demography_for_Oversight_Providers/General/Count by Gender (Child Provider)---


--####################################### Added indexes and constraints ###############################

  ALTER TABLE CLIENT_FACT RENAME CONSTRAINT
  FK_PROV_ID_AGE TO FK_PROV_ID;
  
  
  ALTER TABLE CLIENT_FACT
  ADD CONSTRAINT FK_CLIENT_ID
    FOREIGN KEY (CLIENT_ID)
    REFERENCES DIM_CLIENT(ID);
  
  ALTER TABLE CLIENT_FACT
  ADD CONSTRAINT FK_PGM_ID
    FOREIGN KEY (PGM_ID)
    REFERENCES DIM_PROGRAM(ID);
    
    
  ALTER TABLE CLIENT_FACT
  ADD CONSTRAINT FK_TIME_KEY
    FOREIGN KEY (TIME_KEY)
    REFERENCES DEMOGRAPHIC_TIME(ID);
    
  
  
  CREATE BITMAP INDEX CLIENT_FACT_PROV_ID_BIX
  ON CLIENT_FACT(PROV_ID)
  Local;   -- partitioned table e 'local' index create kora lagbe
  
  CREATE BITMAP INDEX CLIENT_FACT_CLIENT_ID_BIX
  ON CLIENT_FACT(CLIENT_ID)
  Local;
  
  CREATE BITMAP INDEX CLIENT_FACT_PGM_ID_BIX
  ON CLIENT_FACT(PGM_ID)
  Local;
  
  CREATE BITMAP INDEX CLIENT_FACT_TIME_ID_BIX
  ON CLIENT_FACT(TIME_KEY)
  Local;

---------------- INDEX CREATION IN DIMESION TABLES ----
      
  CREATE BITMAP INDEX DT_yr
  ON demographic_time ( year );
  
  CREATE BITMAP INDEX DC_IST
  ON DIM_CLIENT ( INDIVIDUAL_STATUS_TEXT );
  
  CREATE BITMAP INDEX DOP_PC
  ON DIM_OVERSIGHT_PROVIDER ( PROV_CODE );



--#########################################   ###########################################################

 -- Error for having no primary key in 'bridge_cross_provider' and cant use bjx after creating composite primary key 
 -- as both column can't used in a single join condition

  CREATE BITMAP INDEX count_by_gender_bjix ON
  
  CLIENT_FACT (T31.STATUS, T48.PROV_CODE, T106.INDIVIDUAL_STATUS_TEXT, T56.YEAR )
  
  FROM
    DEMOGRAPHIC_TIME T56 /* TIME_DIM */
    ,
    DIM_CLIENT T106
    /* CLIENT_DIM */
    ,
    BRIDGE_CROSS_PROVIDER T110
    /* CROSS_PROVIDER_BRIDGE */
    ,
    DIM_OVERSIGHT_PROVIDER T48
    /* OVERSIGHT_PROVIDER_DIM */
    ,
    DIM_PROVIDER T31
    /* PROVIDER_DIM */
    ,
    DIM_PROGRAM T103
    /* PROGRAM_DIM */
    ,
    CLIENT_FACT T16
    /* CLIENT_FACT_BY_AGE_ALIAS */
  WHERE
    (
          T16.CLIENT_ID               = T106.ID   -- join CLIENT_FACT and DIM_CLIENT
      AND T16.PROV_ID                 = T31.ID    -- join CLIENT_FACT and DIM_PROVIDER
      AND T16.PGM_ID                  = T103.ID   -- join CLIENT_FACT and DIM_PROGRAM
      AND T16.TIME_KEY                = T56.ID    -- join CLIENT_FACT and DEMOGRAPHIC_TIME
      
      AND T31.ID                      = T110.CHILD_PROV_ID
      AND T48.OVERSIGHT_PROV_ID       = T110.PARENT_PROV_ID
      

    )
  local nologging;



--######################### TESTING ######################3333
 
 --- creating bitmap join index 
 
  CREATE BITMAP INDEX count_by_gender_bjix ON CLIENT_FACT (
    T31.STATUS,
    --T48.PROV_CODE,
    T106.INDIVIDUAL_STATUS_TEXT,
    T56.YEAR ) 
    
    FROM DEMOGRAPHIC_TIME T56,
    /* TIME_DIM */
    
    DIM_CLIENT T106,
    /* CLIENT_DIM */
    
    --BRIDGE_CROSS_PROVIDER T110,
    /* CROSS_PROVIDER_BRIDGE */
    
    --DIM_OVERSIGHT_PROVIDER T48,
    /* OVERSIGHT_PROVIDER_DIM */
    
    DIM_PROVIDER T31,
    /* PROVIDER_DIM */
    
     DIM_PROGRAM T103,
    /* PROGRAM_DIM */
    
     CLIENT_FACT T16
    /* CLIENT_FACT_BY_AGE_ALIAS */
    WHERE
    (
      T16.CLIENT_ID    = T106.ID -- join CLIENT_FACT and DIM_CLIENT
      AND T16.PROV_ID  = T31.ID  -- join CLIENT_FACT and DIM_PROVIDER
      AND T16.PGM_ID   = T103.ID -- join CLIENT_FACT and DIM_PROGRAM
      AND T16.TIME_KEY = T56.ID  -- join CLIENT_FACT and DEMOGRAPHIC_TIME
      --        AND T31.ID                      = T110.CHILD_PROV_ID
      --        AND T48.OVERSIGHT_PROV_ID       = T110.PARENT_PROV_ID
    )
    local nologging;



-- Checking if star transformation worked or not ( filter according to bjx)  
-- RESULT : Star transformation worked


  SET ECHO ON
  ALTER SESSION SET star_transformation_enabled=TRUE;
  DELETE FROM plan_table;
  COMMIT;

  EXPLAIN PLAN FOR

  SELECT  /*+ norewrite */
    COUNT ( DISTINCT T16.CLIENT_ID ) AS c1,
    T106.GENDER                      AS c2,
    T106.INDIVIDUAL_STATUS_TEXT      AS c3,
    T103.NAME                        AS c4,
    T103.PROGRAM_TYPE_NAME           AS c5,
    T31.NAME                         AS c6,
    T56.YEAR                         AS c8,
    T31.ID                           AS c9
  FROM
    DEMOGRAPHIC_TIME T56
    /* TIME_DIM */
    ,
    DIM_CLIENT T106
    /* CLIENT_DIM */
    ,
   
    DIM_PROVIDER T31
    /* PROVIDER_DIM */
    ,
    DIM_PROGRAM T103
    /* PROGRAM_DIM */
    ,
    CLIENT_FACT T16
    /* CLIENT_FACT_BY_AGE_ALIAS */
  WHERE
    (
          T16.CLIENT_ID               = T106.ID
      AND T16.PGM_ID                  = T103.ID
      AND T16.PROV_ID                 = T31.ID  
      AND T16.TIME_KEY                = T56.ID
      
      
      AND T106.INDIVIDUAL_STATUS_TEXT = 'Admitted'
      AND
      (
        T56.YEAR IN ( '2016', '2017' )
      )
      AND T31.STATUS                  = 1
      
    )
  GROUP BY
    T31.ID,
    T31.NAME,
    T56.YEAR,
    T103.PROGRAM_TYPE_NAME,
    T103.NAME,
    T106.GENDER,
    T106.INDIVIDUAL_STATUS_TEXT  ;



  SET echo OFF
  SET linesize 160 
  SELECT * FROM TABLE(dbms_xplan.display);



-- checking if star transformation worked or not (less filters than bjx)
-- result : star transformation didn't work


  SET echo ON
  ALTER SESSION SET star_transformation_enabled=TRUE;
  DELETE FROM plan_table;
  COMMIT;

  EXPLAIN PLAN FOR


  SELECT  /*+ norewrite */
    COUNT ( DISTINCT T16.CLIENT_ID ) AS c1,
    T106.GENDER                      AS c2,
    T106.INDIVIDUAL_STATUS_TEXT      AS c3,
    T103.NAME                        AS c4,
    T103.PROGRAM_TYPE_NAME           AS c5,
    T31.NAME                         AS c6,
    T56.YEAR                         AS c8,
    T31.ID                           AS c9
  FROM
    DEMOGRAPHIC_TIME T56
    /* TIME_DIM */
    ,
    DIM_CLIENT T106
    /* CLIENT_DIM */
    ,
   
    DIM_PROVIDER T31
    /* PROVIDER_DIM */
    ,
    DIM_PROGRAM T103
    /* PROGRAM_DIM */
    ,
    CLIENT_FACT T16
    /* CLIENT_FACT_BY_AGE_ALIAS */
  WHERE
    (
          T16.CLIENT_ID               = T106.ID
      AND T16.PGM_ID                  = T103.ID
      AND T16.PROV_ID                 = T31.ID  
      AND T16.TIME_KEY                = T56.ID
      
      AND T31.STATUS                  = 1
      AND T106.INDIVIDUAL_STATUS_TEXT = 'Admitted'
      
    )
  GROUP BY
    T31.ID,
    T31.NAME,
    T56.YEAR,
    T103.PROGRAM_TYPE_NAME,
    T103.NAME,
    T106.GENDER,
    T106.INDIVIDUAL_STATUS_TEXT;
    

  Set Echo Off
  Set Linesize 160 
  Select * From Table(Dbms_Xplan.Display);




-- checking if star transformation worked or not ( extra  filters than bjx)


  SET ECHO ON
  ALTER SESSION SET STAR_TRANSFORMATION_ENABLED=TRUE;
  DELETE FROM PLAN_TABLE;
  COMMIT;


  EXPLAIN PLAN FOR


  SELECT
    COUNT ( DISTINCT T16.CLIENT_ID ) AS c1,
    T106.GENDER                      AS c2,
    T106.INDIVIDUAL_STATUS_TEXT      AS c3,
    T103.NAME                        AS c4,
    T103.PROGRAM_TYPE_NAME           AS c5,
    T31.NAME                         AS c6,
    T48.PROV_CODE                    AS c7,
    T56.YEAR                         AS c8,
    T31.ID                           AS c9
  FROM
    DEMOGRAPHIC_TIME T56
    /* TIME_DIM */
    ,
    DIM_CLIENT T106
    /* CLIENT_DIM */
    ,
    BRIDGE_CROSS_PROVIDER T110
    /* CROSS_PROVIDER_BRIDGE */
    ,
    DIM_OVERSIGHT_PROVIDER T48
    /* OVERSIGHT_PROVIDER_DIM */
    ,
    DIM_PROVIDER T31
    /* PROVIDER_DIM */
    ,
    DIM_PROGRAM T103
    /* PROGRAM_DIM */
    ,
    CLIENT_FACT T16
    /* CLIENT_FACT_BY_AGE_ALIAS */
  WHERE
    (
      '0' NOT IN (
        CASE 'Oversight Provider'
          WHEN 'Linked Provider'
          THEN '1'
          ELSE '0'
        END )
      AND T16.CLIENT_ID               = T106.ID
      AND T16.PROV_ID                 = T31.ID
      AND T16.PGM_ID                  = T103.ID
      AND T16.TIME_KEY                = T56.ID
      
      AND T31.ID                      = T110.CHILD_PROV_ID
      AND T48.OVERSIGHT_PROV_ID       = T110.PARENT_PROV_ID
      
      AND T48.PROV_CODE               = 'DDD-ND'
      AND T106.INDIVIDUAL_STATUS_TEXT = 'Admitted'
      AND
      (
        T56.YEAR IN ( '2016', '2017' )
      )
    )
  GROUP BY
    T31.ID,
    T31.NAME,
    T48.PROV_CODE,
    T56.YEAR,
    T103.PROGRAM_TYPE_NAME,
    T103.NAME,
    T106.GENDER,
    T106.INDIVIDUAL_STATUS_TEXT;


  SET echo OFF
  SET linesize 160 
  SELECT * FROM TABLE(dbms_xplan.display);




---- ################## FAILED --- MERGED TWO COLUMN AND THEN MADE THAT COLUMN THE PK AND THEN TRY TO CREATE THE BITMAP JOIN INDEX ##########################



  ALTER TABLE BRIDGE_CROSS_PROVIDER
  ADD PARENT_CHILD VARCHAR(40); 
  
  UPDATE BRIDGE_CROSS_PROVIDER SET PARENT_CHILD =TO_CHAR( PARENT_PROV_ID ||' '|| CHILD_PROV_ID||' ');
  
  SELECT REGEXP_SUBSTR (PARENT_CHILD, '(\S*)(\s)', 1, 1) as PARENT_PROV_ID
  FROM BRIDGE_CROSS_PROVIDER;
  
  SELECT REGEXP_SUBSTR (PARENT_CHILD, '(\S*)(\s)', 1, 2) as CHILD_PROV_ID
  FROM BRIDGE_CROSS_PROVIDER;



  CREATE BITMAP INDEX new_count_by_gender_bjix ON
  
  CLIENT_FACT (T31.STATUS, T48.PROV_CODE, T106.INDIVIDUAL_STATUS_TEXT, T56.YEAR )
  
  FROM
  DEMOGRAPHIC_TIME T56 /* TIME_DIM */
  ,
  DIM_CLIENT T106
  /* CLIENT_DIM */
  ,
  BRIDGE_CROSS_PROVIDER T110
  /* CROSS_PROVIDER_BRIDGE */
  ,
  DIM_OVERSIGHT_PROVIDER T48
  /* OVERSIGHT_PROVIDER_DIM */
  ,
  DIM_PROVIDER T31
  /* PROVIDER_DIM */
  ,
  DIM_PROGRAM T103
  /* PROGRAM_DIM */
  ,
  CLIENT_FACT T16
  /* CLIENT_FACT_BY_AGE_ALIAS */
  WHERE
  (
        T16.CLIENT_ID               = T106.ID   -- join CLIENT_FACT and DIM_CLIENT
    AND T16.PROV_ID                 = T31.ID    -- join CLIENT_FACT and DIM_PROVIDER
    AND T16.PGM_ID                  = T103.ID   -- join CLIENT_FACT and DIM_PROGRAM
    AND T16.TIME_KEY                = T56.ID    -- join CLIENT_FACT and DEMOGRAPHIC_TIME
    
    AND T31.ID                      =  TO_NUMBER(trim(REGEXP_SUBSTR (T110.PARENT_CHILD, '(\S*)(\s)', 1, 2)) )   -- COMPLEX CLAUSE IS NOR ALLOWED :\ ONLY COLUMN NAME IS ALLOWED
    AND T48.OVERSIGHT_PROV_ID       =  TO_NUMBER(trim(REGEXP_SUBSTR (T110.PARENT_CHILD, '(\S*)(\s)', 1, 1)) )
    
  
  )
  local nologging;
