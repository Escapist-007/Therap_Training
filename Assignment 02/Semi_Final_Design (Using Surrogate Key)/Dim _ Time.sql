-- Schema :  dwtest_monir@bidb


-- Creating Sequence For SURROGATE KEY in Time_Dimension

      CREATE SEQUENCE TIME_KEY_SEQUENCE
      INCREMENT BY 1
      START WITH 1
      MAXVALUE 999999999999999
      NOCYCLE 
      CACHE 20;
      

-- Creating Dimension table -- DIMENSION_TIME

      CREATE TABLE DIMENSION_TIME_V1
        (
          TIME_KEY    NUMBER(38) CONSTRAINT DIMENSION_TIME_PK PRIMARY KEY,
          EVENT_DATE  DATE ,        
          EVENT_HOUR  NUMBER(38), 
          EVENT_DAY   VARCHAR2(12), 
          EVENT_MONTH VARCHAR2(12), 
          EVENT_QUARTER  VARCHAR2(2),  
          EVENT_YEAR     VARCHAR2(4),  
          EVENT_YEAR_INT NUMBER(5),    
          DATE_TIME_INT  NUMBER(38)   
       )
       NOLOGGING;
       
     
-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE 

       CREATE OR REPLACE PROCEDURE POPULATE_DIMENSION_TIME_V1 AS
       BEGIN
          DECLARE   
             MONTH VARCHAR2(12);
             FLAG NUMBER(20);
             DAY VARCHAR2(12); 
             T NUMBER(12); --TRACKING NUMBER OF MONTH
          BEGIN
             FOR Y IN 2000..2020  
             LOOP
                 FOR Q IN 1..4
                 LOOP
                     FOR M IN 1..3
                     LOOP
                        IF Q = 1 AND M = 1 THEN
                           MONTH := 'JAN';
                           FLAG  := 31;
                           T := 1;
                        ELSIF  Q = 1 AND M = 2 THEN
                           MONTH := 'FEB';
                       
                           IF IS_LEAP_YEAR(Y) = TRUE THEN 
                               FLAG  := 29;
                           ELSE
                               FLAG := 28;
                           T := 2;
                           END IF;
                        ELSIF  Q = 1 AND M = 3 THEN
                           MONTH := 'MAR';
                           FLAG  := 31;
                           T := 3;
                        ELSIF  Q = 2 AND M = 1 THEN
                           MONTH := 'APR';
                           FLAG  := 30;
                           T := 4;
                        ELSIF  Q = 2 AND M = 2 THEN
                           MONTH := 'MAY';
                           FLAG  := 31;
                           T := 5;
                        ELSIF  Q = 2 AND M = 3 THEN
                           MONTH := 'JUN';  
                           FLAG  := 30;
                           T := 6;
                        ELSIF Q = 3 AND M = 1 THEN
                           MONTH := 'JUL';
                           FLAG  := 31;
                           T := 7;
                        ELSIF  Q = 3 AND M = 2 THEN
                           MONTH := 'AUG';
                           FLAG  := 31;
                           T := 8;
                        ELSIF  Q = 3 AND M = 3 THEN
                           MONTH := 'SEP';
                           FLAG  := 30;
                           T := 9;
                        ELSIF  Q = 4 AND M = 1 THEN
                           MONTH := 'OCT';
                           FLAG  := 31;
                           T := 10;
                        ELSIF  Q = 4 AND M = 2 THEN
                           MONTH := 'NOV';
                           FLAG  := 30;
                           T := 11;
                        ELSIF  Q = 4 AND M = 3 THEN
                           MONTH := 'DEC';
                           FLAG  := 31;
                           T := 12;
                        ELSE
                           MONTH := 'INVALID';
                        END IF;
                       
                       FOR D IN 1..FLAG
                       LOOP
                         FOR HOUR IN 0..23
                         LOOP  
                         
                          INSERT INTO DIMENSION_TIME 
                          (TIME_KEY,EVENT_HOUR,EVENT_DATE,EVENT_DAY,EVENT_MONTH,EVENT_QUARTER,EVENT_YEAR,EVENT_YEAR_INT,DATE_TIME_INT)
                          VALUES
                          (TIME_KEY_SEQUENCE.nextval, HOUR, TO_DATE(TO_CHAR(D) ||'-'||MONTH||'-'|| TO_CHAR(Y), 'DD-MON-YYYY'),
                          UPPER( SUBSTR(TO_CHAR( TO_DATE(TO_CHAR(D) ||'-'||MONTH||'-'|| TO_CHAR(Y), 'DD-MON-YYYY'),'Day'),1,3) ), MONTH, TO_CHAR(Q), TO_CHAR(Y),Y, 
                          TO_NUMBER( TO_CHAR(Y)|| LPAD(TO_CHAR(T),2,'0')|| LPAD(TO_CHAR(D),2,'0')|| LPAD(TO_CHAR(HOUR),2,'0')) ); 
                          
                          Commit;       
                          
                         END LOOP;
                         
                       END LOOP; 
                       
                     END LOOP;
                 END LOOP;
             END LOOP;
          END;
       END POPULATE_DIMENSION_TIME_V1;

-- Procedure Execution

       EXEC POPULATE_DIMENSION_TIME_V1;
        
-- CHECKING VALUE IN THE DIMENSION TABLE

       SELECT * FROM DIMENSION_TIME
       ORDER BY TIME_KEY;









------------------------------------------      Trying By usibg CONNECT BY clause        ---------------------------------------

  
-- Generating a range of consecutive date values

    SELECT (to_date('01-01-2000','DD-MM-YYYY') + (level-1) ) AS day
    FROM dual
    CONNECT BY LEVEL <= (to_date('31-12-2020','DD-MM-YYYY') - to_date('01-01-2000','DD-MM-YYYY')) + 1;



-- Creating Dimension table -- DIMENSION_TIME_V2

      CREATE TABLE DIMENSION_TIME_V2
            (
              TIME_KEY              NUMBER(38) CONSTRAINT DIMENSION_TIME_PK_V2 PRIMARY KEY,
              EVENT_DATE            DATE ,        
              EVENT_HOUR            NUMBER(38), 
              EVENT_DAY             VARCHAR2(12), 
              EVENT_MONTH           VARCHAR2(12), 
              EVENT_MONTH_NUMBER    VARCHAR2(12),
              EVENT_QUARTER         VARCHAR2(2),  
              EVENT_YEAR            VARCHAR2(4),  
              EVENT_YEAR_INT        NUMBER(5),    
              DATE_TIME_INT         NUMBER(38)   
           )
          NOLOGGING;

-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE 

     create or replace PROCEDURE POPULATE_DIMENSION_TIME_V2
        IS
          START_DATE DATE ;
          END_DATE   DATE;
        BEGIN
          START_DATE := TO_DATE('01/01/2000','DD/MM/YYYY') ;
          END_DATE   := TO_DATE('31/12/2020','DD/MM/YYYY') ;
          
          INSERT
          INTO DIMENSION_TIME_V2
            (
              TIME_KEY,
              EVENT_DATE,
              EVENT_HOUR,
              EVENT_DAY,
              EVENT_MONTH,
              EVENT_MONTH_NUMBER,
              EVENT_QUARTER,
              EVENT_YEAR,
              EVENT_YEAR_INT,
              DATE_TIME_INT
            )
          SELECT 
            TIME_KEY_SEQUENCE.nextval                                                 TIME_KEY,
            START_DATE  + NUMTODSINTERVAL((n-1)/24,'day')                             EVENT_DATE,
            MOD (n -1,24)                                                             EVENT_HOUR,
            
            TO_CHAR( START_DATE + NUMTODSINTERVAL((n-1)/24,'day') ,'DY')              EVENT_DAY,
            UPPER(TO_CHAR( START_DATE + NUMTODSINTERVAL((n-1)/24,'day') ,'Mon'))      EVENT_MONTH,
        
            TO_CHAR(START_DATE  + NUMTODSINTERVAL((n-1)/24,'day') ,'MM')              EVENT_MONTH_NUMBER,
            TO_CHAR(START_DATE  + NUMTODSINTERVAL((n-1)/24,'day') ,'Q')               EVENT_QUARTER,
            
            TO_CHAR(START_DATE  + NUMTODSINTERVAL((n-1)/24,'day') ,'YYYY')            EVENT_YEAR,
            TO_NUMBER( TO_CHAR(START_DATE + NUMTODSINTERVAL((n-1)/24,'day') ,'YYYY')) EVENT_YEAR_INT,
            
            TO_NUMBER ( TO_CHAR( TO_CHAR(START_DATE + NUMTODSINTERVAL((n-1)/24,'day') ,'YYYY'))
            || LPAD(TO_CHAR(TO_CHAR(START_DATE  + NUMTODSINTERVAL((n-1)/24,'day') ,'MM')),2,'0')
            || LPAD(TO_CHAR(TO_CHAR( START_DATE + NUMTODSINTERVAL((n-1)/24,'day') , 'DD')),2,'0')
            || LPAD(TO_CHAR( MOD (n-1,24) ),2,'0')) DATE_TIME_INT
            
          FROM  (SELECT LEVEL n FROM DUAL CONNECT BY LEVEL <= (END_DATE-START_DATE )*24 );
          COMMIT;
        END ;































