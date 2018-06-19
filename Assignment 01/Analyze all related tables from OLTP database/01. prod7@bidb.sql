      
           --------------  GER  -----------
      
DESCRIBE GER;

SELECT * FROM GER;

SELECT COUNT(*) FROM GER;   -- 36,63,736 ROWS

SELECT COUNT(ID) FROM GER;  -- 36,63,736 ROWS

SELECT COUNT(DISTINCT ID) FROM GER; --36,63,736 ROWS

 --- There is no NULL id in GER and EVERY ID IS UNIQUE
      
      
       
SELECT
  ID,
  HAS_INJURY,
  HAS_MER,
  HAS_RESTRAINT_BHV,
  HAS_RESTRAINT_OTH,
  HAS_DEATH,
  HAS_OTHER,
  HAS_RESTRAINT_OTH
FROM
  GER
WHERE
  ID = 28933; -- This GER form has all events ( Injury , MER , Death ,Restrain behavior etc)
  
      
-- There are 6 types of events and every event has a unique number. e.g. Injury - 1 , MER - 2 , Restrain behavior - 3 , Restrain other - 4, Death - 5, Other - 9999 .
--  CASE 
--   when GER_GEN_EV.EVENT_TYPE = 1 then 'Injury'
--   when GER_GEN_EV.EVENT_TYPE = 2 then 'Medication Error'
--   when GER_GEN_EV.EVENT_TYPE = 3 then 'Restraint Related to Behavior'
--   when GER_GEN_EV.EVENT_TYPE = 4 then 'Restraint Other'
--   when GER_GEN_EV.EVENT_TYPE = 5 then 'Death'
--   when GER_GEN_EV.EVENT_TYPE = 9999 then 'Other'
      
      
      
          ------------------------     GER_GENEREL_EVENT     ------------------
                                   
      
SELECT COUNT(*) FROM GER_GENERAL_EVENT; -- 40,57,031 ROWS -- For each event in GER from there is a row in this table. so no. of rows in Ger_General_Event >= No. of rows in GER

SELECT COUNT(ID) FROM GER_GENERAL_EVENT; -- 40,57,031 ROWS , SO NO NULL id .

SELECT COUNT(GER_ID) FROM GER_GENERAL_EVENT; -- 40,07,760 ROWS. THERE ARE MANY EVENTS WHICH HAS NO GER_ID. THIS ROWS HAVE NO SIGNIFICANCE.

SELECT COUNT(DISTINCT GER_ID) FROM GER_GENERAL_EVENT; --36,63,369 ROWS . Null ke distinct include kore but count e seta thake na.

SELECT DISTINCT GER_ID FROM GER_GENERAL_EVENT ORDER BY GER_ID DESC;

SELECT
  COUNT ( DISTINCT ger_id ) + COUNT ( DISTINCT
  CASE
    WHEN ger_id IS NULL
    THEN 1
  END ) AS TOTAL
FROM
  ger_general_event; -- 36,63,370 rows
      
      
      
-- Below two queries are same
      
SELECT
  COUNT ( * )
FROM
  GER_GENERAL_EVENT
WHERE
  GER_ID NOT IN
  (
    SELECT
      ID
    FROM
      GER
  ) ;         --- Total 51 rows . 1 row is for null
  
  
SELECT DISTINCT
  ger_id
FROM
  ger_general_event
MINUS
  (
    SELECT
      ID
    FROM
      ger
  ) ;        --- 51 rows(null is included) have GER_ID which are not in GER table
      
      
      
      
          --------------------- JOINING OF GER & GER_GENERAL_EVENT  ----------------------------------
      
      
-- Inner join 

SELECT
  COUNT ( * )
FROM
  GER_GENERAL_EVENT GGE
JOIN GER G
ON
  G.ID = GGE.GER_ID;    --- 40,07,709 rows after joining of 36,63,736 rows from GER and 40,57,031 ROWS from GER_GENERAL_EVENT



-- Full join 

SELECT
  COUNT ( * )
FROM
  GER G
FULL JOIN GER_GENERAL_EVENT GGE
ON
  G.ID = GGE.GER_ID; -- 40,57,448 rows. This is full join .  40,07,709 rows are common.  49,739 rows are either from ger or ger_general_event 


-- Left join 

SELECT
  COUNT ( * )
FROM
  GER G
LEFT JOIN GER_GENERAL_EVENT GGE
ON
  G.ID = GGE.GER_ID; -- 40,08,126 ROWS
  

--Right JOin

SELECT
  COUNT ( * )
FROM
  GER G
RIGHT JOIN GER_GENERAL_EVENT GGE
ON
  G.ID = GGE.GER_ID;  --- 40,57,031 ROWS



          -------------- JOINING ALL TABLES GER, GGE, GEI, GED --------------------


SELECT
  GEI.ID AS INJURY_ID,
  GEM.ID AS MER_ID,
  GED.ID AS DEATH_ID,
  G.PGM_ID,
  G.INDIVIDUAL_ID,
  G.PROV_ID,
  G.EVENT_DATE_INT AS EVENT_DATE_INT
FROM
  prod7.GER G
JOIN prod7.GER_GENERAL_EVENT GGE
ON
  G.ID = GGE.GER_ID
LEFT JOIN GER_EVENT_INJURY GEI
ON
  GGE.ID = GEI.ID
LEFT JOIN GER_EVENT_DEATH GED
ON
  GGE.ID = GED.ID
LEFT JOIN GER_EVENT_MER GEM
ON
  GGE.ID = GEM.ID
WHERE
  G.ID                = 28933
  AND GGE.EVENT_TYPE IN ( 1, 2, 5 ) ;

















