-- Schema :  dwtest_monir@bidb

-- Creating Dimension table -- Dimension_Restrain_Other

  CREATE TABLE DIMENSION_RESTRAINT_OTHER
    (
      RESTRAINT_OTHER_ID NUMBER(10,0) CONSTRAINT RESTRAINT_OTHER_PK PRIMARY KEY, 
      END_DATE TIMESTAMP (6),
      RESTRAINT_TYPE NUMBER(10,0),
      
      BEGIN_TIME_HOUR VARCHAR2(255 BYTE), 
      BEGIN_TIME_MIN VARCHAR2(255 BYTE), 
      BEGIN_TIME_AM_PM VARCHAR2(255 BYTE), 
      
      END_TIME_HOUR VARCHAR2(255 BYTE), 
      END_TIME_MIN VARCHAR2(255 BYTE), 
      END_TIME_AM_PM VARCHAR2(255 BYTE)
    
    )
    NOLOGGING;
    
        
-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE 

  CREATE OR REPLACE
  PROCEDURE POPULATE_DIM_RES_OTHER AS
  BEGIN
    INSERT INTO DIMENSION_RESTRAINT_OTHER (RESTRAINT_OTHER_ID, END_DATE, RESTRAINT_TYPE, BEGIN_TIME_HOUR, BEGIN_TIME_MIN, BEGIN_TIME_AM_PM, END_TIME_HOUR, END_TIME_MIN, END_TIME_AM_PM )
    SELECT  ID, END_DATE, RESTRAINT_TYPE, BEGIN_TIME_HOUR, BEGIN_TIME_MIN, BEGIN_TIME_AM_PM, END_TIME_HOUR, END_TIME_MIN, END_TIME_AM_PM
    FROM PROD7.GER_EVENT_RESTRAINT_OTHER 

  Commit;
  END POPULATE_DIM_RES_OTHER;
  
  

-- Procedure Execution

  EXEC POPULATE_DIM_RES_OTHER;