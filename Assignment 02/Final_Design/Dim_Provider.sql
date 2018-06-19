-- Schema :  dwtest_monir@bidb


-- Creating Dimension table -- Dimension_Provider

  CREATE
    TABLE DIMENSION_PROVIDER
    (
      ID     NUMBER ( 10, 0 ) CONSTRAINT PROVIDER_PK PRIMARY KEY,
      CODE   VARCHAR2 ( 16 ),
      NAME   VARCHAR2 ( 64 ),
      CITY   VARCHAR2 ( 30 ),
      STATE  VARCHAR2 ( 2 ),
      COUNTY VARCHAR2 ( 64 ),
      STATUS NUMBER ( 3 )
    )
    NOLOGGING;
    
    
  -- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE
  
  CREATE OR REPLACE PROCEDURE POPULATE_DIMENSION_PROVIDER
  AS
  BEGIN
    INSERT
    INTO
      DIMENSION_PROVIDER
      (
        ID,
        CODE,
        NAME,
        CITY,
        STATE,
        COUNTY,
        STATUS
      )
    SELECT
      ID,
      CODE,
      NAME,
      CITY,
      STATE,
      COUNTY,
      STATUS
    FROM
      PROD7.PROVIDER COMMIT;
  END POPULATE_DIMENSION_PROVIDER;