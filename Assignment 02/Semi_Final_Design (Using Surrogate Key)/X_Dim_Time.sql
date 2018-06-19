-- Schema :  dwtest_monir@bidb


-- Creating Sequence For SURROGATE KEY in Time_Dimension

      CREATE SEQUENCE Time_Key_Sequence
      INCREMENT BY 1
      START WITH 1
      MAXVALUE 999999999999999
      NOCYCLE 
      CACHE 20;
      

-- Creating Dimension table -- Dimension_Time

    CREATE TABLE DIMENSION_TIME
      (
        Time_Key  NUMBER(10,0) CONSTRAINT TIME_PK PRIMARY KEY,
        Day NUMBER(10,0),
        Month_name VARCHAR2(255),
        Year NUMBER(10,0)
      );

-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE 

      Create Or Replace Procedure Populate_Time_Dimension As
      Begin
        Insert Into Dimension_Time (Time_Key, Day, Month_Name, Year)
        Select Time_Key_Sequence.Nextval,To_Char(Event_Date, 'dd'),To_Char(Event_Date, 'mm'),To_Char(Event_Date, 'yyyy')
        From Prod7.Ger  
      Commit;
      End Populate_Time_Dimension;

-- Procedure Execution

      EXEC POPULATE_TIME_DIMENSION;
        
-- CHECKING VALUE IN THE DIMENSION TABLE

      SELECT * FROM DIMENSION_TIME;

        
        
        
        
        
        
        
        
        
        
        