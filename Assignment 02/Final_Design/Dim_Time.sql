-- Schema :  dwtest_monir@- Creating Dimension table -- DIMENSION_TIME


-- Creating Dimension table -- DIMENSION_TIME

    CREATE TABLE DIMENSION_TIME
        (
          EVENT_DATE            DATE ,        
          EVENT_HOUR            NUMBER(38), 
          EVENT_DAY             VARCHAR2(12), 
          EVENT_MONTH           VARCHAR2(12), 
          EVENT_MONTH_NUMBER    VARCHAR2(12),
          EVENT_QUARTER         VARCHAR2(2),  
          EVENT_YEAR            VARCHAR2(4),  
          EVENT_YEAR_INT        NUMBER(5),    
          DATE_TIME_INT         NUMBER(38) CONSTRAINT TIME_PK PRIMARY KEY 
          
       )
    NOLOGGING;


-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE 
                       
                       

   CREATE OR REPLACE PROCEDURE populate_dimension_time
      IS
        start_date DATE ;
        end_date   DATE;
      BEGIN
        start_date := to_date('01/01/2000','DD/MM/YYYY') ;
        end_date   := to_date('31/12/2020','DD/MM/YYYY') ;
        
        INSERT
        INTO dimension_time
          (
            event_date,
            event_hour,
            event_day,
            event_month,
            event_month_number,
            event_quarter,
            event_year,
            event_year_int,
            date_time_int
          )
        SELECT 
                                                    
          start_date  + numtodsinterval((n-1)/24,'day')                             event_date,
          mod (n -1,24)                                                             event_hour,
          
          to_char( start_date + numtodsinterval((n-1)/24,'day') ,'DY')              event_day,
          upper(to_char( start_date + numtodsinterval((n-1)/24,'day') ,'Mon'))      event_month,
      
          to_char(start_date  + numtodsinterval((n-1)/24,'day') ,'MM')              event_month_number,
          to_char(start_date  + numtodsinterval((n-1)/24,'day') ,'Q')               event_quarter,
          
          to_char(start_date  + numtodsinterval((n-1)/24,'day') ,'YYYY')            event_year,
          to_number( to_char(start_date + numtodsinterval((n-1)/24,'day') ,'YYYY')) event_year_int,
          
          to_number ( to_char( to_char(start_date + numtodsinterval((n-1)/24,'day') ,'YYYY'))
          || lpad(to_char(to_char(start_date  + numtodsinterval((n-1)/24,'day') ,'MM')),2,'0')
          || lpad(to_char(to_char( start_date + numtodsinterval((n-1)/24,'day') , 'DD')),2,'0')
          || lpad(to_char( mod (n-1,24) ),2,'0')) date_time_int
          
        FROM  (SELECT LEVEL n FROM dual CONNECT BY LEVEL <= (end_date-start_date + 1 ) * 24 );
        COMMIT;
      END ;

-- Procedure Execution

     EXEC POPULATE_DIMENSION_TIME;








