
-- Schema :  dwtest_monir@bidb

-- Creating Dimension table -- Dimension_Client

  CREATE
    TABLE DIMENSION_PROGRAM
    (
      ID              NUMBER ( 10, 0 ) CONSTRAINT PROGRAM_PK PRIMARY KEY,
      PGM_TYPE_ID     NUMBER ( 10, 0 ),
      PGM_TYPE_NAME   VARCHAR2 ( 50 BYTE ),
      NAME            VARCHAR2 ( 64 CHAR ),
      PROV_ID         NUMBER ( 10, 0 ),
      PROGRAM_CODE    VARCHAR2 ( 32 BYTE ),
      PROGRAM_TABS_ID VARCHAR2 ( 16 BYTE )
    )
    NOLOGGING;
    
    
    
    
  CREATE OR REPLACE PROCEDURE POPULATE_DIMENSION_PROGRAM
  AS
  BEGIN
    INSERT
    INTO
      DIMENSION_PROGRAM
      (
        ID,
        PGM_TYPE_ID,
        PGM_TYPE_NAME,
        NAME,
        PROV_ID,
        PROGRAM_CODE,
        PROGRAM_TABS_ID
      )
    SELECT
      P.ID,
      P.PGM_TYPE_ID,
      PT.NAME,
      P.NAME,
      P.PROV_ID,
      P.PROGRAM_CODE,
      P.PROGRAM_TABS_ID
    FROM
      PROD7.PROGRAM P
    LEFT JOIN PROD7.PROGRAM_TYPE PT
    ON
      P.ID = PT.ID;
    COMMIT;
  END POPULATE_DIMENSION_PROGRAM;
        
    