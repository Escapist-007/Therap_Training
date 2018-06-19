-- Schema :  dwtest_monir@bidb


-- Creating Dimension table -- Dimension_Oversight
 CREATE
  TABLE DIMENSION_OVERSIGHT
  (
    OVERSIGHT_PROV_ID NUMBER ( 10, 0 ) CONSTRAINT OVERSIGHT_PROVIDER_PK PRIMARY
    KEY,
    PROV_CODE VARCHAR2 ( 16 BYTE ),
    PROV_NAME VARCHAR2 ( 64 BYTE ),
    TYPE      VARCHAR2 ( 20 BYTE )
  )
  NOLOGGING;
        

-- PROCEDURE FOR INSERTING DATA INTO DIMENSION TABLE FROM SOURCE TABLE 

  CREATE OR REPLACE PROCEDURE populate_dimension_oversight
  AS
  BEGIN
    INSERT
    INTO
      dimension_oversight
      (
        oversight_prov_id,
        prov_code,
        prov_name,
        TYPE
      )
    SELECT
      t.parent_prov_id,
      p.code,
      p.NAME,
      p.TYPE
    FROM
      (
        SELECT DISTINCT
          parent_prov_id
        FROM
          prod7.cross_provider
      )
      t
    LEFT JOIN prod7.provider p
    ON
      t.parent_prov_id = p.ID ;
    COMMIT;
  END populate_dimension_oversight;