--
--  Grade Estatistica/Postal
--

CREATE EXTENSION IF NOT EXISTS postgis;
DROP SCHEMA IF EXISTS libosmcodes CASCADE;
CREATE SCHEMA libosmcodes;

------------------
-- Helper functions:

CREATE or replace FUNCTION libosmcodes.ij_to_xy(
  i  int, -- coluna
  j  int, -- linha
  x0 int, -- referencia de inicio do eixo x [x0,y0]
  y0 int, -- referencia de inicio do eixo y [x0,y0]
  s  int  -- lado da célula
) RETURNS int[] AS $f$
  SELECT array[
    x0 + i*s,
    y0 + j*s
  ]
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.ij_to_xy(int,int,int,int,int)
 IS 'Retorna canto inferior esquerdo de célula na matriz.'
;
--SELECT libosmcodes.ij_to_xy(1,1,4180000,1035500,262144);

CREATE or replace FUNCTION libosmcodes.ij_to_geom(
  i  int, -- coluna
  j  int, -- linha
  x0 int, -- referencia de inicio do eixo x [x0,y0]
  y0 int, -- referencia de inicio do eixo y [x0,y0]
  s  int, -- lado da célula
  sr int  -- srid
) RETURNS geometry AS $f$
  SELECT str_ggeohash_draw_cell_bycenter(v[1]+s/2,v[2]+s/2,s/2,false,sr)
  FROM
  (
    SELECT libosmcodes.ij_to_xy(i,j,x0,y0,s) v
  ) t
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.ij_to_geom(int,int,int,int,int,int)
 IS 'Retorna geometria de célula na matriz.'
;
--SELECT libosmcodes.ij_to_geom(0,0,4180000,1035500,262144,9377);

CREATE or replace FUNCTION libosmcodes.ij_to_bbox(
  i  int, -- coluna
  j  int, -- linha
  x0 int, -- referencia de inicio do eixo x [x0,y0]
  y0 int, -- referencia de inicio do eixo y [x0,y0]
  s  int  -- lado da célula
) RETURNS int[] AS $f$
  SELECT array[ x0+i*s, y0+j*s, x0+i*s+s, y0+j*s+s ]
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.ij_to_bbox(int,int,int,int,int)
 IS 'Retorna bbox de célula da matriz.'
;
-- SELECT libosmcodes.ij_to_bbox(0,0,4180000,1035500,262144);

CREATE or replace FUNCTION libosmcodes.ij_to_bbox(
  a int[]
)RETURNS int[] AS $wrap$
  SELECT libosmcodes.ij_to_bbox(a[1],a[2],a[3],a[4],a[5])
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.ij_to_bbox(int[])
 IS 'Retorna bbox de célula da matriz.'
;
-- SELECT libosmcodes.ij_to_bbox(array[0,0,4180000,1035500,262144]);

CREATE or replace FUNCTION libosmcodes.xy_to_ij(
  x  int,
  y  int,
  x0 int, -- referencia de inicio do eixo x [x0,y0]
  y0 int, -- referencia de inicio do eixo y [x0,y0]
  s  int  -- lado da célula
) RETURNS int[] AS $f$
  SELECT array[ (x-x0)/s, (y-y0)/s, x0, y0, s ]
  WHERE (x-x0) >= 0 AND (y-y0) >= 0
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.xy_to_ij(int,int,int,int,int,int)
 IS 'Retorna célula da matriz que contem x,y.'
;
--SELECT libosmcodes.xy_to_ij(4442144,1297644,4180000,1035500,262144);

CREATE or replace  FUNCTION libosmcodes.xy_to_ij(
  a int[]
) RETURNS int[] AS $wrap$
  SELECT libosmcodes.xy_to_ij(a[1],a[2],a[3],a[4],a[5])
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.xy_to_ij(int[])
 IS 'Retorna célula da matriz que contem x,y.'
;
--SELECT libosmcodes.xy_to_ij(array[4442144,1297644,4180000,1035500,262144]);

CREATE or replace FUNCTION libosmcodes.xy_to_bbox(
  x  int,
  y  int,
  x0 int, -- referencia de inicio do eixo x [x0,y0]
  y0 int, -- referencia de inicio do eixo y [x0,y0]
  s  int  -- lado da célula
  ) RETURNS int[] AS $f$
  SELECT libosmcodes.ij_to_bbox(libosmcodes.xy_to_ij(x,y,x0,y0,s))
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.xy_to_bbox(int,int,int,int,int)
 IS 'Retorna bbox da célula que contém x,y.'
;
-- SELECT libosmcodes.xy_to_bbox(4704288,1559788,4180000,1035500,262144);

CREATE or replace  FUNCTION libosmcodes.xy_to_quadrant(
  x  int,
  y  int,
  x0 int, -- referencia de inicio do eixo x [x0,y0]
  y0 int, -- referencia de inicio do eixo y [x0,y0]
  s  int, -- lado da célula
  cl int  -- número de colunas da matriz
) RETURNS int AS $f$
  SELECT cl*ij[2] + ij[1]
  FROM ( SELECT libosmcodes.xy_to_ij(x,y,x0,y0,s) ) t(ij)
  WHERE ij[1] < cl
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.xy_to_quadrant(int,int,int,int,int,int)
 IS 'Retorna número do quandrante que contém x,y.'
;
--SELECT libosmcodes.xy_to_quadrant(4442144,1297644,4180000,1035500,262144,6);

CREATE or replace  FUNCTION libosmcodes.xy_to_quadrant(
  a int[]
) RETURNS int AS $wrap$
  SELECT libosmcodes.xy_to_quadrant(a[1],a[2],a[3],a[4],a[5],a[6])
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.xy_to_quadrant(int[])
 IS 'Retorna número do quandrante que contém x,y.'
;
--SELECT libosmcodes.xy_to_quadrant(array[4442144,1297644,4180000,1035500,262144,6]);

------------------
-- Uncertain level defaults:

CREATE or replace FUNCTION libosmcodes.uncertain_base16h(u int) RETURNS int AS $f$
  -- GeoURI's uncertainty value "is the radius of the disk that represents uncertainty geometrically"
  SELECT CASE -- discretization by "snap to size-levels bits"
     WHEN s < 1 THEN 36
     WHEN s < 2 THEN 35
     WHEN s < 3 THEN 34
     WHEN s < 4 THEN 33
     WHEN s < 6 THEN 32
     WHEN s < 8 THEN 31
     WHEN s < 11 THEN 30
     WHEN s < 16 THEN 29
     WHEN s < 23 THEN 28
     WHEN s < 32 THEN 27
     WHEN s < 45 THEN 26
     WHEN s < 64 THEN 25
     WHEN s < 91 THEN 24
     WHEN s < 128 THEN 23
     WHEN s < 181 THEN 22
     WHEN s < 256 THEN 21
     WHEN s < 362 THEN 20
     WHEN s < 512 THEN 19
     WHEN s < 724 THEN 18
     WHEN s < 1024 THEN 17
     WHEN s < 1448 THEN 16
     WHEN s < 2048 THEN 15
     WHEN s < 2896 THEN 14
     WHEN s < 4096 THEN 13
     WHEN s < 5793 THEN 12
     WHEN s < 8192 THEN 11
     WHEN s < 11585 THEN 10
     WHEN s < 16384 THEN 9
     WHEN s < 23170 THEN 8
     WHEN s < 32768 THEN 7
     WHEN s < 46341 THEN 6
     WHEN s < 65536 THEN 5
     WHEN s < 92682 THEN 4
     WHEN s < 131072 THEN 3
     WHEN s < 185364 THEN 2
     WHEN s < 262144 THEN 1
     ELSE 0
     END
  FROM (SELECT u*2) t(s)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.uncertain_base16h(int)
  IS 'Uncertain base16h and base32 for L0 262km'
;

CREATE or replace FUNCTION libosmcodes.uncertain_base16hL01048km(u int) RETURNS int AS $f$
  -- GeoURI's uncertainty value "is the radius of the disk that represents uncertainty geometrically"
  SELECT CASE -- discretization by "snap to size-levels bits"
     WHEN s < 1 THEN 40
     WHEN s < 2 THEN 39
     WHEN s < 3 THEN 38
     WHEN s < 4 THEN 37
     WHEN s < 6 THEN 36
     WHEN s < 8 THEN 35
     WHEN s < 11 THEN 34
     WHEN s < 16 THEN 33
     WHEN s < 23 THEN 32
     WHEN s < 32 THEN 31
     WHEN s < 45 THEN 30
     WHEN s < 64 THEN 29
     WHEN s < 91 THEN 28
     WHEN s < 128 THEN 27
     WHEN s < 181 THEN 26
     WHEN s < 256 THEN 25
     WHEN s < 362 THEN 24
     WHEN s < 512 THEN 23
     WHEN s < 724 THEN 22
     WHEN s < 1024 THEN 21
     WHEN s < 1448 THEN 20
     WHEN s < 2048 THEN 19
     WHEN s < 2896 THEN 18
     WHEN s < 4096 THEN 17
     WHEN s < 5793 THEN 16
     WHEN s < 8192 THEN 15
     WHEN s < 11585 THEN 14
     WHEN s < 16384 THEN 13
     WHEN s < 23170 THEN 12
     WHEN s < 32768 THEN 11
     WHEN s < 46341 THEN 10
     WHEN s < 65536 THEN 9
     WHEN s < 92682 THEN 8
     WHEN s < 131072 THEN 7
     WHEN s < 185364 THEN 6
     WHEN s < 262144 THEN 5
     WHEN s < 370728 THEN 4
     WHEN s < 524288 THEN 3
     WHEN s < 741455 THEN 2
     WHEN s < 1048576 THEN 1
     ELSE 0
     END
  FROM (SELECT u*2) t(s)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.uncertain_base16hL01048km(int)
  IS 'Uncertain base16h and base32 for L0 1048km'
;

------------------
-- Others helper functions::

CREATE or replace FUNCTION str_geocodeiso_decode(iso text)
RETURNS text[] as $f$
  SELECT
    CASE
      WHEN cardinality(u)=3 AND iso ~ '[a-zA-Z]{2,}' THEN iso || array[upper(u[1])]
      ELSE (
        SELECT isolabel_ext
        FROM mvwjurisdiction_synonym
        WHERE lower(synonym) = lower(iso) ) || array[upper(u[1])]
    END
  FROM ( SELECT regexp_split_to_array (iso,'(-)')::text[] AS u ) r
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION str_geocodeiso_decode(text)
  IS 'Decode abbrev isolabel_ext.'
;
--SELECT str_geocodeiso_decode('CO-Itagui');

CREATE or replace FUNCTION libosmcodes.osmcode_decode_xybox(
  p_code text,
  p_base int DEFAULT 32,
  bbox   int[] DEFAULT array[0,0,0,0]
) RETURNS float[] AS $f$
  SELECT str_ggeohash_decode_box(  -- returns codeBox
           p_code, -- without l0 prefix
           CASE WHEN p_base = 16 THEN 4 ELSE 5 END, -- code_digit_bits
           CASE WHEN p_base = 16
           THEN
           '{"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9, "a":10, "b":11, "c":12, "d":13, "e":14, "f":15, "g":0, "h":1,"j":0, "k":1, "l":2, "m":3,
           "n":0, "p":1, "q":2, "r":3, "s":4, "t":5, "v":6, "z":7}'::jsonb
           ELSE
           '{"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9, "b":10, "c":11, "d":12, "f":13, "g":14, "h":15, "j":16, "k":17, "l":18, "m":19, "n":20, "p":21, "q":22, "r":23, "s":24, "t":25, "u":26, "v":27, "w":28, "x":29, "y":30, "z":31}'::jsonb
           END,
           bbox  -- cover-cell specification
         ) AS codebox
         --str_ggeohash_decode_box2(baseh_to_vbit(p_code,p_base),p_bbox)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.osmcode_decode_xybox(text,int,int[])
  IS 'Decodes OSMcode geocode into a bounding box of its cell.'
;

CREATE or replace FUNCTION libosmcodes.ggeohash_GeomsFromVarbit(
  p_code varbit,
  p_translate boolean DEFAULT false, -- true para converter em LatLong (WGS84 sem projeção)
  p_srid      int DEFAULT 4326,      -- WGS84
  p_base      int DEFAULT 16,
  p_grid_size int DEFAULT 2,
  p_bbox int[] DEFAULT  array[0,0,0,0]
) RETURNS TABLE(ghs text, geom geometry) AS $f$
  SELECT vbit_to_baseh(p_code || x,p_base,0), str_ggeohash_draw_cell_bybox(str_ggeohash_decode_box2(p_code || x,p_bbox),p_translate,p_srid)
  FROM
  unnest(
  CASE
  WHEN p_base = 16 AND p_grid_size = 2  THEN '{0,1}'::bit[]
  WHEN p_base = 16 AND p_grid_size = 4  THEN '{00,01,11,10}'::varbit[]
  WHEN p_base = 16 AND p_grid_size = 8  THEN '{000,001,010,011,100,101,110,111}'::varbit[]
  WHEN p_base = 16 AND p_grid_size = 16 THEN '{0000,0001,0010,0011,0100,0101,0110,0111,1000,1001,1010,1011,1100,1101,1110,1111}'::varbit[]
  WHEN p_base = 32 AND p_grid_size = 32 THEN '{00000,00001,00010,00011,00100,00101,00110,00111,01000,01001,01010,01011,01100,01101,01110,01111,10000,10001,10010,10011,10100,10101,10110,10111,11000,11001,11010,11011,11100,11101,11110,11111}'::varbit[]
  END
  ) t(x)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.ggeohash_GeomsFromVarbit
  IS 'Return grid child-cell of OSMcode. The parameter is the ggeohash the parent-cell, that will be a prefix for all child-cells.'
;

------------------
-- Table cover:

-- l0cover:
CREATE TABLE libosmcodes.l0cover (
  jurisd_base_id int   NOT NULL,
  srid           int   NOT NULL,
  prefix_l032    text  NOT NULL,
  prefix_l016h   text  NOT NULL,
  bbox           int[] NOT NULL,
  subcells_l032  text[],
  subcells_l016h text[],
  geom           geometry, -- in default srid
  geom_srid4326  geometry
);

-- de-para:
CREATE TABLE libosmcodes.de_para (
  id bigint    NOT NULL,
  isolabel_ext text NOT NULL,
  prefix       text NOT NULL,
  index        text NOT NULL,
  geom         geometry -- in default srid
);

------------------
-- encode:

CREATE or replace FUNCTION libosmcodes.osmcode_encode(
  p_geom       geometry(POINT),
  p_base       int     DEFAULT 32,
  p_bit_length int     DEFAULT 40,
  p_srid       int     DEFAULT 9377,
  p_grid_size  int     DEFAULT 32,
  p_bbox       int[]   DEFAULT array[0,0,0,0],
  p_l0code     text    DEFAULT '0',
  p_jurisd_base_id int DEFAULT 170
) RETURNS jsonb AS $f$
    SELECT jsonb_build_object(
      'type', 'FeatureCollection',
      'features',
        (
          ST_AsGeoJSONb(ST_Transform(geom_cell,4326),8,0,null,
              jsonb_strip_nulls(jsonb_build_object(
                  'code', code_end,
                  'short_code', short_code,
                  'area', ST_Area(geom_cell),
                  'side', SQRT(ST_Area(geom_cell)),
                  'base', base
                  ))
          )::jsonb ||
          CASE
          WHEN p_grid_size > 0
          THEN
            (
              SELECT jsonb_agg(
                  ST_AsGeoJSONb(  CASE WHEN p_grid_size % 2 = 1 THEN ST_Centroid(ST_Transform(geom,4326)) ELSE ST_Transform(geom,4326) END ,8,0,null,
                      jsonb_build_object(
                          'code', upper(p_l0code||ghs) ,
                          'code_subcell', substr(ghs,length(code_end),length(ghs)) ,
                          'prefix', code_end,
                          'area', ST_Area(geom),
                          'side', SQRT(ST_Area(geom)),
                          'base', base
                          )
                      )::jsonb) AS gj
              FROM libosmcodes.ggeohash_GeomsFromVarbit(m.bit_string,false,p_srid,p_base,CASE WHEN p_grid_size % 2 = 1 THEN p_grid_size - 1 ELSE p_grid_size END,p_bbox)
            )
          ELSE '{}'::jsonb
          END
        )
      )
    FROM
    (
      SELECT bit_string,
      str_ggeohash_draw_cell_bybox((CASE WHEN p_bit_length = 0 THEN p_bbox ELSE str_ggeohash_decode_box2(bit_string,p_bbox) END),false,p_srid) AS geom_cell,
      CASE WHEN p_base = 16 THEN 'base16h' ELSE 'base32' END AS base,
      upper(CASE WHEN p_bit_length = 0 THEN p_l0code ELSE (p_l0code||vbit_to_baseh(bit_string,p_base,0)) END) AS code_end,
      (('{"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9, "B":10, "C":11, "D":12, "F":13, "G":14, "H":15, "J":16, "K":17, "L":18, "M":19, "N":20, "P":21, "Q":22, "R":23, "S":24, "T":25, "U":26, "V":27, "W":28, "X":29, "Y":30, "Z":31}'::jsonb)->(p_l0code))::int::bit(5) || bit_string AS code_end_bits
      FROM
      (
        SELECT str_ggeohash_encode3(ST_X(p_geom),ST_Y(p_geom),p_bbox,p_bit_length) AS bit_string
      ) r
    ) m
    LEFT JOIN LATERAL
    (
      SELECT (isolabel_ext|| (CASE WHEN length(m.code_end) = length(prefix) THEN '~' || index ELSE '~' || index || substr(m.code_end,length(prefix)+1,length(m.code_end)) END) ) AS short_code
      FROM libosmcodes.de_para r
      WHERE
      (
        ( (id::bit(64)<<27)::bit(20) # code_end_bits::bit(20) ) = 0::bit(20) OR ( (id::bit(64)<<27)::bit(20) # (code_end_bits::bit(15))::bit(20) ) = 0::bit(20)
        OR ( (id::bit(64)<<27)::bit(20) # (code_end_bits::bit(10))::bit(20) ) = 0::bit(20) OR ( (id::bit(64)<<27)::bit(20) # (code_end_bits::bit(5))::bit(20) ) = 0::bit(20)
      )
      AND  (id::bit(64))::bit(10) = p_jurisd_base_id::bit(10)
      AND CASE WHEN (id::bit(64)<<26)::bit(1) <> b'0' THEN ST_Contains(r.geom,p_geom) ELSE TRUE  END
    ) t
    ON TRUE
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.osmcode_encode(geometry(POINT),int,int,int,int,int[],text,int)
  IS 'Encodes geometry to OSMcode.'
;

CREATE or replace FUNCTION libosmcodes.osmcode_encode(
  lat          float,
  lon          float,
  p_base       int     DEFAULT 32,
  p_bit_length int     DEFAULT 40,
  p_srid       int     DEFAULT 9377,
  p_grid_size  int     DEFAULT 32,
  p_bbox       int[]   DEFAULT array[0,0,0,0],
  p_l0code     text    DEFAULT '0',
  p_jurisd_base_id int DEFAULT 170
) RETURNS jsonb AS $wrap$
  SELECT libosmcodes.osmcode_encode(
      ST_SetSRID(ST_MakePoint(lon,lat),4326),
      p_base,
      p_bit_length,
      p_srid,
      p_grid_size,
      p_bbox,
      p_l0code,
      p_jurisd_base_id
    )
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libosmcodes.osmcode_encode(float,float,int,int,int,int,int[],text,int)
  IS 'Encodes LatLon to OSMcode. Wrap for osmcode_encode(geometry)'
;

CREATE or replace FUNCTION api.osmcode_encode(
  uri    text,
  p_base int DEFAULT 32,
  grid   int DEFAULT 0
) RETURNS jsonb AS $wrap$
  SELECT libosmcodes.osmcode_encode(
    ST_Transform(v.geom,u.srid),
    p_base,
    CASE
    WHEN latLon[4] IS NOT NULL
    THEN
      CASE
      WHEN jurisd_base_id = 170 AND p_base = 32 THEN ((libosmcodes.uncertain_base16h(latLon[4]::int))/5)*5
      WHEN jurisd_base_id = 170 AND p_base = 16 THEN libosmcodes.uncertain_base16h(latLon[4]::int)
      WHEN jurisd_base_id = 76  AND p_base = 32 THEN ((libosmcodes.uncertain_base16hL01048km(latLon[4]::int))/5)*5
      WHEN jurisd_base_id = 76  AND p_base = 16 THEN libosmcodes.uncertain_base16hL01048km(latLon[4]::int)
      END
    ELSE 35
    END,
    u.srid,
    grid,
    u.bbox,
    u.l0code,
    u.jurisd_base_id
  )
  FROM ( SELECT str_geouri_decode(uri) ) t(latLon),
  LATERAL ( SELECT ST_SetSRID(ST_MakePoint(latLon[2],latLon[1]),4326) ) v(geom),
  LATERAL
  (
    SELECT CASE WHEN p_base = 16 THEN prefix_l016h ELSE prefix_l032 END AS l0code, jurisd_base_id, bbox, ST_SRID(geom) AS srid
    FROM libosmcodes.l0cover
    WHERE ST_Contains(geom_srid4326,v.geom)
  ) u
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION api.osmcode_encode(text,int,int)
  IS 'Encodes Geo URI to OSMcode. Wrap for osmcode_encode(geometry)'
;
-- EXPLAIN ANALYZE SELECT api.osmcode_encode('geo:3.461,-76.577');
-- EXPLAIN ANALYZE SELECT api.osmcode_encode('geo:-15.5,-47.8');

------------------
-- osmcode decode:

CREATE or replace FUNCTION api.osmcode_decode(
   p_code text,
   p_iso  text,
   p_base int     DEFAULT 32
) RETURNS jsonb AS $f$
  SELECT jsonb_build_object(
      'type', 'FeatureCollection',
      'features',
          (
            SELECT jsonb_agg(
                ST_AsGeoJSONb(ST_Transform(v.geom,4326),8,0,null,
                    jsonb_build_object(
                        'code', c.code,
                        'area', ST_Area(v.geom),
                        'side', SQRT(ST_Area(v.geom)),
                        'base', CASE WHEN p_base = 16 THEN 'base16h' ELSE 'base32' END
                        )
                    )::jsonb) AS gj
            FROM
            (
              SELECT DISTINCT code FROM regexp_split_to_table(upper(p_code),',') code
            ) c,
            LATERAL
            (
              --SELECT str_ggeohash_draw_cell_bybox(libosmcodes.osmcode_decode_xybox(substr(c.code,length(CASE WHEN p_base = 16 THEN prefix_l016h ELSE prefix_l032 END)+1),p_base,bbox),false,srid) AS geom
              SELECT str_ggeohash_draw_cell_bybox(str_ggeohash_decode_box2(baseh_to_vbit(substr(c.code,length(CASE WHEN p_base = 16 THEN prefix_l016h ELSE prefix_l032 END)+1),p_base),bbox),false,srid) AS geom
              FROM libosmcodes.l0cover
              WHERE jurisd_base_id = (('{"CO":170, "BR":76}'::jsonb)->(upper(p_iso)))::int
                AND (
                      CASE
                      WHEN p_base = 16 AND upper(p_iso) = 'CO' THEN prefix_l016h = substr(c.code,1,2)
                      WHEN p_base = 16 AND upper(p_iso) = 'BR' THEN prefix_l016h = upper(substr(c.code,1,1))
                      ELSE prefix_l032 = substr(c.code,1,1)
                      END
                    )
                AND
                    CASE
                    WHEN subcells_l032 IS NOT NULL AND upper(p_iso) = 'BR' AND p_base = 32 THEN (subcells_l032 @> array[substr(p_code,2,1)]::text[])
                    WHEN subcells_l016h IS NOT NULL AND upper(p_iso) = 'BR' AND p_base = 16 THEN (subcells_l016h @> array[substr(p_code,2,1)]::text[])
                    WHEN subcells_l032 IS NOT NULL AND upper(p_iso) = 'CO' AND p_base = 32 THEN (subcells_l032 @> array[substr(p_code,2,1)]::text[])
                    WHEN subcells_l016h IS NOT NULL AND upper(p_iso) = 'CO' AND p_base = 16 THEN (subcells_l016h @> array[substr(p_code,1,2)]::text[])
                    ELSE TRUE
                    END
            ) v
          )
      )
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION api.osmcode_decode(text,text,int)
  IS 'Decodes OSMcode.'
;
-- EXPLAIN ANALYZE SELECT api.osmcode_decode('HX7VgYKPW','CO');
-- EXPLAIN ANALYZE SELECT api.osmcode_decode('1,2,d3,2','CO',32);

CREATE or replace FUNCTION api.osmcode_decode_reduced(
   p_code text,
   p_iso  text
) RETURNS jsonb AS $f$
    SELECT api.osmcode_decode(
        (
            SELECT  prefix || substring(upper(p_code),2)
            FROM libosmcodes.de_para
            WHERE lower(isolabel_ext) = lower(x[1])
                AND index = substring(upper(p_code),1,1)
        ),
        x[2]
    )
    FROM (SELECT str_geocodeiso_decode(p_iso)) t(x)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION api.osmcode_decode_reduced(text)
  IS 'Decodes OSMcode reduced (base32). Wrap for osmcode_decode.'
;
-- EXPLAIN ANALYZE SELECT api.osmcode_decode_reduced('0JKRPV','CO-Itagui');

------------------
-- jurisdiction l0cover:

CREATE or replace FUNCTION api.jurisdiction_l0cover(
   p_iso  text,
   p_base int     DEFAULT 32
) RETURNS jsonb AS $f$
  SELECT jsonb_build_object(
    'type', 'FeatureCollection',
    'features',
      (
        SELECT jsonb_agg(
          ST_AsGeoJSONb(geom_srid4326,8,0,null,
              jsonb_strip_nulls(jsonb_build_object(
                  'code', prefix,
                  'area', ST_Area(geom),
                  'side', SQRT(ST_Area(geom)),
                  'base', CASE WHEN p_base = 16 THEN 'base16h' ELSE 'base32' END,
                  'index', index
                  ))
              )::jsonb) || (SELECT (api.jurisdiction_geojson_from_isolabel(p_iso))->'features')
        FROM
        (
          (
            SELECT geom_srid4326, geom,
                CASE
                WHEN p_base = 16 THEN prefix_l016h
                ELSE prefix_l032
                END AS prefix, null AS index
              FROM libosmcodes.l0cover
              WHERE jurisd_base_id = (('{"CO":170, "BR":76}'::jsonb)->(upper(p_iso)))::int
          )
          UNION ALL
          (
            SELECT ST_Transform(geom,4326) AS geom_srid4326, geom, prefix, index
              FROM libosmcodes.de_para
              WHERE lower(isolabel_ext) = lower((str_geocodeiso_decode(p_iso))[1])
          )
        ) t
      )
    )
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION api.jurisdiction_l0cover(text,int)
  IS 'Return l0cover.'
;
-- EXPLAIN ANALYZE SELECT api.jurisdiction_l0cover('CO-ANT-Itagui');


/*
CREATE or replace FUNCTION libgrid_co.xy_to_l0code(
  x int,
  y int,
  x0 int,   -- referencia de inicio do eixo x [x0,y0]
  y0 int,   -- referencia de inicio do eixo y [x0,y0]
  s int,
  columns int,
  p_base int DEFAULT 32
  ) RETURNS text AS $f$
  SELECT libgrid_co.digitVal_to_digit(array_position(libgrid_co.quadrants(),libgrid_co.xy_to_quadrant(x,y,x0,y0,s,columns))-1,p_base)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.xy_to_l0code(int,int,int,int,int,int,int)
 IS 'Retorna gid_code da célula L0 que contém xy.'
;*/
/*
CREATE or replace FUNCTION libgrid_co.digitVal_to_digit(v int, p_base int DEFAULT 32) RETURNS char as $f$
  -- v from 0 to 31.
  SELECT
    CASE
    WHEN p_base = 16 THEN substr('000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F', v*2+1, 2)
    ELSE substr('0123456789BCDFGHJKLMNPQRSTUVWXYZ', v+1, 1)
    END
$f$ LANGUAGE SQL IMMUTABLE;*/
/*
CREATE FUNCTION libgrid_co.quadrants() RETURNS int[] AS $f$
  SELECT array[0,45,37,38,39,31,32,33,25,26,27,28,29,18,19,20,21,22,23,12,13,14,15,16,17,8,9,10,3,4]
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.quadrants IS 'List of official quadrants.';
*/
/*
CREATE or replace FUNCTION libgrid_co.l0code_to_quadrant(
  p_l0code text,
  p_base int DEFAULT 32
  ) RETURNS int AS $f$
  SELECT
    CASE WHEN p_base = 16
    THEN (('{"00": "0", "01": 45, "02": 37, "03": 38, "04": 39, "05": 31, "06": 32, "07": 33, "08": 25, "09": 26, "0A": 27, "0B": 28, "0C": 29, "0D": 18, "0E": 19, "0F": 20, "10": 21, "11": 22, "12": 23, "13": 12, "14": 13, "15": 14, "16": 15, "17": 16, "18": 17, "19": 8, "1A": 9, "1B": 10, "1C": 3, "1D": 4, "1E": 0, "1F": 0}'::jsonb)->(p_l0code))::int
    ELSE (('{"0":0, "1": 45, "2": 37, "3": 38, "4": 39, "5": 31, "6": 32, "7": 33, "8": 25, "9": 26, "B": 27, "C": 28, "D": 29, "F": 18, "G": 19, "H": 20, "J": 21, "K": 22, "L": 23, "M": 12, "N": 13, "P": 14, "Q": 15, "R": 16, "S": 17, "T": 8, "U": 9, "V": 10, "W": 3, "X": 4, "Y": 0, "Z": 0}'::jsonb)->(p_l0code))::int
    END
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.l0code_to_quadrant(text,int)
 IS 'Retorna quadrante da célula L0.'
;*/

/*
CREATE or replace FUNCTION libgrid_co.osmcode_decode_xy(
  p_code text,
  p_base int DEFAULT 32,
  x0        int     DEFAULT 4180000,   -- referencia de inicio do eixo x [x0,y0]
  y0        int     DEFAULT 1035500,   -- referencia de inicio do eixo y [x0,y0]
  s         int     DEFAULT 262144,
  columns   int     DEFAULT 6,
  witherror boolean DEFAULT false
) RETURNS float[] as $f$
  SELECT CASE WHEN witherror THEN xy || array[p[3] - xy[1], p[4] - xy[2]] ELSE xy END
  FROM (
    SELECT array[(p[1] + p[3]) / 2.0, (p[2] + p[4]) / 2.0] AS xy, p
    FROM (SELECT libgrid_co.osmcode_decode_xybox(p_code,p_base,x0,y0,s,columns)) t1(p)
  ) t2
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_xy(text,int,int,int,int,int,boolean)
  IS 'Decodes Colombia-OSMcode into a XY point and optional error.'
;
-- SELECT libgrid_co.osmcode_decode_xy('HX7VGYKPW',32);

CREATE or replace FUNCTION libgrid_co.osmcode_decode_toXYPoint(
  p_code text,
  p_base int,
  p_srid      int DEFAULT 9377,      --
  x0          int DEFAULT 4180000,   -- referencia de inicio do eixo x [x0,y0]
  y0          int DEFAULT 1035500,   -- referencia de inicio do eixo y [x0,y0]
  s           int DEFAULT 262144,
  columns     int DEFAULT 6
) RETURNS geometry AS $f$
  SELECT ST_SetSRID(ST_MakePoint(xy[1],xy[2]),p_srid)  -- inverter X com Y?
  FROM ( SELECT libgrid_co.osmcode_decode_xy(p_code,p_base,x0,y0,s,columns,false) ) t(xy)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_toXYPoint(text,int,int,int,int,int)
  IS 'Decodes Colombia-OSM_code into a 9377 geometry.'
;

CREATE or replace FUNCTION libgrid_co.osmcode_decode_toPoint(
  p_code text,
  p_base int,
  p_srid      int DEFAULT 9377,      --
  x0          int DEFAULT 4180000,   -- referencia de inicio do eixo x [x0,y0]
  y0          int DEFAULT 1035500,   -- referencia de inicio do eixo y [x0,y0]
  s           int DEFAULT 262144,
  columns     int DEFAULT 6
) RETURNS geometry AS $f$
  SELECT ST_Transform( ST_SetSRID(ST_MakePoint(xy[1],xy[2]),p_srid) , 4326) -- trocar x y?
  FROM ( SELECT libgrid_co.osmcode_decode_xy(p_code,p_base,x0,y0,s,columns,false) ) t(xy)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_toPoint(text,int,int,int,int,int)
  IS 'Decodes Colombia-OSM_code into a WGS84 geometry.'
;

CREATE or replace FUNCTION libgrid_co.osmcode_decode(
  p_code text,
  p_base int,
  p_srid      int DEFAULT 9377,      --
  x0          int DEFAULT 4180000,   -- referencia de inicio do eixo x [x0,y0]
  y0          int DEFAULT 1035500,   -- referencia de inicio do eixo y [x0,y0]
  s           int DEFAULT 262144,
  columns     int DEFAULT 6
) RETURNS float[] AS $f$
  SELECT array[ST_Y(geom), ST_X(geom)]  -- LatLon
  FROM ( SELECT libgrid_co.osmcode_decode_toPoint(p_code,p_base,p_srid,x0,y0,s,columns) ) t(geom)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode(text,int,int,int,int,int,int)
  IS 'Decodes Colombia-OSM_code into WGS84 LatLon coordinates.'
;
*/


/*
-- cobertura L0 da colombia
DROP TABLE libgrid_co.L0_cell262km;
CREATE TABLE libgrid_co.L0_cell262km AS
SELECT r.gid,
       r.index,
       s.gid_code,
       ('{"0": "00", "1": "01", "2": "02", "3": "03", "4": "04", "5": "05", "6": "06", "7": "07", "8": "08", "9": "09", "B": "0a", "C": "0b", "D": "0c", "F": "0d", "G": "0e", "H": "0f", "J": "10", "K": "11", "L": "12", "M": "13", "N": "14", "P": "15", "Q": "16", "R": "17", "S": "18", "T": "19", "U": "1a", "V": "1b", "W": "1c", "X": "1d", "Y": "1e", "Z": "1f"}'::jsonb)->>s.gid_code AS gid_code_hex,
       r.bbox,
       r.geom
FROM
(
  SELECT ROW_NUMBER() OVER(ORDER BY index/6 DESC, index%6 ASC) as gid,
         libgrid_co.ij_to_bbox(index%6,index/6,4180000,1035500,262144) AS bbox,
         index,
         geom
  FROM
  (
    SELECT index, libgrid_co.ij_to_geom(index%6,index/6,4180000,1035500,262144,9377) AS geom
    FROM generate_series(0,47) AS index
  ) t
  WHERE ST_Intersects(geom, (SELECT ST_Transform(geom,9377) FROM optim.jurisdiction_geom WHERE isolabel_ext='CO') )
       AND index <> 42   -- remove island
) r, LATERAL (SELECT libgrid_co.digitVal_to_digit(gid::int) AS gid_code) AS s
;
*/
/*

CREATE or replace FUNCTION libgrid_co.ggeohash_GeomsFromPrefix(
  prefix text DEFAULT '',
  p_translate boolean DEFAULT false, -- true para converter em LatLong (WGS84 sem projeção)
  p_srid      int DEFAULT 4326,      -- WGS84
  p_base      int DEFAULT 32
) RETURNS TABLE(ghs text, geom geometry) AS $f$
  SELECT prefix||x, str_ggeohash_draw_cell_bybox(libgrid_co.osmcode_decode_xybox(prefix||x,p_base),p_translate,p_srid)
  FROM unnest('{0,1,2,3,4,5,6,7,8,9,B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,U,V,W,X,Y,Z}'::text[]) t(x)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.ggeohash_GeomsFromPrefix
  IS 'Return grid child-cell of Colombia-OSMcode. The parameter is the ggeohash the parent-cell, that will be a prefix for all child-cells.'
;
--SELECT libgrid_co.ggeohash_GeomsFromPrefix('HX7VGYKPW',true,9377);

CREATE or replace FUNCTION jsonb_array_to_floats(j_numbers jsonb) RETURNS float[] AS $f$
  select array_agg(x::float) from jsonb_array_elements(j_numbers) t(x)
$f$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION libgrid_co.gridGeoms_fromGeom(
  reference_geom geometry,
  code_size int DEFAULT 5,
  npoints integer DEFAULT 600
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
SELECT libgrid_co.gridGeoms_fromGeom( ST_SetSRID( ST_GeomFromText('POLYGON((-76.57770034945 3.46103000261,-76.57391243547 3.46103208489,-76.57390575999 3.45834677198,-76.57770076667 3.45834677198,-76.57770034945 3.46103000261))')  ,4326)  );

CREATE FUNCTION libgrid_co.cellGeom_to_bbox(r geometry) RETURNS float[] AS $f$
    SELECT array[min(st_X(g)), min(st_Y(g)), max(st_X(g)), max(st_Y(g))]
    FROM (SELECT (dp).geom as g  FROM (SELECT ST_DumpPoints(r) AS dp) t1 LIMIT 4) t2
$f$ LANGUAGE SQL IMMUTABLE;
*/

---------------
---------------
---------------
-- Main functions:
/*
CREATE FUNCTION libgrid_co.osmcode_encode_xy(
   p_geom geometry(Point,9377),
   code_size int DEFAULT 8,
   use_hex boolean DEFAULT false
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
  code_size int DEFAULT 8
) RETURNS text AS $wrap$
  SELECT libgrid_co.osmcode_encode_xy( ST_Transform(p_geom,9377), code_size )
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode(geometry(Point,4326), int)
  IS 'Encodes LatLon (WGS84) as the standard Colombia-OSMcode. Wrap for libgrid_co.osmcode_encode(geometry(Point,9377)).'
;

CREATE or replace FUNCTION libgrid_co.osmcode_encode(
   lat float,
   lon float,
   code_size int DEFAULT 8
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
*/


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

CREATE FUNCTION libgrid_co.osmcode_decode_xy(
   code text,
   witherror boolean DEFAULT false
) RETURNS float[] AS $f$
  SELECT CASE WHEN witherror THEN xy || array[bbox[3] - xy[1], bbox[4] - xy[2]] ELSE xy END
  FROM (
    SELECT array[(bbox[1] + bbox[3]) / 2, (bbox[2] + bbox[4]) / 2] AS xy, bbox
    FROM (SELECT libgrid_co.osmcode_decode_boxXY(code)) t1(bbox)
  ) t2
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_xy(text,boolean)
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
   code_size int DEFAULT 8
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
/*
CREATE FUNCTION libgrid_co.osmcode_encode_level0(pt geometry) RETURNS text AS $f$
  SELECT gid_code
  FROM libgrid_co.L0_cell262km
  WHERE ST_Contains(geom,pt)
$f$ LANGUAGE SQL IMMUTABLE;
*/

/*
CREATE FUNCTION libgrid_co.grid__GeomsFromPrefix(
  parent_code text,
  context_prefix text DEFAULT ''
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

/*
CREATE FUNCTION libgrid_co.grid__GeomsFromGeom(
  reference_geom geometry,
  npoints integer DEFAULT 200
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
*/

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
