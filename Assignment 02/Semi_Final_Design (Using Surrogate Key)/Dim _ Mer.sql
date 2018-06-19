-- Schema :  dwtest_monir@bidb


-- Creating Sequence For SURROGATE KEY in MER_Dimension

    CREATE SEQUENCE MER_KEY_SEQUENCE
    INCREMENT BY 1
    START WITH 1
    MAXVALUE 999999999999999
    NOCYCLE 
    CACHE 20;

-- Creating Dimension table -- DIMENSION_MER

    CREATE TABLE DIMENSION_MER
      (
        Mer_Key  NUMBER(10,0) CONSTRAINT MER_PK PRIMARY KEY,
        Mer_ID NUMBER(10,0) NOT NULL ENABLE, 
        Error_Type NUMBER(10,0),
        Error_Type_Other VARCHAR2(255 BYTE),
        Error_Cause NUMBER(10,0),
        Error_Cause_Other VARCHAR2(255 BYTE)
      )
      nologging;

-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE 

      CREATE OR REPLACE
      PROCEDURE POPULATE_DIMENSION_MER AS
      BEGIN
        INSERT INTO DIMENSION_MER ( Mer_Key, Mer_ID, Error_Type, Error_Type_Other, Error_Cause, Error_Cause_Other )
        SELECT MER_KEY_SEQUENCE.nextval, ID, ERROR_TYPE, ERROR_TYPE_OTHER, ERROR_CAUSE, ERROR_CAUSE_OTHER 
        FROM prod7.GER_EVENT_MER 
      Commit;
      END POPULATE_DIMENSION_MER;

-- Procedure Execution

      EXEC POPULATE_DIMENSION_MER;
        
-- Index creation 

  
      CREATE INDEX Mer_id_idx ON DIMENSION_MER
        (MER_ID
        )
      nologging;
