SELECT * FROM ger;

describe ger;



SELECT
  g.ID         AS gerid,
  gge.ID       AS injuryid,
  di.injury_id AS diminjuryid,
  gge.event_type
FROM
  ger_general_event gge
JOIN ger g
ON
  g.ID = gge.ger_id
JOIN dwtest_monir.dimension_injury di
ON
  di.injury_id = gge.ID
WHERE
  gge.event_type = 1;



SELECT
  di.injury_key,
  g.prov_id,
  g.individual_id,
  g.pgm_id
FROM
  ger g
JOIN ger_general_event gge
ON
  g.ID = gge.ger_id
JOIN dwtest_monir.dimension_injury di
ON
  di.injury_id = gge.ID
WHERE
  g.has_injury = 1;




SELECT
  count ( * )
FROM
  ger g
JOIN ger_general_event gge
ON
  g.ID = gge.ger_id
  --JOIN dwtest_monir.DIMENSION_INJURY DI
  --ON DI.INJURY_ID = GGE.ID
WHERE
  g.has_injury = 1;


SELECT count(*)
FROM ger
WHERE has_injury = 1;


SELECT *
FROM ger
WHERE has_injury = 1;


SELECT count(injury_id)
FROM dwtest_monir.dimension_injury;


SELECT
  g.ID,
  count ( * ) AS count
FROM
  (
    SELECT
      *
    FROM
      ger
    WHERE
      has_injury = 1
  )
  g
JOIN ger_general_event gge
ON
  g.ID = gge.ger_id
GROUP BY
  g.ID
HAVING
  count ( * ) > 5;
   
   
   
   
SELECT
  count ( * )
FROM
  ger g
JOIN ger_general_event gge
ON
  g.ID = gge.ger_id
JOIN dwtest_monir.dimension_injury di
ON
  di.injury_id = gge.ID
WHERE
  gge.event_type = 1;


  
  
SELECT * FROM ger_general_event;
  
  
  
  
SELECT
  di.injury_key,
  g.pgm_id,
  g.individual_id,
  g.prov_id
FROM
  prod7.ger g
JOIN prod7.ger_general_event gge
ON
  g.ID = gge.ger_id
JOIN dwtest_monir.dimension_injury di
ON
  di.injury_id = gge.ID
JOIN dwtest_monir.dimension_time dt
ON
  (
    dt.event_date     = CAST ( g.event_date AS DATE )
    AND dt.event_hour = EXTRACT ( HOUR FROM g.event_date )
  )
WHERE
  gge.event_type = 1;



  
  
SELECT
  count ( * )
FROM
  prod7.ger g
JOIN prod7.ger_general_event gge
ON
  g.ID = gge.ger_id
JOIN dwtest_monir.dimension_injury di
ON
  di.injury_id = gge.ID
JOIN dwtest_monir.dimension_time dt
ON
  (
    dt.event_date     = CAST ( g.event_date AS DATE )
    AND dt.event_hour = EXTRACT ( HOUR FROM g.event_date )
  )
WHERE
  gge.event_type = 1;
  
  
SELECT
  to_number ( to_char ( event_date_int )
  || to_char ( EXTRACT ( HOUR FROM event_date ) ) )
FROM
  ger;
  
  

SELECT
  to_char ( concat ( to_char ( event_date_int ), to_char ( EXTRACT ( HOUR FROM
  event_date ) ) ) ) AS datee
FROM
  ger;


 