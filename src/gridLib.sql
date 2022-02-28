
--
--  Grade Estatistica de Colombia.
--

-- Carregar https://git.AddressForAll.org/pg_pubLib-v1/blob/main/src/pubLib05hcode-encdec.sql


CREATE extension IF NOT EXISTS postgis;
DROP SCHEMA IF EXISTS libgrid_co CASCADE;
CREATE SCHEMA libgrid_co;

-------------------
-- Heper functions:

CREATE or replace FUNCTION jsonb_array_to_floats(j_numbers jsonb) RETURNS float[] AS $f$
  select array_agg(x::float) from jsonb_array_elements(j_numbers) t(x)
$f$ LANGUAGE SQL IMMUTABLE;

CREATE or replace FUNCTION libgrid_co.digitVal_to_digit(v int) RETURNS char as $f$
  -- v from 0 to 31.
  SELECT substr('0123456789BCDFGHJKLMNPQRSTUVWXYZ', v+1, 1)
$f$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION libgrid_co.cellGeom_to_bbox(r geometry) RETURNS float[] AS $f$
    SELECT array[min(st_X(g)), min(st_Y(g)), max(st_X(g)), max(st_Y(g))]
    FROM (SELECT (dp).geom as g  FROM (SELECT ST_DumpPoints(r) AS dp) t1 LIMIT 4) t2
$f$ LANGUAGE SQL IMMUTABLE;

---------------
---------------
---------------

CREATE TABLE libgrid_co.L0_cell262km AS
 WITH grid AS ( -- A grid from Colombian terrestrial box:
  SELECT size, (ST_SquareGrid(  size, ST_MakeEnvelope(4304477, 1089833, 5685106, 2957996, 9377)  )).*
  FROM (SELECT 262144 as size) t0
 )
  SELECT ROW_NUMBER() OVER() as gid,
         ''::char AS gid_code,
         libgrid_co.cellGeom_to_bbox(geom) AS bbox,
         geom
  FROM grid
  WHERE ST_Intersects(geom, (SELECT ST_Transform(geom,9377) FROM ingest.fdw_jurisdiction_geom WHERE isolabel_ext='CO') )
;
DELETE FROM libgrid_co.L0_cell262km WHERE gid=3   -- remove island
;
UPDATE libgrid_co.L0_cell262km
SET gid=n, gid_code=libgrid_co.digitVal_to_digit(32-n::int)
FROM (
  SELECT ROW_NUMBER() OVER(ORDER BY ST_Y(pt), ST_X(pt) DESC) AS n, gid
  FROM (SELECT gid, st_centroid(geom) as pt FROM libgrid_co.L0_cell262km) t0
) t
WHERE L0_cell262km.gid=t.gid
;

---------------
---------------
---------------
-- Main functions:

CREATE FUNCTION libgrid_co.osmcode_encode_xy(
   p_geom geometry(Point,9377),
   code_size int default 8
) RETURNS text AS $f$
  SELECT gid_code || str_ggeohash_encode(
          ST_X(p_geom),
          ST_Y(p_geom),
          code_size,
          5,
          '0123456789BCDFGHJKLMNPQRSTUVWXYZ',
          bbox  -- cover-cell specification
        )
  FROM libgrid_co.L0_cell262km
  WHERE ST_Contains(geom,p_geom)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode_xy(geometry(Point,9377), int)
  IS 'Encodes geometry (of standard Colombia projection) as standard Colembia-OSMcode.'
;
-- SELECT libgrid_co.osmcode_encode( ST_Transform(ST_SetSRID(ST_MakePoint(3.461,-76.577),4326),9377) );

CREATE or replace FUNCTION libgrid_co.osmcode_encode(
  p_geom geometry(Point, 4326),
  code_size int default 8
) RETURNS text AS $wrap$
  SELECT libgrid_co.osmcode_encode_xy( ST_Transform(p_geom,9377), code_size )
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode(geometry(Point,4326), int)
  IS 'Encodes LatLon (WGS84) as the standard Colombia-OSMcode. Wrap for libgrid_co.osmcode_encode(geometry(Point,9377)).'
;

CREATE or replace FUNCTION libgrid_co.osmcode_encode(
   lat float,
   lon float,
   code_size int default 8
) RETURNS text AS $wrap$
  SELECT libgrid_co.osmcode_encode(
      ST_SetSRID(ST_MakePoint(lon,lat),4326),
      code_size
    )
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode(float,float,int)
  IS 'Encodes LatLon as the standard Colombia-OSMcode. Wrap for osmcode_encode(geometry)'
;

CREATE FUNCTION libgrid_co.osmcode_encode(uri text) RETURNS text AS $wrap$
   -- pending add parameter to enforce size
  SELECT libgrid_co.osmcode_encode(latLon[1],latLon[2]) -- pending uncertain_to_size
  FROM (SELECT str_geouri_decode(uri)) t(latLon)
$wrap$ LANGUAGE SQL IMMUTABLE;


---

CREATE FUNCTION libgrid_co.osmcode_encode2_xy(
   p_geom geometry(Point,9377),
   code_size int default 8
) RETURNS jsonb AS $f$

  SELECT  jsonb_build_object('code',gid_code||(j->>'code'), 'box',j->'box')
  FROM (
    SELECT gid_code, str_ggeohash_encode2(
            ST_X(p_geom),
            ST_Y(p_geom),
            code_size,
            5,
            '0123456789BCDFGHJKLMNPQRSTUVWXYZ',
            bbox  -- cover-cell specification
          ) AS j
    FROM libgrid_co.L0_cell262km
    WHERE ST_Contains(geom,p_geom)
  ) t

$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode2_xy(geometry(Point,9377), int)
  IS 'Encodes geometry (of standard Colombia projection) as standard Colembia-OSMcode.'
;
-- SELECT libgrid_co.osmcode_encode( ST_Transform(ST_SetSRID(ST_MakePoint(3.461,-76.577),4326),9377) );

CREATE FUNCTION libgrid_co.osmcode_encode2_latlon(
   p_geom geometry(Point,4326),
   code_size int default 8
) RETURNS jsonb AS $f$
  SELECT libgrid_co.osmcode_encode2_xy( ST_Transform(p_geom,9377), code_size )
$f$ LANGUAGE SQL IMMUTABLE;


CREATE or replace FUNCTION libgrid_co.osmcode_encode2(
   lat float,
   lon float,
   code_size int default 8
) RETURNS jsonb AS $wrap$
  SELECT libgrid_co.osmcode_encode2_latlon(
      ST_SetSRID(ST_MakePoint(lon,lat),4326),
      code_size
    )
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode2(float,float,int)
  IS 'Encodes LatLon as the standard Colombia-OSMcode. Wrap for osmcode_encode(geometry)'
;

CREATE FUNCTION libgrid_co.osmcode_encode2(uri text,code_size int default 8) RETURNS jsonb AS $wrap$
  SELECT libgrid_co.osmcode_encode2(latLon[1],latLon[2],code_size) -- pending uncertain_to_size
  FROM (SELECT str_geouri_decode(uri)) t(latLon)
$wrap$ LANGUAGE SQL IMMUTABLE;
