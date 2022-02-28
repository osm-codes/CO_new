
DO $a$
BEGIN

RAISE NOTICE E'--- Function libgrid_co.osmcode_encode --- \n   -- Montañitas: --';
ASSERT libgrid_co.osmcode_encode('geo:3.46103000261,-76.57770034945') = 'GF1ZDW6NY',    'fail in GF1ZDW6NY';
ASSERT libgrid_co.osmcode_encode('geo:3.46103208489,-76.57391243547') = 'GF1ZSNQV7',    'fail in GF1ZSNQV7';
ASSERT libgrid_co.osmcode_encode('geo:3.45834677198,-76.57390575999') = 'GF1ZLKNU4',    'fail in GF1ZLKNU4';
ASSERT libgrid_co.osmcode_encode('geo:3.45834677198,-76.57770076667') = 'GF1Z6T4KC',    'fail in GF1Z6T4KC';
RAISE NOTICE '   -- Bogotá: --';
ASSERT libgrid_co.osmcode_encode('geo:4.711111,-74.072222') = 'HX7VGYKPW',              'fail in HX7VGYKPW';
END;$a$;

RAISE NOTICE '--- Function libgrid_co.osmcode_decode: ---';
ASSERT round( ST_Area( libgrid_co.osmcode_decode_polyXY('GF1ZDW6NY') ), 7 ) = 2.3458051, 'fail in GF1ZDW6NY';
ASSERT round( ST_Area( libgrid_co.osmcode_decode_polyXY('GF1ZSNQV7') ), 7 ) = 2.3458051, 'fail in GF1ZSNQV7';
ASSERT round( ST_Area( libgrid_co.osmcode_decode_polyXY('GF1ZLKNU4') ), 7 ) = 2.3458051, 'fail in GF1ZLKNU4';
ASSERT round( ST_Area( libgrid_co.osmcode_decode_polyXY('HX7VGYKPW') ), 7 ) = 2.3458051, 'fail in HX7VGYKPW';

END;$a$;

/*
SELECT round( ST_Area( libgrid_co.osmcode_decode_polyXY('GF1ZDW6NY') ), 7 );

SELECT libgrid_co.osmcode_encode('geo:3.46103000261,-76.57770034945');

SELECT libgrid_co.osmcode_encode('geo:3.46103208489,-76.57391243547');

SELECT libgrid_co.osmcode_encode('geo:3.45834677198,-76.57390575999');

SELECT libgrid_co.osmcode_encode('geo:3.45834677198,-76.57770076667');

SELECT libgrid_co.osmcode_encode('geo:4.711111,-74.072222');

----

SELECT libgrid_co.osmcode_decode('HX7VGYKPW');

DROP TABLE fredy2;
DROP TABLE fredy1;

CREATE TABLE fredy1 AS
  SELECT gid,geouri, j->>'code' AS code,  substr(j->>'code',5,4) as endereco,
         st_centroid(str_ggeohash_draw_cell_bybox(jsonb_array_to_floats(j->'box'),true,9377)) as pt,
         str_ggeohash_draw_cell_bybox(jsonb_array_to_floats(j->'box'),true,9377) as geom
  FROM (
    SELECT gid,geouri, libgrid_co.osmcode_encode2(geouri,7) AS j
    FROM (VALUES
        (1,'geo:3.4588817,-76.5743308'),
        (2,'geo:3.4588344,-76.5750212'),
        (3,'geo:3.4587984,-76.5750062'),
        (4,'geo:3.4587535,-76.5749868'),
        (5,'geo:3.4588194,-76.5750392'),
        (6,'geo:3.45878610,-76.57501858'),
        (7,'geo:3.45870039,-76.57500548'),
        (8,'geo:3.45864125,-76.57498377')

      --(1,'geo:3.46103000261,-76.57770034945'),
      --(2,'geo:3.46103208489,-76.57391243547'),
      --(3,'geo:3.45834677198,-76.57390575999'),
      --(4,'geo:3.45834677198,-76.57770076667'),
      --(5,'geo:4.711111,-74.072222')
    ) t(gid,geouri)
  ) t2;

  CREATE TABLE fredy2 AS
    SELECT gid,geouri, j->>'code' AS code,
           str_ggeohash_draw_cell_bybox(jsonb_array_to_floats(j->'box'),true,9377) as geom
    FROM (
      SELECT gid,geouri, libgrid_co.osmcode_encode2(geouri,4) AS j
      FROM (VALUES
        (1,'geo:3.4588817,-76.5743308'),
        (2,'geo:3.4588344,-76.5750212')
      ) t(gid,geouri)
    ) t2;

*/
