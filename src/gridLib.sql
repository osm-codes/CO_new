
--
--  Grade Estatistica de Colombia.
--

-- Carregar https://git.AddressForAll.org/pg_pubLib-v1/blob/main/src/pubLib05hcode-encdec.sql


CREATE extension IF NOT EXISTS postgis;
DROP SCHEMA IF EXISTS lib_co_grid CASCADE;
CREATE SCHEMA lib_co_grid;

-------

CREATE FUNCTION lib_co_grid.str_geohash_encode_bypgis(
  latLon text
) RETURNS text as $wrap$
  SELECT ST_GeoHash(  ST_SetSRID(ST_MakePoint(x[2],x[1]),4326),  8)
  FROM (SELECT str_geouri_decode(LatLon)) t(x)
$wrap$ LANGUAGE SQL IMMUTABLE;


CREATE FUNCTION lib_co_grid.num_base_decode(
  p_val text,
  p_base int, -- from 2 to 36
  p_alphabet text = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
) RETURNS numeric(500,0) AS $f$
		  SELECT SUM(
	       ( p_base::numeric(500,0)^(length($1)-i) )::numeric(500,0)
	       *   -- base^j * digit_j
	       ( strpos(p_alphabet,d) - 1 )::numeric(500,0)
	    )::numeric(500,0) --- returns numeric?
  		FROM regexp_split_to_table($1,'') WITH ORDINALITY t1(d,i)
$f$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION lib_co_grid.num_baseGeohash_decode(p_val text) RETURNS numeric(500,0) AS $wrap$
   SELECT lib_co_grid.num_base_decode(p_val, 32, '0123456789bcdefghjkmnpqrstuvwxyz');
$wrap$ LANGUAGE SQL IMMUTABLE;

---------------


CREATE FUNCTION lib_co_grid.osmcode_encode(
   lat float,
   lon float,
   numberOfChars int default 8
) RETURNS text AS $f$
  SELECT str_ggeohash_encode(
         ST_X(geom),
         ST_Y(geom),
         numberOfChars,
         5, -- baseBits
         '0123456789BCDFGHJKLMNPQRSTUVWXYZ', -- base32nvU as http://addressforall.org/_foundations/art1.pdf
         5685106, -- max_x
         4304477, -- min_x
         2957996, -- max_y
         1089833 -- min_y
       )
  FROM (SELECT ST_Transform( ST_SetSRID(ST_MakePoint(lon,lat),4326) , 9377)) t(geom)
$f$ LANGUAGE SQL IMMUTABLE;


CREATE FUNCTION lib_co_grid.osmcode_decode_boxXY(
   code text
) RETURNS float[] AS $f$
  SELECT str_ggeohash_decode_box(
         code,
         5, -- baseBits
         '{"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9, "b":10, "c":11, "d":12, "f":13, "g":14, "h":15, "j":16, "k":17, "l":18, "m":19, "n":20, "p":21, "q":22, "r":23, "s":24, "t":25, "u":26, "v":27, "w":28, "x":29, "y":30, "z":31}'::jsonb,
         5685106, -- max_x
         4304477, -- min_x
         2957996, -- max_y
         1089833  -- min_y
       )
$f$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION lib_co_grid.osmcode_decode_XY(
   code text,
   witherror boolean default false
) RETURNS float[] AS $f$
  SELECT CASE WHEN witherror THEN xy || array[bbox[3] - xy[1], bbox[4] - xy[2]] ELSE xy END
  FROM (
    SELECT array[(bbox[1] + bbox[3]) / 2, (bbox[2] + bbox[4]) / 2] AS xy, bbox
    FROM (SELECT lib_co_grid.osmcode_decode_boxXY(code)) t1(bbox)
  ) t2
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION lib_co_grid.osmcode_decode_XY(text,boolean)
  IS 'Decodes Colombia-OSM_code into a XY point of its official projection.'
;

CREATE or replace FUNCTION lib_co_grid.osmcode_decode_topoint(
   code text
 ) RETURNS geometry AS $f$
  SELECT ST_Transform( ST_SetSRID(ST_MakePoint(xy[1],xy[2]),9377) , 4326) -- trocar x y?
  FROM ( SELECT lib_co_grid.osmcode_decode_XY(code,false) ) t(xy)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION lib_co_grid.osmcode_decode_topoint(text)
  IS 'Decodes Colombia-OSM_code into a WGS84 point.'
;

CREATE or replace FUNCTION lib_co_grid.osmcode_decode(
   code text
 ) RETURNS float[] AS $f$
  SELECT array[ST_Y(geom), ST_X(geom)]
  FROM ( SELECT lib_co_grid.osmcode_decode_topoint(code) ) t(geom)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION lib_co_grid.osmcode_decode_topoint(text)
  IS 'Decodes Colombia-OSM_code into standard LatLon array.'
;
