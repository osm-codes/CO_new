--
--  Grade Estatistica de Colombia.
--

-- Carregar https://git.AddressForAll.org/pg_pubLib-v1/blob/main/src/pubLib05hcode-encdec.sql

CREATE EXTENSION IF NOT EXISTS postgis;
DROP SCHEMA IF EXISTS libgrid_co CASCADE;
CREATE SCHEMA libgrid_co;


CREATE VIEW vwlixo_municipios_unicos AS
  SELECT substring(isolabel_ext,8) as dupname, MAX(isolabel_ext) AS isolabel_ext
  FROM optim.jurisdiction j
  WHERE isolevel::int >2 AND isolabel_ext like 'CO%'
  GROUP BY 1 having count(*)=1 order by 1
;
COMMENT ON VIEW vwlixo_municipios_unicos
 IS 'Municípios colombianos com nomes únicos.'
;

CREATE VIEW vwlixo_municipios_reduced AS
  SELECT  'CO-' || substring(isolabel_ext,4,1) ||'-'|| substring(isolabel_ext,8) as isolabel_reduced, isolabel_ext
  FROM optim.jurisdiction j
  WHERE isolevel::int >2 AND isolabel_ext like 'CO-%' AND name not in ('Sabanalarga', 'Sucre', 'Guamal', 'Riosucio')
;
COMMENT ON VIEW vwlixo_municipios_reduced
 IS 'Municípios colombianos que podem ter suprimido o nome do estado.'
;

------------------
-- Helper functions:

CREATE or replace FUNCTION jsonb_array_to_floats(j_numbers jsonb) RETURNS float[] AS $f$
  select array_agg(x::float) from jsonb_array_elements(j_numbers) t(x)
$f$ LANGUAGE SQL IMMUTABLE;

CREATE or replace FUNCTION libgrid_co.digitVal_to_digit(v int) RETURNS char as $f$
  -- v from 0 to 31.
  SELECT substr('0123456789BCDFGHJKLMNPQRSTUVWXYZ', v+1, 1)
$f$ LANGUAGE SQL IMMUTABLE;

CREATE or replace FUNCTION libgrid_co.ij_to_xy(
  i int,   -- coluna
  j int,   -- linha
  x0 int,  -- referencia de inicio do eixo x [x0,y0]
  y0 int,  -- referencia de inicio do eixo y [x0,y0]
  side int -- lado da célula
) RETURNS int[] AS $f$
  SELECT array[
    x0 + i*side,
    y0 + j*side
  ]
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.ij_to_xy(int,int,int,int,int)
 IS 'Coordenadas a partir da posição da célula na matriz.'
;
--SELECT libgrid_co.ij_to_xy(1,1,4180000,1035500,262144);

CREATE or replace FUNCTION libgrid_co.geom_from_ij(
  i int,    -- coluna
  j int,    -- linha
  x0 int,   -- referencia de inicio do eixo x [x0,y0]
  y0 int,   -- referencia de inicio do eixo y [x0,y0]
  side int, -- lado da célula
  srid int  -- srid
  ) RETURNS geometry AS $f$
  SELECT str_ggeohash_draw_cell_bycenter(v[1]+side/2,v[2]+side/2,side/2,false,srid)
  FROM
  (
    SELECT libgrid_co.ij_to_xy(i,j,x0,y0,side) v
  ) t
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.geom_from_ij(int,int,int,int,int,int)
 IS 'Geometria a partir da posição da célula na matriz.'
;
--SELECT libgrid_co.geom_from_ij(0,0,4180000,1035500,262144,9377);

CREATE or replace FUNCTION libgrid_co.ij_to_bbox(
  i int,
  j int,
  x0 int,   -- referencia de inicio do eixo x [x0,y0]
  y0 int,   -- referencia de inicio do eixo y [x0,y0]
  s int
  ) RETURNS int[] AS $f$

  SELECT array[ x0+i*s, y0+j*s, x0+i*s+s, y0+j*s+s ]
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.ij_to_bbox(int,int,int,int,int)
 IS 'Retorna bbox da célula da matriz.'
;
-- SELECT libgrid_co.ij_to_bbox(0,0,4180000,1035500,262144);

CREATE or replace FUNCTION libgrid_co.ij_to_bbox(a int[]) RETURNS int[] AS $f$
  SELECT libgrid_co.ij_to_bbox(a[1],a[2],a[3],a[4],a[5])
$f$ LANGUAGE SQL IMMUTABLE;
-- SELECT libgrid_co.ij_to_bbox(array[0,0,4180000,1035500,262144]);

CREATE or replace FUNCTION libgrid_co.xy_to_bbox(
  x int,
  y int,
  x0 int,   -- referencia de inicio do eixo x [x0,y0]
  y0 int,   -- referencia de inicio do eixo y [x0,y0]
  s int
  ) RETURNS int[] AS $f$
  SELECT libgrid_co.ij_to_bbox(libgrid_co.xyS_collapseTo_ijS(x,y,x0,y0,s))
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.xy_to_bbox(int,int,int,int,int)
 IS 'Retorna bbox da célula que contém xy.'
;
-- SELECT libgrid_co.xy_to_bbox(4704288,1559788,4180000,1035500,262144);

CREATE or replace FUNCTION libgrid_co.xy_to_gid(
  x int,
  y int,
  x0 int,   -- referencia de inicio do eixo x [x0,y0]
  y0 int,   -- referencia de inicio do eixo y [x0,y0]
  s int,
  columns int
  ) RETURNS text AS $f$
  SELECT libgrid_co.digitVal_to_digit(array_position(libgrid_co.quadrantes(),libgrid_co.xy_to_quadrante(x,y,x0,y0,s,columns)))
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.xy_to_gid(int,int,int,int,int,int)
 IS 'Retorna gid_code da célula L0 que contém xy.'
;

CREATE or replace FUNCTION libgrid_co.xyS_collapseTo_ijS(x int, y int, x0 int, y0 int, s int) RETURNS int[] AS $f$
  SELECT array[ (x-x0)/s, (y-y0)/s, x0, y0, s ]
$f$ LANGUAGE SQL IMMUTABLE;
--SELECT libgrid_co.xyS_collapseTo_ijS(4442144,1297644,4180000,1035500,262144);

CREATE or replace  FUNCTION libgrid_co.xyS_collapseTo_ijS(xyS int[]) RETURNS int[] AS $wrap$
  SELECT libgrid_co.xys_collapseTo_ijs(xyS[1],xyS[2],xyS[3],xyS[4],xyS[5])
$wrap$ LANGUAGE SQL IMMUTABLE;
--SELECT libgrid_co.xyS_collapseTo_ijS(array[4442144,1297644,4180000,1035500,262144]);

CREATE or replace  FUNCTION libgrid_co.xy_to_quadrante(x int, y int, x0 int, y0 int, s int, columns int) RETURNS int AS $f$
  SELECT columns*ij[2] + ij[1]
  FROM ( SELECT libgrid_co.xyS_collapseTo_ijS(x,y,x0,y0,s) ) t(ij)
$f$ LANGUAGE SQL IMMUTABLE;
--SELECT libgrid_co.xy_to_quadrante(4442144,1297644,4180000,1035500,262144,6);

CREATE or replace  FUNCTION libgrid_co.xy_to_quadrante(xyd int[]) RETURNS int AS $wrap$
  SELECT libgrid_co.xy_to_quadrante(xyd[1],xyd[2],xyd[3],xyd[4],xyd[5],xyd[6])
$wrap$ LANGUAGE SQL IMMUTABLE;
--SELECT libgrid_co.xy_to_quadrante(array[4442144,1297644,4180000,1035500,262144,6]);


CREATE FUNCTION libgrid_co.quadrantes() RETURNS int[] AS $f$
  SELECT array[45,37,38,39,31,32,33,25,26,27,28,29,18,19,20,21,22,23,12,13,14,15,16,17,8,9,10,3,4]
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.quadrantes IS 'List of official quadrants.';

------------------
-- Decode:

CREATE or replace FUNCTION libgrid_co.osmcode_decode_xybox(
   p_code  text,
   use_hex boolean default false
) RETURNS float[] AS $f$
  SELECT str_ggeohash_decode_box(  -- returns codeBox
           CASE WHEN use_hex THEN substr(p_code,3) ELSE substr(p_code,2) END,
           CASE WHEN use_hex THEN 4 ELSE 5 END, -- code_digit_bits
           CASE WHEN use_hex
           THEN
           '{"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9, "a":10, "b":11, "c":12, "d":13, "e":14, "f":15}'::jsonb
           ELSE
           '{"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9, "b":10, "c":11, "d":12, "f":13, "g":14, "h":15, "j":16, "k":17, "l":18, "m":19, "n":20, "p":21, "q":22, "r":23, "s":24, "t":25, "u":26, "v":27, "w":28, "x":29, "y":30, "z":31}'::jsonb
           END,
           libgrid_co.ij_to_bbox(b%6,b/6,4180000,1035500,262144)  -- cover-cell specification
         ) AS codebox
  FROM
  (
    SELECT
      CASE WHEN use_hex
      THEN (('{"00": "0", "01": 45, "02": 37, "03": 38, "04": 39, "05": 31, "06": 32, "07": 33, "08": 25, "09": 26, "0a": 27, "0b": 28, "0c": 29, "0d": 18, "0e": 19, "0f": 20, "10": 21, "11": 22, "12": 23, "13": 12, "14": 13, "15": 14, "16": 15, "17": 16, "18": 17, "19": 8, "1a": 9, "1b": 10, "1c": 3, "1d": 4, "1e": 0, "1f": 0}'::jsonb)->(substr(p_code,1,2)))::int
      ELSE (('{"0":0, "1": 45, "2": 37, "3": 38, "4": 39, "5": 31, "6": 32, "7": 33, "8": 25, "9": 26, "B": 27, "C": 28, "D": 29, "F": 18, "G": 19, "H": 20, "J": 21, "K": 22, "L": 23, "M": 12, "N": 13, "P": 14, "Q": 15, "R": 16, "S": 17, "T": 8, "U": 9, "V": 10, "W": 3, "X": 4, "Y": 0, "Z": 0}'::jsonb)->(substr(p_code,1,1)))::int
      END AS giid
  ) l(b)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_xybox(text,boolean)
  IS 'Decodes Colombia-OSMcode geocode into a bounding box of its cell.'
;
-- SELECT libgrid_co.osmcode_decode_xybox('HX7VGYKPW');

CREATE or replace FUNCTION libgrid_co.osmcode_decode_xy(
   p_code text,
   use_hex boolean default false,
   witherror boolean default false
) RETURNS float[] as $f$
  SELECT CASE WHEN witherror THEN xy || array[p[3] - xy[1], p[4] - xy[2]] ELSE xy END
  FROM (
    SELECT array[(p[1] + p[3]) / 2.0, (p[2] + p[4]) / 2.0] AS xy, p
    FROM (SELECT libgrid_co.osmcode_decode_xybox(p_code,use_hex)) t1(p)
  ) t2
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_xy(text,boolean,boolean)
  IS 'Decodes Colombia-OSMcode into a XY point and optional error.'
;
-- SELECT libgrid_co.osmcode_decode_xy('HX7VGYKPW',true);

CREATE or replace FUNCTION libgrid_co.osmcode_decode_toXYPoint(p_code text) RETURNS geometry AS $f$
  SELECT ST_SetSRID(ST_MakePoint(xy[1],xy[2]),9377)  -- inverter X com Y?
  FROM ( SELECT libgrid_co.osmcode_decode_xy(p_code,false,false) ) t(xy)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_decode_toXYPoint(p_code text)
  IS 'Decodes Colombia-OSM_code into a 9377 geometry.'
;

CREATE or replace FUNCTION libgrid_co.osmcode_decode_toPoint(p_code text) RETURNS geometry AS $f$
  SELECT ST_Transform( ST_SetSRID(ST_MakePoint(xy[1],xy[2]),9377) , 4326) -- trocar x y?
  FROM ( SELECT libgrid_co.osmcode_decode_xy(p_code,false,false) ) t(xy)
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

CREATE or replace FUNCTION libgrid_co.ggeohash_GeomsFromPrefix(
  prefix text DEFAULT '',
  p_translate boolean DEFAULT false, -- true para converter em LatLong (WGS84 sem projeção)
  p_srid      int DEFAULT 4326,          -- WGS84
  use_hex     boolean default false
) RETURNS TABLE(ghs text, geom geometry) AS $f$
  SELECT prefix||x, str_ggeohash_draw_cell_bybox(libgrid_co.osmcode_decode_xybox(prefix||x,use_hex),p_translate,p_srid)
  FROM unnest(CASE WHEN use_hex THEN '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F}'::text[] ELSE '{0,1,2,3,4,5,6,7,8,9,B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,U,V,W,X,Y,Z}'::text[] END ) t(x)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.ggeohash_GeomsFromPrefix
  IS 'Return grid child-cell of Colombia-OSMcode. The parameter is the ggeohash the parent-cell, that will be a prefix for all child-cells.'
;
--SELECT libgrid_co.ggeohash_GeomsFromPrefix('HX7VGYKPW',true,9377);


------------------
-- de-para:

CREATE TABLE libgrid_co.de_para (
  isolabel_ext text NOT NULL,
  subprefix text,
  prefix text NOT NULL,
  subcells text[],
  is_subdiv_default boolean DEFAULT false,
  geom geometry
);

INSERT INTO libgrid_co.de_para(isolabel_ext,subprefix,prefix,subcells,is_subdiv_default,geom) VALUES
('CO-ANT-Itagui'  ,'C','8UR',null,true,null),
('CO-ANT-Itagui'  ,'O','8UQ',null,false,null),
('CO-ANT-Medellin','C','8U' ,null,true,null),
('CO-ANT-Medellin','E','9J' ,null,false,null),
('CO-ANT-Medellin','N','8V' ,null,false,null),
('CO-DC-Bogota'   ,'C','H'  ,null,true,null),
('CO-BOY-Busbanza','C','B57','{H,G,C,B}'::text[],false,null),
('CO-BOY-Busbanza','C','B5L','{J,5,7,4,6,1,3,0,2}'::text[],true,null),
('CO-BOY-Busbanza','C','B55','{X,Z,W,Y,V}'::text[],false,null),
('CO-BOY-Busbanza','C','B5J','{P,R,N,Q,K}'::text[],false,null)
;

CREATE or replace FUNCTION libgrid_co.update_de_para(
  p_isolabel_ext text DEFAULT '',
  p_prefix text DEFAULT ''
) RETURNS void AS $f$
  UPDATE libgrid_co.de_para
  SET geom =
  (
      SELECT ST_Intersection(
          (str_ggeohash_draw_cell_bybox(libgrid_co.osmcode_decode_xybox(p_prefix),true,9377)),
          (SELECT geom
          FROM optim.vw01full_jurisdiction_geom g
          WHERE lower(g.isolabel_ext) = lower(p_isolabel_ext) AND jurisd_base_id = 170)
      )
  )
  WHERE prefix= p_prefix AND isolabel_ext = p_isolabel_ext
$f$ LANGUAGE SQL VOLATILE;
SELECT libgrid_co.update_de_para('CO-ANT-Itagui','8UR');
SELECT libgrid_co.update_de_para('CO-ANT-Itagui','8UQ');
SELECT libgrid_co.update_de_para('CO-ANT-Medellin','8U');
SELECT libgrid_co.update_de_para('CO-ANT-Medellin','9J');
SELECT libgrid_co.update_de_para('CO-ANT-Medellin','8V');
SELECT libgrid_co.update_de_para('CO-DC-Bogota','H');
SELECT libgrid_co.update_de_para('CO-BOY-Busbanza','B57');
SELECT libgrid_co.update_de_para('CO-BOY-Busbanza','B5L');
SELECT libgrid_co.update_de_para('CO-BOY-Busbanza','B55');
SELECT libgrid_co.update_de_para('CO-BOY-Busbanza','B5J');


------------------
-- Encode:

CREATE or replace FUNCTION libgrid_co.osmcode_encode2_ptgeom(
   p_geom     geometry(POINT),
   code_size  int       default 8,
   view_child boolean   default false,
   use_hex    boolean   default false
) RETURNS jsonb AS $f$
    SELECT jsonb_build_object(
        'type', 'FeatureCollection',
        'features',
            (
                ST_AsGeoJSONb(
                str_ggeohash_draw_cell_bybox(bbox,true,9377),
                    6,0,null,
                    jsonb_strip_nulls(jsonb_build_object(
                        'code', code_end,
                        'short_code', short_code,
                        'area', ST_Area(str_ggeohash_draw_cell_bybox(bbox,false,9377)),
                        'side', SQRT(ST_Area(str_ggeohash_draw_cell_bybox(bbox,false,9377)))
                        ))
                )::jsonb ||
                CASE
                WHEN view_child IS TRUE
                THEN
                    (
                    SELECT jsonb_agg(
                        ST_AsGeoJSONb(ST_Transform(geom,4326),6,0,null,
                            jsonb_build_object(
                                'code', ghs ,
                                'code_subcell', substr(ghs,length(code_end)+1,length(ghs)) ,
                                'prefix', code_end,
                                'area', ST_Area(geom),
                                'side', SQRT(ST_Area(geom))
                                )
                            )::jsonb ) AS gj FROM libgrid_co.ggeohash_GeomsFromPrefix(code_end,false,9377,use_hex)
                    )
                ELSE '{}'::jsonb
                END
            )
        )
    FROM
    (
        SELECT r.*,
        CASE WHEN (code_size-1) = 0 THEN r.bbbox    ELSE (jsonb_array_to_floats(j->'box')) END AS bbox,
        CASE WHEN (code_size-1) = 0 THEN upper(r.gid_code) ELSE upper(r.gid_code||(j->>'code'))          END AS code_end
        FROM
        (
          SELECT
          CASE WHEN use_hex
          THEN ('{"0": "00", "1": "01", "2": "02", "3": "03", "4": "04", "5": "05", "6": "06", "7": "07", "8": "08", "9": "09", "B": "0a", "C": "0b", "D": "0c", "F": "0d", "G": "0e", "H": "0f", "J": "10", "K": "11", "L": "12", "M": "13", "N": "14", "P": "15", "Q": "16", "R": "17", "S": "18", "T": "19", "U": "1a", "V": "1b", "W": "1c", "X": "1d", "Y": "1e", "Z": "1f"}'::jsonb)->>u.gid_code
          ELSE u.gid_code
          END AS gid_code,
          CASE
          WHEN (code_size-1) = 0
          THEN '{}'::jsonb
          ELSE
              str_ggeohash_encode2(
                  u.a, u.b,
                  (code_size-1),
                  CASE WHEN use_hex THEN 4 ELSE 5 END,
                  CASE WHEN use_hex THEN '0123456789abcdef' ELSE '0123456789BCDFGHJKLMNPQRSTUVWXYZ' END,
                  bbbox  -- cover-cell specification
                  )
          END AS j,
          bbbox
          FROM
          (
            SELECT t.*,
                  libgrid_co.xy_to_bbox(a::int,b::int,4180000,1035500,262144)  AS bbbox,
                  libgrid_co.xy_to_gid(a::int,b::int,4180000,1035500,262144,6) AS gid_code
            FROM
            (
                SELECT geom, ST_X(a.geom) AS a , ST_Y(a.geom) AS b
                FROM
                (
                    SELECT CASE WHEN ST_SRID(p_geom)=9377 THEN p_geom ELSE ST_Transform(p_geom,9377) END
                ) a(geom)
            ) t
          ) u
        ) r
    ) s
    LEFT JOIN LATERAL
    (
            SELECT (isolabel_ext|| CASE WHEN subcells IS NULL THEN '-' || subprefix ELSE '' END || (CASE WHEN length((s.j->>'code')) +1  = length(prefix) THEN '' ELSE   '~' || substr((s.j->>'code'),length(prefix),length((s.j->>'code'))) END) ) AS short_code
            FROM libgrid_co.de_para r
            WHERE ST_Contains(r.geom,p_geom) AND prefix = substr(gid_code||(j->>'code'),1,length(prefix))
    ) t
    ON TRUE
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode2_ptgeom(geometry(POINT),int,boolean,boolean)
  IS 'Encodes geometry (of standard Colombia projection) as standard Colombia-OSMcode.'
;
-- SELECT libgrid_co.osmcode_encode2_ptgeom( ST_SetSRID(ST_MakePoint(-76.577,3.461),4326) );

CREATE or replace FUNCTION libgrid_co.osmcode_encode2(
   lat        float,
   lon        float,
   code_size  int     default 8,
   view_child boolean default false,
   use_hex    boolean default false
) RETURNS jsonb AS $wrap$
  SELECT libgrid_co.osmcode_encode2_ptgeom(
      ST_SetSRID(ST_MakePoint(lon,lat),4326),
      code_size,
      view_child,
      use_hex
    )
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode2(float,float,int,boolean,boolean)
  IS 'Encodes LatLon as the standard Colombia-OSMcode. Wrap for osmcode_encode2_ptgeom(geometry)'
;

CREATE or replace FUNCTION libgrid_co.uncertain_to_code_size(
  u int
) RETURNS int AS $f$
  -- GeoURI's uncertainty value "is the radius of the disk that represents uncertainty geometrically"
  SELECT CASE -- discretization by "snap to size-levels"
     WHEN s < 5      THEN 8
     WHEN s < 27     THEN 7
     WHEN s < 151    THEN 6
     WHEN s < 852    THEN 5
     WHEN s < 4820   THEN 4
     WHEN s < 27266  THEN 3
     WHEN s < 154242 THEN 2
     ELSE                 1
     END
  FROM (SELECT u*2) t(s)
$f$ LANGUAGE SQL IMMUTABLE;

CREATE or replace FUNCTION libgrid_co.osmcode_encode2(
  uri        text,
  view_child boolean default false,
  use_hex    boolean default false
) RETURNS jsonb AS $wrap$
  SELECT libgrid_co.osmcode_encode2(
    latLon[1],
    latLon[2],
    CASE WHEN latLon[4] IS NOT NULL THEN libgrid_co.uncertain_to_code_size(latLon[4]::int) ELSE 8 END,
    view_child,
    use_hex
    )
  FROM (SELECT str_geouri_decode(uri)) t(latLon)
$wrap$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.osmcode_encode2(text,boolean,boolean)
  IS 'Encodes Geo URI to a standard Colombia-OSMcode. Wrap for osmcode_encode2(lat,lon)'
;
-- SELECT libgrid_co.osmcode_encode2('geo:3.461,-76.577');


------------------
-- Decode:

CREATE or replace FUNCTION libgrid_co.decode_geojson(
   p_code  text,
   use_hex boolean default false
) RETURNS jsonb AS $f$
  SELECT  jsonb_build_object(
    'type' , 'FeatureCollection',
    'features', ARRAY[ ST_AsGeoJSONb(ST_Transform(geom,4326),6,0,null,jsonb_build_object('code', upper(p_code), 'area', ST_Area(geom),
    'side', SQRT(ST_Area(geom))
    ))::jsonb ]  )
    FROM (SELECT str_ggeohash_draw_cell_bybox(libgrid_co.osmcode_decode_xybox(upper(p_code),use_hex),false,9377)) t(geom)
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.decode_geojson(text,boolean)
  IS 'Decodes Colombia-OSMcode.'
;
--SELECT libgrid_co.decode_geojson('HX7VgYKPW');

CREATE or replace FUNCTION libgrid_co.isolabel_geojson(
   p_isolabel_ext text
) RETURNS jsonb AS $f$
    SELECT jsonb_build_object(
        'type', 'FeatureCollection',
        'features',
            (
                ST_AsGeoJSONb(
                    geom,
                    6,0,null,
                    jsonb_build_object(
                        'osm_id', osm_id,
                        'jurisd_base_id', jurisd_base_id,
                        'jurisd_local_id', jurisd_local_id,
                        'parent_id', parent_id,
                        'admin_level', admin_level,
                        'name', name,
                        'parent_abbrev', parent_abbrev,
                        'abbrev', abbrev,
                        'wikidata_id', wikidata_id,
                        'lexlabel', lexlabel,
                        'isolabel_ext', isolabel_ext,
                        'lex_urn', lex_urn,
                        'name_en', name_en,
                        'isolevel', isolevel,
                        'area', ST_Area(geom,true),
                        'jurisd_base_id', jurisd_base_id
                        )
                    )::jsonb
            )
        )
    FROM optim.vw01full_jurisdiction_geom g
    WHERE ( (lower(g.isolabel_ext) = lower(p_isolabel_ext) ) OR ( lower(g.isolabel_ext) = lower((SELECT isolabel_ext FROM vwlixo_municipios_unicos WHERE lower(dupname) = lower( split_part(p_isolabel_ext,'-',2) ))) ) OR ( lower(g.isolabel_ext) = lower((SELECT isolabel_ext FROM vwlixo_municipios_reduced WHERE lower(isolabel_reduced) = lower(p_isolabel_ext))) ) ) /*AND jurisd_base_id = 170*/
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.isolabel_geojson(text)
  IS 'Return geojson of jurisdiction.'
;
--SELECT libgrid_co.isolabel_geojson('CO-A-Itagui');

CREATE or replace FUNCTION str_geocodeuri_decode(uri text)
RETURNS text[] as $f$
  SELECT
    CASE
      WHEN cardinality(a)=5 THEN array[a[1] || '-' ||  a[2] || '-' || a[3]]::text[] || array[a[4]] || a[5]
      WHEN cardinality(a)=4 THEN a[1] || '-' ||  a[2] || '-' || a[3] || array['C']::text[] || a[4]
      ELSE NULL
    END
  FROM (
    SELECT regexp_split_to_array (uri,'(-|~)')::text[] AS a
  ) t
$f$ LANGUAGE SQL IMMUTABLE;
--COMMENT ON FUNCTION str_geocodeuri_decode(text)
  --IS 'Decodes standard GeoURI of latitude and longitude into float array.'
--;
--SELECT str_geocodeuri_decode('co-ant-itagui~12345');

CREATE or replace FUNCTION libgrid_co.decode_geojson2(
   p_code text
) RETURNS jsonb AS $f$
    SELECT libgrid_co.decode_geojson(
        (
            SELECT  prefix || (str_geocodeuri_decode(p_code))[3]
            FROM libgrid_co.de_para
            WHERE lower(isolabel_ext) = lower((str_geocodeuri_decode(p_code))[1])
                AND lower(subprefix)  = lower((str_geocodeuri_decode(p_code))[2])
                AND
                    CASE
                    WHEN subcells IS NOT NULL
                    THEN (subcells @> array[substr((str_geocodeuri_decode(p_code))[3],1,1)]::text[])
                    ELSE TRUE
                    END
        )
    )
$f$ LANGUAGE SQL IMMUTABLE;
--COMMENT ON FUNCTION libgrid_co.decode_geojson2(text)
  --IS 'Decodes Colombia-OSMcode.'
--;
--SELECT libgrid_co.decode_geojson2('CO-ANT-Itagui-O~UWCFR');
--SELECT libgrid_co.decode_geojson2('CO-ANT-Itagui-C~JKRPV');
--SELECT libgrid_co.decode_geojson2('CO-ANT-Itagui~JKRPV');

CREATE or replace FUNCTION str_geocodeuri_decode_isolevel1_only(uri text)
RETURNS text[] as $f$
  SELECT
    CASE
      WHEN cardinality(a)=4 THEN (SELECT isolabel_ext FROM vwlixo_municipios_unicos WHERE lower(dupname) = lower(a[2]) ) || array[a[3]] || a[4]
      WHEN cardinality(a)=3 THEN (SELECT isolabel_ext FROM vwlixo_municipios_unicos WHERE lower(dupname) = lower(a[2]) ) || array['~']::text[] || a[3]
      ELSE NULL
    END
  FROM (
    SELECT regexp_split_to_array (uri,'(-|~)')::text[] AS a
  ) t
$f$ LANGUAGE SQL IMMUTABLE;
--SELECT str_geocodeuri_decode_isolevel1_only('CO-Itagui-O~UWCFR');

CREATE or replace FUNCTION libgrid_co.decode_geojson_isolevel1_only(
   p_code text
) RETURNS jsonb AS $f$
    SELECT libgrid_co.decode_geojson(
        (
            SELECT  prefix || (str_geocodeuri_decode_isolevel1_only(p_code))[3]
            FROM libgrid_co.de_para
            WHERE lower(isolabel_ext) = lower((str_geocodeuri_decode_isolevel1_only(p_code))[1])
                AND
                    CASE
                    WHEN (str_geocodeuri_decode_isolevel1_only(p_code))[2] = '~' THEN is_subdiv_default IS TRUE
                    ELSE lower(subprefix)  = lower((str_geocodeuri_decode_isolevel1_only(p_code))[2])
                    END
                AND
                    CASE
                    WHEN subcells IS NOT NULL
                    THEN (subcells @> array[substr((str_geocodeuri_decode_isolevel1_only(p_code))[3],1,1)]::text[])
                    ELSE TRUE
                    END
        )
    )
$f$ LANGUAGE SQL IMMUTABLE;

CREATE or replace FUNCTION str_geocodeuri_decode_isolevel2_abbrev(uri text)
RETURNS text[] as $f$
  SELECT
    CASE
      WHEN cardinality(a)=5 THEN (SELECT isolabel_ext FROM vwlixo_municipios_reduced WHERE lower(isolabel_reduced) = lower(a[1] ||'-'|| a[2] ||'-'|| a[3]) ) || array[a[4]] || a[5]
      WHEN cardinality(a)=4 THEN (SELECT isolabel_ext FROM vwlixo_municipios_reduced WHERE lower(isolabel_reduced) = lower(a[1] ||'-'|| a[2] ||'-'|| a[3]) ) || array['~']::text[] || a[4]
      ELSE NULL
    END
  FROM (
    SELECT regexp_split_to_array (uri,'(-|~)')::text[] AS a
  ) t
$f$ LANGUAGE SQL IMMUTABLE;
--SELECT str_geocodeuri_decode_isolevel2_abbrev('CO-A-Itagui-O~UWCFR');

CREATE or replace FUNCTION libgrid_co.decode_geojson_isolevel2_abbrev(
   p_code text
) RETURNS jsonb AS $f$
    SELECT libgrid_co.decode_geojson(
        (
            SELECT  prefix || (str_geocodeuri_decode_isolevel2_abbrev(p_code))[3]
            FROM libgrid_co.de_para
            WHERE lower(isolabel_ext) = lower((str_geocodeuri_decode_isolevel2_abbrev(p_code))[1])
                AND
                    CASE
                    WHEN (str_geocodeuri_decode_isolevel2_abbrev(p_code))[2] = '~' THEN is_subdiv_default IS TRUE
                    ELSE lower(subprefix)  = lower((str_geocodeuri_decode_isolevel2_abbrev(p_code))[2])
                    END
                AND
                    CASE
                    WHEN subcells IS NOT NULL
                    THEN (subcells @> array[substr((str_geocodeuri_decode_isolevel2_abbrev(p_code))[3],1,1)]::text[])
                    ELSE TRUE
                    END
        )
    )
$f$ LANGUAGE SQL IMMUTABLE;
--SELECT libgrid_co.decode_geojson_isolevel2_abbrev('CO-A-Itagui-O~UWCFR');


CREATE or replace FUNCTION str_geocodeuri_decode_de_para(uri text)
RETURNS text[] as $f$
  SELECT
    CASE
      WHEN cardinality(a)=4 AND u IS NULL THEN COALESCE((SELECT isolabel_ext FROM vwlixo_municipios_reduced WHERE lower(isolabel_reduced) = lower(a[1] ||'-'|| a[2] ||'-'|| a[3]) ),a[1] || '-' ||  a[2] || '-' || a[3]) || array[a[4]]
      WHEN cardinality(a)=3 AND u IS NULL THEN (SELECT isolabel_ext FROM vwlixo_municipios_unicos WHERE lower(dupname) = lower(a[2]) ) || array[a[3]]
      WHEN cardinality(a)=2 AND u IS NOT NULL THEN (SELECT isolabel_ext FROM vwlixo_municipios_unicos WHERE lower(dupname) = lower(a[2]) ) || u
      WHEN cardinality(a)=3 AND u IS NOT NULL THEN COALESCE((SELECT isolabel_ext FROM vwlixo_municipios_reduced WHERE lower(isolabel_reduced) = lower(a[1] ||'-'|| a[2] ||'-'|| a[3]) ),a[1] || '-' ||  a[2] || '-' || a[3]) || u
      ELSE NULL
    END
  FROM (
    SELECT regexp_split_to_array (regexp_replace(uri,'~$','','ig'),'(-)')::text[] AS a, (regexp_match(uri,'(~)')) AS u
  ) t
$f$ LANGUAGE SQL IMMUTABLE;
--SELECT str_geocodeuri_decode_de_para('CO-Itagui-O');
--SELECT str_geocodeuri_decode_de_para('CO-A-Itagui-O');
--SELECT str_geocodeuri_decode_de_para('CO-ANT-Itagui-O');
--SELECT str_geocodeuri_decode_de_para('CO-Itagui~');
--SELECT str_geocodeuri_decode_de_para('CO-A-Itagui~');
--SELECT str_geocodeuri_decode_de_para('CO-ANT-Itagui~');

CREATE or replace FUNCTION libgrid_co.decode_geojson_de_para(
   p_code text
) RETURNS jsonb AS $f$
  SELECT  jsonb_build_object(
    'type' , 'FeatureCollection',
    'features', ARRAY[ ST_AsGeoJSONb(ST_Transform(geom,4326),6,0,null,jsonb_build_object('code', upper(prefix), 'area', ST_Area(geom),
    'side', SQRT(ST_Area(geom))
    ))::jsonb ]  )
    FROM libgrid_co.de_para
    WHERE lower(isolabel_ext) = lower((str_geocodeuri_decode_de_para(p_code))[1])
          AND
        CASE
          WHEN (str_geocodeuri_decode_de_para(p_code))[2] = '~' THEN is_subdiv_default IS TRUE
          ELSE lower(subprefix)  = lower((str_geocodeuri_decode_de_para(p_code))[2])
        END
$f$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION libgrid_co.decode_geojson_de_para(text)
  IS 'Decodes Colombia-OSMcode.'
;
--SELECT libgrid_co.decode_geojson_de_para('CO-Itagui-C');
--SELECT libgrid_co.decode_geojson_de_para('CO-A-Itagui-C');
--SELECT libgrid_co.decode_geojson_de_para('CO-A-Itagui~');
--SELECT libgrid_co.decode_geojson_de_para('CO-BOY-Busbanza-C');





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
    SELECT index, libgrid_co.geom_from_ij(index%6,index/6,4180000,1035500,262144,9377) AS geom
    FROM generate_series(0,47) AS index
  ) t
  WHERE ST_Intersects(geom, (SELECT ST_Transform(geom,9377) FROM optim.jurisdiction_geom WHERE isolabel_ext='CO') )
       AND index <> 42   -- remove island
) r, LATERAL (SELECT libgrid_co.digitVal_to_digit(gid::int) AS gid_code) AS s
;
*/


--CREATE FUNCTION libgrid_co.gridGeoms_fromGeom(
  --reference_geom geometry,
  --code_size int default 5,
  --npoints integer default 600
--) RETURNS TABLE (gid int, code text, geom geometry(POLYGON,9377))
--AS $f$
    --SELECT ROW_NUMBER() OVER() as gid, -- ou bigint geocode_to_binary(j->>'code')
           --j->>'code' AS code,
           --str_ggeohash_draw_cell_bybox(jsonb_array_to_floats(j->'box'),false,9377) AS geom
    --FROM (
      --SELECT  distinct libgrid_co.osmcode_encode2_ptgeom(geom,code_size) as j
      --FROM ST_DumpPoints(  ST_GeneratePoints(reference_geom,npoints)  ) t1(d)
    --) t2
    --ORDER BY j->>'code'
--$f$ LANGUAGE SQL IMMUTABLE;
-- SELECT libgrid_co.gridGeoms_fromGeom( ST_SetSRID( ST_GeomFromText('POLYGON((-76.57770034945 3.46103000261,-76.57391243547 3.46103208489,-76.57390575999 3.45834677198,-76.57770076667 3.45834677198,-76.57770034945 3.46103000261))')  ,4326)  );

--CREATE FUNCTION libgrid_co.cellGeom_to_bbox(r geometry) RETURNS float[] AS $f$
    --SELECT array[min(st_X(g)), min(st_Y(g)), max(st_X(g)), max(st_Y(g))]
    --FROM (SELECT (dp).geom as g  FROM (SELECT ST_DumpPoints(r) AS dp) t1 LIMIT 4) t2
--$f$ LANGUAGE SQL IMMUTABLE;


---------------
---------------
---------------
-- Main functions:
/*
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
   witherror boolean default false
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

/*
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
