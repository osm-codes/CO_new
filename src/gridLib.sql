
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
         ''::text AS gid_code_hex,
         libgrid_co.cellGeom_to_bbox(geom) AS bbox,
         geom
  FROM grid
  WHERE ST_Intersects(geom, (SELECT ST_Transform(geom,9377) FROM ingest.fdw_jurisdiction_geom WHERE isolabel_ext='CO') )
;
DELETE FROM libgrid_co.L0_cell262km WHERE gid=3   -- remove island
;
UPDATE libgrid_co.L0_cell262km
SET gid=t.n,
    gid_code=t.gid_code,
    gid_code_hex=('{"0": "00", "1": "01", "2": "02", "3": "03", "4": "04", "5": "05", "6": "06", "7": "07", "8": "08", "9": "09", "B": "0a", "C": "0b", "D": "0c", "F": "0d", "G": "0e", "H": "0f", "J": "10", "K": "11", "L": "12", "M": "13", "N": "14", "P": "15", "Q": "16", "R": "17", "S": "18", "T": "19", "U": "1a", "V": "1b", "W": "1c", "X": "1d", "Y": "1e", "Z": "1f"}'::jsonb)->>t.gid_code
FROM (
  SELECT *, libgrid_co.digitVal_to_digit(32-n::int) as gid_code
  FROM (
    SELECT ROW_NUMBER() OVER(ORDER BY ST_Y(pt), ST_X(pt) DESC) AS n, gid
    FROM (SELECT gid, st_centroid(geom) as pt FROM libgrid_co.L0_cell262km) t0
  ) t1
) t
WHERE L0_cell262km.gid=t.gid
;

---------------
---------------
---------------
-- Main functions:

CREATE FUNCTION libgrid_co.osmcode_encode_xy(
   p_geom geometry(Point,9377),
   code_size int default 8,
   use_hex boolean default false
) RETURNS text AS $f$
  SELECT gid_code || str_ggeohash_encode(
          ST_X(p_geom),
          ST_Y(p_geom),
          code_size,
          CASE WHEN use_hex THEN 4 ELSE 5 END,
          CASE WHEN use_hex THEN '0123456789abcdef' ELSE '0123456789BCDFGHJKLMNPQRSTUVWXYZ' END,
          bbox  -- cover-cell specification
        )
  FROM libgrid_co.L0_cell262km
  WHERE ST_Contains(geom,p_geom)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode_xy(geometry(Point,9377), int, boolean)
  IS 'Encodes geometry (of standard Colombia projection) as standard Colembia-OSMcode.'
;
-- SELECT libgrid_co.osmcode_encode_ptgeom( ST_SetSRID(ST_MakePoint(-76.577,3.461),4326) );
-- SELECT libgrid_co.osmcode_encode_ptgeom( ST_Transform(ST_SetSRID(ST_MakePoint(-76.577,3.461),4326),9377) );


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

CREATE or replace FUNCTION libgrid_co.osmcode_encode2_ptgeom(
   p_geom    geometry(POINT),
   code_size int       default 8,
   use_hex   boolean   default false
) RETURNS jsonb AS $f$

  SELECT  jsonb_build_object( 'code',gid_code||(j->>'code'),  'box',j->'box' )
  FROM (
    SELECT CASE WHEN use_hex THEN l0.gid_code_hex ELSE l0.gid_code END as gid_code,
           str_ggeohash_encode2(
              ST_X(t.geom), ST_Y(t.geom),
              code_size,
              CASE WHEN use_hex THEN 4 ELSE 5 END,
              CASE WHEN use_hex THEN '0123456789abcdef' ELSE '0123456789BCDFGHJKLMNPQRSTUVWXYZ' END,
              l0.bbox  -- cover-cell specification
            ) AS j
    FROM libgrid_co.L0_cell262km l0,
         (SELECT CASE WHEN ST_SRID(p_geom)=9377 THEN p_geom ELSE ST_Transform(p_geom,9377) END) t(geom)
    WHERE ST_Contains(l0.geom,t.geom)
  ) t2

$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode2_ptgeom(geometry(POINT),int,boolean)
  IS 'Encodes geometry (of standard Colombia projection) as standard Colembia-OSMcode.'
;
-- SELECT libgrid_co.osmcode_encode2_ptgeom( ST_SetSRID(ST_MakePoint(-76.577,3.461),4326) );

CREATE or replace FUNCTION libgrid_co.osmcode_encode2(
   lat float,
   lon float,
   code_size int default 8
) RETURNS jsonb AS $wrap$
  SELECT libgrid_co.osmcode_encode2_ptgeom(
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
COMMENT ON FUNCTION libgrid_co.osmcode_encode2(text,int)
  IS 'Encodes Geo URI to a standard Colombia-OSMcode geocode. Wrap for osmcode_encode2(lat,lon)'
;
-- SELECT libgrid_co.osmcode_encode2( 'geo:-76.577,3.461' );

----
CREATE FUNCTION libgrid_co.gridGeoms_fromGeom(
  reference_geom geometry,
  code_size int default 5,
  npoints integer default 600
) RETURNS TABLE (gid int, code text, geom geometry(POLYGON,9377))
AS $f$
    SELECT ROW_NUMBER() OVER() as gid, -- ou bigint geocode_to_binary(j->>'code')
           j->>'code' AS code,
           str_ggeohash_draw_cell_bybox(jsonb_array_to_floats(j->'box'),false,9377) AS geom
    FROM (
      SELECT  distinct libgrid_co.osmcode_encode2_ptgeom(geom,code_size) as j
      FROM ST_DumpPoints(  ST_GeneratePoints(reference_geom,npoints)  ) t1(d)
    ) t2
    ORDER BY j->>'code'
$f$ LANGUAGE SQL IMMUTABLE;
-- SELECT libgrid_co.gridGeoms_fromGeom( ST_SetSRID( ST_GeomFromText('POLYGON((-76.57770034945 3.46103000261,-76.57391243547 3.46103208489,-76.57390575999 3.45834677198,-76.57770076667 3.45834677198,-76.57770034945 3.46103000261))')  ,4326)  );



------------------
------------------

CREATE FUNCTION libgrid_co.osmcode_decode_XYbox(
   p_code text
) RETURNS float[] AS $f$
  SELECT str_ggeohash_decode_box(  -- returns codeBox
           c.code,
           5, -- code_digit_bits
           '{"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9, "b":10, "c":11, "d":12, "f":13, "g":14, "h":15, "j":16, "k":17, "l":18, "m":19, "n":20, "p":21, "q":22, "r":23, "s":24, "t":25, "u":26, "v":27, "w":28, "x":29, "y":30, "z":31}'::jsonb,
           l.bbox  -- cover-cell specification
         ) AS codebox
  FROM libgrid_co.L0_cell262km l INNER JOIN
      ( SELECT substr(p_code,1,1) AS gid_code, substr(p_code,2) as code) c
      ON l.gid_code=c.gid_code
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_XYbox(text)
  IS 'Decodes Colombia-OSMcode geocode into a bounding box of its cell.'
;
-- SELECT libgrid_co.osmcode_decode_xybox('HX7VGYKPW');

CREATE or replace FUNCTION libgrid_co.osmcode_decode_XY(
   p_code text,
   witherror boolean default false
) RETURNS float[] as $f$
  SELECT CASE WHEN witherror THEN xy || array[p[3] - xy[1], p[4] - xy[2]] ELSE xy END
  FROM (
    SELECT array[(p[1] + p[3]) / 2.0, (p[2] + p[4]) / 2.0] AS xy, p
    FROM (SELECT libgrid_co.osmcode_decode_XYbox(p_code)) t1(p)
  ) t2
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_XY(text,boolean)
  IS 'Decodes Colombia-OSMcode into a XY point and optional error.'
;
-- SELECT libgrid_co.osmcode_decode('HX7VGYKPW',true);


CREATE FUNCTION libgrid_co.osmcode_decode_toXYPoint(p_code text) RETURNS geometry AS $f$
  SELECT ST_SetSRID(ST_MakePoint(xy[1],xy[2]),9377)  -- inverter X com Y?
  FROM ( SELECT libgrid_co.osmcode_decode_XY(p_code,false) ) t(xy)
$f$ LANGUAGE SQL IMMUTABLE;


CREATE or replace FUNCTION libgrid_co.osmcode_decode_toPoint(p_code text) RETURNS geometry AS $f$
  SELECT ST_Transform( ST_SetSRID(ST_MakePoint(xy[1],xy[2]),9377) , 4326) -- trocar x y?
  FROM ( SELECT libgrid_co.osmcode_decode_XY(p_code,false) ) t(xy)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_toPoint(text)
  IS 'Decodes Colombia-OSM_code into a WGS84 geometry.'
;

CREATE or replace FUNCTION libgrid_co.osmcode_decode(p_code text) RETURNS float[] AS $f$
  SELECT array[ST_Y(geom), ST_X(geom)]  -- LatLon
  FROM ( SELECT libgrid_co.osmcode_decode_toPoint(p_code) ) t(geom)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode(text)
  IS 'Decodes Colombia-OSM_code into WGS84 LatLon coordinates.'
;


--------------------------------------
--------------------------------------
---- EXPERIMENTS UNDER CONSTRUCTION:

/*
CREATE FUNCTION libgrid_co.osmcode_decode_polyXY(
   code text
) RETURNS geometry AS $f$
  SELECT ST_MakeEnvelope(b[1], b[2], b[3], b[4], 9377)
  FROM (SELECT libgrid_co.osmcode_decode_boxXY(code)) t(b)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_boxXY(text)
  IS 'Draw the geometry of a Colombia-OSM_code.'
;

CREATE FUNCTION libgrid_co.osmcode_decode_XY(
   code text,
   witherror boolean default false
) RETURNS float[] AS $f$
  SELECT CASE WHEN witherror THEN xy || array[bbox[3] - xy[1], bbox[4] - xy[2]] ELSE xy END
  FROM (
    SELECT array[(bbox[1] + bbox[3]) / 2, (bbox[2] + bbox[4]) / 2] AS xy, bbox
    FROM (SELECT libgrid_co.osmcode_decode_boxXY(code)) t1(bbox)
  ) t2
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_XY(text,boolean)
  IS 'Decodes Colombia-OSM_code into a XY point of its official projection.'
;

CREATE or replace FUNCTION libgrid_co.osmcode_decode(
   code text
 ) RETURNS float[] AS $f$
  SELECT array[ST_Y(geom), ST_X(geom)]
  FROM ( SELECT libgrid_co.osmcode_decode_topoint(code) ) t(geom)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_topoint(text)
  IS 'Decodes Colombia-OSM_code into standard LatLon array.'
;



*/


------------------------
---- HELPER AND ASSERTS:

/*

CREATE FUNCTION libgrid_co.num_base32_decode(p_val text) -- não trata zeros a esquerda, exceto em modo hiddenBit
RETURNS numeric(500,0) AS $f$
		  SELECT SUM(
	       ( 32::numeric(500,0)^(length($1)-i) )::numeric(500,0)
	       *   -- base^j * digit_j
	       ( strpos('0123456789BCDFGHJKLMNPQRSTUVWXYZ',d) - 1 )::numeric(500,0)
	    )::numeric(500,0) --- returns numeric?
  		FROM regexp_split_to_table($1,'') WITH ORDINALITY t1(d,i)
$f$ LANGUAGE SQL IMMUTABLE;

SELECT  jsonb_object_agg(x, '0'||libgrid_co.num_base32_decode(x)::text)
FROM  regexp_split_to_table('0123456789BCDFGHJKLMNPQRSTUVWXYZ','') t(x);
 {"0": "00", "1": "01", "2": "02", "3": "03", "4": "04", "5": "05", "6": "06", "7": "07",
  "8": "08", "9": "09", "B": "0a", "C": "0b", "D": "0c", "F": "0d", "G": "0e", "H": "0f",
  "J": "10", "K": "11", "L": "12", "M": "13", "N": "14", "P": "15", "Q": "16", "R": "17",
  "S": "18", "T": "19", "U": "1a", "V": "1b", "W": "1c", "X": "1d", "Y": "1e", "Z": "1f"}


CREATE FUNCTION libgrid_co.str_geohash_encode_bypgis(
  latLon text
) RETURNS text as $wrap$
  SELECT ST_GeoHash(  ST_SetSRID(ST_MakePoint(x[2],x[1]),4326),  8)
  FROM (SELECT str_geouri_decode(LatLon)) t(x)
$wrap$ LANGUAGE SQL IMMUTABLE;


CREATE FUNCTION libgrid_co.num_baseGeohash_decode(p_val text) RETURNS numeric(500,0) AS $wrap$
   SELECT libgrid_co.num_base_decode(p_val, 32, '0123456789bcdefghjkmnpqrstuvwxyz');
$wrap$ LANGUAGE SQL IMMUTABLE;


CREATE FUNCTION libgrid_co.osmcode_encode_testfull(
   lat float,
   lon float,
   code_size int default 8
) RETURNS text AS $f$
  SELECT str_ggeohash_encode(
         ST_X(geom),
         ST_Y(geom),
         code_size,
         5, -- code_digit_bits
         '0123456789BCDFGHJKLMNPQRSTUVWXYZ', -- base32nvU as http://addressforall.org/_foundations/art1.pdf
         4304477, -- min_x
         1089833, -- min_y
         5685106, -- max_x
         2957996  -- max_y
       )
  FROM (SELECT ST_Transform( ST_SetSRID(ST_MakePoint(lon,lat),4326) , 9377)) t(geom)
$f$ LANGUAGE SQL IMMUTABLE;
*/
-----------
-- Helper:

CREATE FUNCTION libgrid_co.osmcode_encode_level0(pt geometry) RETURNS text AS $f$
  SELECT gid_code
  FROM libgrid_co.L0_cell262km
  WHERE ST_Contains(geom,pt)
$f$ LANGUAGE SQL IMMUTABLE;


/*
CREATE FUNCTION libgrid_co.grid__GeomsFromPrefix(
  parent_code text,
  context_prefix text default ''
) RETURNS TABLE (gid int, code text, geom geometry(POLYGON,9377)) AS $f$

  SELECT ROW_NUMBER() OVER() as gid, code, local_code,
  FROM (
    SELECT prefix||x as code,
           context_prefix||x as local_code
           libgrid_co.??(prefix||x) as j
    FROM unnest( regexp_split_to_array('0123456789BCDFGHJKLMNPQRSTUVWXYZ','') ) t(x)
    ORDER BY 1
  ) t

$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION geohash_GeomsFromPrefix
  IS 'Return a GGeohash grid, the quadrilateral geometry of each child-cell and its geocode.'
;
*/




CREATE FUNCTION libgrid_co.grid__GeomsFromGeom(
  reference_geom geometry,
  npoints integer default 200
) RETURNS TABLE (gid int, code text, geom geometry(POLYGON,9377)) AS $f$
  SELECT ROW_NUMBER() OVER() as gid, code, local_code,
  FROM (
    SELECT prefix||x as code,
           context_prefix||x as local_code
           libgrid_co.osmcode_encode2_ptgeom(geom) as j
    FROM ST_GeneratePoints(reference_geom,npoints) t(geom)
    ORDER BY 1
  ) t
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION geohash_GeomsFromPrefix
  IS 'Return a GGeohash grid, the quadrilateral geometry of each child-cell and its geocode.'
;
-- ST_GeomFromText('POLYGON((-76.57770034945 3.46103000261,-76.57391243547 3.46103208489,-76.57390575999 3.45834677198,-76.57770076667 3.45834677198,-76.57770034945 3.46103000261))')




/* homologado com QGIS:
SELECT  distinct st_asText(geom)
FROM ST_DumpPoints(ST_GeneratePoints(
  ST_SetSRID(
    ST_GeomFromText('POLYGON((-76.57770034945 3.46103000261,-76.57391243547 3.46103208489,-76.57390575999 3.45834677198,-76.57770076667 3.45834677198,-76.57770034945 3.46103000261))')
    ,4326
  )
  ,600
)) t1(d);
*/
