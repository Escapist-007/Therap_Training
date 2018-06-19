-- Schema :  dwtest_monir@bidb


-- Creating Dimension table -- DIMENSION_MER

  CREATE
  TABLE DIMENSION_MER
  (
    Mer_ID            NUMBER ( 10, 0 ) CONSTRAINT MER_PK PRIMARY KEY,
    Error_Type        NUMBER ( 10, 0 ),
    Error_Type_Other  VARCHAR2 ( 255 BYTE ),
    Error_Cause       NUMBER ( 10, 0 ),
    Error_Cause_Other VARCHAR2 ( 255 BYTE )
  )
  nologging;
  
  
        
-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE 

  CREATE OR REPLACE PROCEDURE POPULATE_DIMENSION_MER
  AS
  BEGIN
    INSERT
    INTO
      DIMENSION_MER
      (
        Mer_ID,
        Error_Type,
        Error_Type_Other,
        Error_Cause,
        Error_Cause_Other
      )
    SELECT
      ID,
      ERROR_TYPE,
      ERROR_TYPE_OTHER,
      ERROR_CAUSE,
      ERROR_CAUSE_OTHER
    FROM
      prod7.GER_EVENT_MER COMMIT;
  END POPULATE_DIMENSION_MER;
  
  

-- Procedure Execution

  EXEC POPULATE_DIMENSION_MER;