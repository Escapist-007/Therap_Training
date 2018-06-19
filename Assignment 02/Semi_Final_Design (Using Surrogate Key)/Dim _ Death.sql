-- Schema :  dwtest_monir@bidb


-- Creating Sequence For SURROGATE KEY in Injury_Dimension

      CREATE SEQUENCE Death_Key_Sequence
      INCREMENT BY 1
      START WITH 1
      MAXVALUE 999999999999999
      NOCYCLE 
      CACHE 20;

      

-- Creating Dimension table -- Dimension_Injury

      CREATE TABLE DIMENSION_DEATH
        (
          Death_Key  NUMBER(10,0) CONSTRAINT DEATH_PK PRIMARY KEY,
          Death_ID NUMBER(10,0) NOT NULL ENABLE, 
          Death_Cause NUMBER(10,0),
          Death_Hour  VARCHAR2(255 BYTE),
          Death_Am_Pm  VARCHAR2(255)
        
        )
      nologging;

-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE 

      CREATE OR REPLACE
      PROCEDURE POPULATE_DIMENSION_DEATH AS
      BEGIN
        INSERT INTO DIMENSION_DEATH (Death_Key, Death_ID, Death_Cause, Death_Hour, Death_Am_Pm)
        
        SELECT DEATH_KEY_SEQUENCE.nextval, ID, CAUSE, TIME_HOUR, TIME_AM_PM
        
        FROM prod7.GER_EVENT_DEATH -- ei table e grant dite hobe 'prod7' schema theke. SQL CODE : GRANT SELECT ON GER_EVENT_DEATH TO DWTEST_MONIR;

      Commit;
      END POPULATE_DIMENSION_DEATH;

-- Procedure Execution

      EXEC POPULATE_DIMENSION_DEATH;
        
-- CHECKING VALUE IN THE DIMENSION TABLE

      SELECT * FROM DIMENSION_DEATH;
        
-- INDEX CREATION

      CREATE INDEX Death_id_idx ON DIMENSION_DEATH
        (DEATH_ID
        );

        
        
        
        
        
        
        
        
        
        
        
        