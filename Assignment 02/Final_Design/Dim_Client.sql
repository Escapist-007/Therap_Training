
-- Schema :  dwtest_monir@bidb

-- Creating Dimension table -- Dimension_Client

  CREATE TABLE DIMENSION_CLIENT
    (
      ID            NUMBER(10,0) CONSTRAINT CLIENT_PK PRIMARY KEY,
      ID_TYPE       NUMBER(10,0),
      ID_NUMBER     VARCHAR2(64 BYTE), 
      FORM_ID       VARCHAR2(30 BYTE),
      FIRST_NAME    VARCHAR2(25 CHAR), 
      LAST_NAME     VARCHAR2(25 CHAR),
      MIDDLE_NAME   VARCHAR2(25 CHAR),
      GENDER        VARCHAR2(20 BYTE), 
      BIRTH_DATE    DATE, 
      STATUS        NUMBER(4,0),
    
      
      MEDICAID_NUMBER VARCHAR2(128 CHAR),
   
      PROV_ID     NUMBER(10,0),
      CREATED     TIMESTAMP (6), 
      RA_CITY     VARCHAR2(32 BYTE),
      RA_COUNTY   VARCHAR2(50 BYTE), 
      RA_STATE    VARCHAR2(2 CHAR),
      
      BP_CITY     VARCHAR2(32 BYTE), 
      BP_STATE    VARCHAR2(2 CHAR),
      BP_COUNTRY  NUMBER(10,0),
      
      HAIR_COLOR  NUMBER(10,0),
      EYE_COLOR   NUMBER(10,0),
      RELIGION    NUMBER(10,0),
      LANGUAGE    NUMBER(10,0),
      
      HOSPITAL_ID  NUMBER(10,0),
      ETHNICITY    NUMBER(5,0)

    )
    NOLOGGING;




-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE 

  CREATE OR REPLACE PROCEDURE POPULATE_DIMENSION_CLIENT
  AS
  BEGIN
    INSERT
    INTO
      DIMENSION_CLIENT
      (
        ID,
        ID_TYPE,
        ID_NUMBER,
        FORM_ID,
        FIRST_NAME,
        LAST_NAME,
        MIDDLE_NAME,
        GENDER,
        BIRTH_DATE,
        STATUS,
        MEDICAID_NUMBER,
        PROV_ID,
        CREATED,
        RA_CITY,
        RA_COUNTY,
        RA_STATE,
        BP_CITY,
        BP_STATE,
        BP_COUNTRY,
        HAIR_COLOR,
        EYE_COLOR,
        RELIGION,
        LANGUAGE,
        HOSPITAL_ID,
        ETHNICITY
      )
    SELECT
      C.ID,
      C.ID_TYPE,
      C.ID_NUMBER,
      C.FORM_ID,
      C.FIRST_NAME,
      C.LAST_NAME,
      C.MIDDLE_NAME,
      C.GENDER,
      C.BIRTH_DATE,
      C.STATUS,
      C.MEDICAID_NUMBER,
      C.PROV_ID,
      C.CREATED,
      CD.RA_CITY,
      CD.RA_COUNTY,
      CD.RA_STATE,
      CD.BP_CITY,
      CD.BP_STATE,
      CD.BP_COUNTRY,
      CD.HAIR_COLOR,
      CD.EYE_COLOR,
      CD.RELIGION,
      CD.LANGUAGE,
      CD.HOSPITAL_ID,
      CD.ETHNICITY
    FROM
      PROD7.CLIENT C
    JOIN PROD7.CLIENT_DETAIL CD
    ON
      C.ID = CD.ID ;
    COMMIT;
  END POPULATE_DIMENSION_CLIENT;
        

        
        
        
        
        
  EXEC POPULATE_DIMENSION_CLIENT;
        
        
        
        
        
        
        
        
        
        
        
        
        





