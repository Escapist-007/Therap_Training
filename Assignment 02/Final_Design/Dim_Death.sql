-- Creating Dimension table -- Dimension_Injury

  CREATE
  TABLE DIMENSION_DEATH
  (
    Death_ID    NUMBER ( 10, 0 ) CONSTRAINT DEATH_PK PRIMARY KEY,
    Death_Cause NUMBER ( 10, 0 ),
    Death_Hour  VARCHAR2 ( 255 BYTE ),
    Death_Am_Pm VARCHAR2 ( 255 )
  )
  nologging;

-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE 

  CREATE OR REPLACE PROCEDURE populate_dimension_death
  AS
  BEGIN
    INSERT
    INTO
      dimension_death
      (
        death_id,
        death_cause,
        death_hour,
        death_am_pm
      )
    SELECT
      ID,
      cause,
      time_hour,
      time_am_pm
    FROM
      prod7.ger_event_death -- ei table e grant dite hobe 'prod7' schema theke.
      -- SQL CODE : GRANT SELECT ON GER_EVENT_DEATH TO DWTEST_MONIR;
      COMMIT;
  END populate_dimension_death;

-- Procedure Execution

  EXEC POPULATE_DIMENSION_DEATH;
        
-- CHECKING VALUE IN THE DIMENSION TABLE

  SELECT * FROM DIMENSION_DEATH;
        
