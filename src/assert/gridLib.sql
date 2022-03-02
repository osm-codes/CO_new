
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
ASSERT round( ST_Area( libgrid_co.osmcode_decode_polyXY('HX7VGYKPW') ), 7 ) = 2.3458051, 'fail in HX7VGYKPW';

END;$a$;

/*
Origen check:
SELECT libgrid_co.osmcode_encode('geo:3.46103000261,-76.57770034945');
SELECT libgrid_co.osmcode_encode('geo:3.46103208489,-76.57391243547');
SELECT libgrid_co.osmcode_encode('geo:3.45834677198,-76.57390575999');
SELECT libgrid_co.osmcode_encode('geo:3.45834677198,-76.57770076667');
SELECT libgrid_co.osmcode_encode('geo:4.711111,-74.072222');
SELECT round( ST_Area( libgrid_co.osmcode_decode_polyXY('GF1ZDW6NY') ), 7 );
SELECT libgrid_co.osmcode_decode('HX7VGYKPW');

SELECT libgrid_co.osmcode_encode2('geo:3.45834677198,-76.57770076667')


*/
