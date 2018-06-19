-- Schema :  dwtest_monir@bidb

-- Creating Dimension table -- Dimension_Injury

CREATE
  TABLE DIMENSION_INJURY
  (
    Injury_ID                 NUMBER ( 10, 0 ) CONSTRAINT INJURY_PK PRIMARY KEY,
    Injury_Type               NUMBER ( 10, 0 ),
    Injury_Cause              NUMBER ( 10, 0 ),
    Injury_Severity           NUMBER ( 10, 0 ),
    Injury_Hour               VARCHAR2 ( 255 BYTE ),
    Injury_Am_Pm              VARCHAR2 ( 255 ),
    Treatment_Hour            VARCHAR2 ( 255 BYTE ),
    Treatment_Am_Pm           VARCHAR2 ( 255 ),
    Injury_Treatment_Interval VARCHAR2 ( 255 BYTE )
  )
  nologging; -- nologgng is used for faster insertion/deletion as there will be no redo log


-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE 

  CREATE OR REPLACE PROCEDURE POPULATE_DIMENSION_INJURY
  AS
  BEGIN
    INSERT
    INTO
      DIMENSION_INJURY
      (
        Injury_ID,
        Injury_Type,
        Injury_Cause,
        Injury_Severity,
        Injury_Hour,
        Injury_Am_Pm,
        Treatment_Hour,
        Treatment_Am_Pm,
        Injury_Treatment_Interval
      )
    SELECT
      ID,
      INJURY_TYPE,
      INJURY_CAUSE,
      INJURY_SEVERITY,
      INJURY_HOUR,
      INJURY_AM_PM,
      TREATMENT_HOUR,
      TREATMENT_AM_PM,
      ( INJURY_HOUR - TREATMENT_HOUR )
    FROM
      prod7.GER_EVENT_INJURY -- ei table e grant dite hobe 'prod7' schema theke. SQL CODE : GRANT SELECT ON GER_EVENT_INJURY TO DWTEST_MONIR;
      COMMIT;
  END POPULATE_DIMENSION_INJURY;
  
  

-- Procedure Execution

  EXEC POPULATE_DIMENSION_INJURY;
        
-- CHECKING VALUE IN THE DIMENSION TABLE

  SELECT * FROM DIMENSION_INJURY;
        
  SELECT COUNT(*) FROM DIMENSION_INJURY;  -- 10,12,147 ROWS ( 21 JUNE )

-- Updating injury hour and treatment hour based on am/pm and update the injury_treatment_interval

  UPDATE DIMENSION_INJURY
  SET Injury_Hour = Injury_Hour + '12'
  WHERE Injury_Am_Pm = 'pm' AND Injury_Hour <> 12;
  
  UPDATE DIMENSION_INJURY
  SET Treatment_Hour = Treatment_Hour + '12'
  WHERE Treatment_Am_Pm = 'pm' AND Treatment_Hour <> 12;
  
  UPDATE DIMENSION_INJURY
  SET Injury_Treatment_Interval = Treatment_Hour - Injury_Hour;

  UPDATE DIMENSION_INJURY
  SET Injury_Treatment_Interval = 12
  WHERE (Injury_Am_Pm = 'pm' AND Injury_Hour = 12 AND Treatment_Am_Pm = 'am' AND Treatment_Hour = 12 ) OR (Injury_Am_Pm = 'am' AND Injury_Hour = 12 AND Treatment_Am_Pm = 'pm' AND Treatment_Hour = 12 );



        
        
        
        
        
        
        
        
        
        
        
        
