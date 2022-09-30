------------------
-- coverage city (temp table):

--DROP TABLE libosmcodes.tmp_coverage_city;
CREATE TABLE libosmcodes.tmp_coverage_city (
  isolabel_ext text   NOT NULL,
  srid         int    NOT NULL,
  jurisd_base_id int NOT NULL,
  cover        text[] NOT NULL
);
--DELETE FROM libosmcodes.tmp_coverage_city;
INSERT INTO libosmcodes.tmp_coverage_city(isolabel_ext,srid,jurisd_base_id,cover) VALUES
('BR-AM-Apui',952019,76,'{056AJ,056AK,066AL,056AM,056BJ,056BK,056BL,056BM,056EJ,056EK,056EL,056EM,056FJ,056FK,056FL,056F8V,056FM,059G,059H,05CG,05CH}'::text[]),
('BR-AM-Barcelos',952019,76,'{005H,010G,010H,011G,011H,012G,012H,013G,013H,018G,019G}'::text[]),
('BR-AM-Maraa',952019,76,'{005CK,005CL,005CM,005DJ,005DK,005DL,005DM,005EJ,005EK,005EL,005EM,005FJ,005FK,010G,010H,05AH}'::text[]),
('BR-AM-SaoGabrielCachoeira',952019,76,'{003G,003H,004H,005H,006G,006H,007G,007H,009G,00CG,00DG}'::text[]),
('BR-AP-LaranjalJari',952019,76,'{022FM,023G,0233K,0234AT,0236J,023H,0283K,0283L,0283M,0284M,0285K,0285L,0285M,0286J,0286K,0286L,0286M,0287J,0287K,0287L,0287M,0289J,0289K,028CJ,028CK,028DJ,028DK,029G,0298J}'::text[]),
('BR-BA-CasaNova',952019,76,'{0736K,0736M,0737J,0737K,0737L,0737M,073CK,073DJ,073DK,073DL,073DM,073FK,0762L,0762M,0768J,0768K,0768L,0768M,076AJ}'::text[]),
('BR-BA-FormosaRioPreto',952019,76,'{065CM,065DJ,065DK,065DL,065DM,065EK,065FJ,065FK,065FL,065FM,0675K,0708J,0708L,0708M,0709L,0709M,070AJ,070AK,080AL,070AM,070BJ,070BK,070BL,070BM,0720J,0720K,0720L,0720M,0721J}'::text[]),
('BR-MG-SantaCruzMinas',952019,76,'{0B0C127,0B0C12D,0B0C132,0B0C133,0B0C136,0B0C138,0B0C139,0B0C13C}'::text[]),
('BR-PA-Altamira',952019,76,'{021G,062H,063G,063H,068G,068H,069G,069H,06AG,06AH,06BG,06BH}'::text[]),
('BR-PA-Itaituba',952019,76,'{0151K,05DG,05DH,05FG,05F8K,05F9J,05F9K,05F9L,05F9M,05FBJ,05FBK,05FBM,05FCJ,05FCK,05FCL,05FCM,05FDJ,05FDK,05FDL,05FDM,05FEJ,05FEK,05FEL,05FFJ,05FFK,05FFL,05FFM,068H,06AG,06AH}'::text[]),
('BR-PA-Obidos',952019,76,'{015H,017G,017H,01D5K,01D5M,01D7K,01D7M,01DDK,020H,020AJ,022G,022H,028G,0288J}'::text[]),
('BR-PA-PortoMoz',952019,76,'{020DK,020DM,0212L,0212M,0213L,0213M,0216L,0218J,0218K,0218L,0218M,0219J,0219K,0219L,0219M,021AJ,021AK,021BJ,021BK,021BL,021BM,021CJ,021CL,021EJ,021EL}'::text[]),
('BR-PB-Cabedelo',952019,76,'{08864Z,08865T,08866Q,08867N,08867P,08867S}'::text[]),
('BR-PB-Cuitegi',952019,76,'{0883C3F,0883CR,0883CS,0883CC0,0883CC1,0883CC2,0883CC3,0883CC4,0883CC5,0883CC6,0883CC7,0883CC8,0883CC9,0883CCA,0883CCB,0883CCC,0883CCD,0883CCE,0883CCF,0883CD0,0883CD1,0883CD2,0883CD3,0883CD4,0883CD6,0883CD8,0883CD9,0883CDA,0883CE4,0883CE5,0883CF0}'::text[]),
('BR-PB-Piloezinhos',952019,76,'{0883CS,0883CT,0883CV,0883CZ,0883EN,0883E40,0883E41,0883E42,0883E43,0883E44,0883E45,0883E46,0883E47,0883E48,0883E49,0983E4C,0883E4D,0883E50,0883E52,0883E58}'::text[]),
('BR-PE-FernandoNoronha',952019,76,'{08BD2V,08BD2Z,08BD3T,08BD9N}'::text[]),
('BR-PE-Olinda',952019,76,'{082ECR,082ECS,082ECT,082ECV,082ECZ,082EEN,082EEQ}'::text[]),
('BR-PI-Urucui',952019,76,'{072EL,072EM,0781K,0781M,0783K,0783M,0784J,0784K,0784L,0784M,0785J,0785L,0786J,0786K,0786L,0786M,0787J,0787L,078CK,078DJ}'::text[]),
('BR-RJ-RioJaneiro',952019,76,'{0EAEK,0EAFJ,0EADL,0EAF4T,0EAF4S,0EAF4P,0EAF4N,0EADET,0EADES,0EAF4Z,0EAF4V,0EAF4R,0EAF4Q,0EADEZ,0EADEV,0EAF5S,0EAF5P,0EAF5N,0EADFT,0EADFS}'::text[]),
('BR-RN-Passagem',952019,76,'{0889DR,0889DV,0889DE1,0889DE3,0889DE4,0889DE5,0889DE6,0889DE7,0889DED,0889DEF,0889DF0,0889DF1,0889DF2,0889DF3,0889DF4,0889DF5,0889DF6,0889DF7,0889DF8,0889DF9,0889DFA,0889DFB,0889DFC,0889DFD,0889DFE,0889DFF,0889F50,088C8A8,088C8AA}'::text[]),
('BR-RO-PortoVelho',952019,76,'{0573K,0576J,0576K,0576L,0576M,0577J,0577K,0577L,0577M,052G,052H,053H,053AL,053AC07,053ADS,058G,059G}'::text[]),
('BR-RR-Amajari',952019,76,'{018H,019H,01A0K,01A0L,01A0M,01A1J,01A1K,01A1L,01A1M,01A2J,01A4J,01A4K,01A4L,01A4M,01A5J,01A5K,01A5M,01BG,01B45R}'::text[]),
('BR-RR-Caroebe',952019,76,'{0D3G,0169M,016AK,016AM,016BJ,016BK,016BL,016BM,016CL,016EJ,016EL,01C0K,01C0M,01C1J,01C1K,01C1L,01C1M,01C4J,01C4L}'::text[]),
('BR-RS-Esteio',952019,76,'{03F4J,0D1FAP,0D1FAQ,0D1FAR,0D1FB02,0D1FB03,0D1FB04,0D1FB06,0D1FB08,0D1FB09}'::text[]),
('BR-RS-SantaVitoriaPalmar',952019,76,'{0FA7M,0FB2L,0FADK,0FB8J,0FB8K,0FADM,0FB8L,0FB8M,0FB9L,0FBAJ,0FBAK,0FBBJ}'::text[]),
('BR-RS-SaoPedroSerra',952019,76,'{0D346T,0D346EA,0D346EB,0D346EE,0D346EF,0D346F8,0D346F9,0D346FA,0D346FB,0D346FC,0D346FD,0D346FE,0D346FF,0D347T,0D34CN,0D34CQ,0D34DN}'::text[]),
('BR-SC-Bombinhas',952019,76,'{0DC50R,0DC51P,0DC51S,0DC51T}'::text[]),
('BR-SP-Campinas',952019,76,'{0DFBJ,0DFBK,0DFBM,0DFEJ,0DF9M}'::text[]),
('BR-SP-Jandira',952019,76,'{0DF957B,0DF957C,0DF957D,0DF957E,0DF957F,0DF95D1,0DF95D3,0DF95D4,0DF95D5,0DF95D6,0DF95D7,0DF95D8,0DF95D9,0DF95DA,0DF95DB,0DF95DC,0DF95DD,0DF95DE,0DF95F0,0DF95F1,0DFC028,0DFC029,0DFC02A,0DFC02B,0DFC02C,0DFC02E,0DFC080,0DFC081,0DFC084,0DFC085}'::text[]),
('BR-SP-SaoCaetanoSul',952019,76,'{0DF6BF5,0DF6BF6,0DF6BF7,0DF6BFC,0DF6BFD,0DF6BFE,0DF6BFF,0DF6EA0,0DF6EA1,0DF6EA2,0DF6EA3,0DF6EA8,0DF6EA9,0DF6EAA,0DF6EAB,0DF6EAC,0DF6EAE,0DFC154,0DFC155,0DFC157,0DFC400,0DFC401,0DFC402,0DFC403,0DFC404,0DFC406}'::text[]),
('BR-SP-SaoPaulo',952019,76,'{0DF6J,0DF6L,0DFCJ,0DFC6S,0DFC6P,0DFC6N,0DFC4T,0DFC4S,0DFC4P,0DFC4N,0DF6ET,0DFC4Z,0DFC4V,0DFC4R,0DFC4Q,0DF6EZ,0DFC5T,0DFC5S,0DFC5P,0DFC5N,0DF6FT}'::text[]),
('CO-AMA-Leticia',9377,170,'{1D1EK,1D1EL,1D1EM,1D2H,1D31K,1D31L,1D31M,1D32M,1D33J,1D33K,1D33L,1D33M,1D34J,1D34K,1D34L,1D34M,1D36J,1D36K,1D36L,1D36M,1D37J,1D37L,1D3H,1D8G,1D9G,1D9H,1DCH}'::text[]),
('CO-ANT-Itagui',9377,170,'{09823S,09823T,09823Z,09828Q,09828R,09829N,09829P,09829Q,09829R,09829S,09829T,09829V,09829Z,0982CP,0982CS,0982CT}'::text[]),
('CO-ANT-Medellin',9377,170,'{08D77Z,08D7M,08DDK,08DDM,0982L,0982M,0983L,0988J,0988K,0988L,0988M,0989J}'::text[]),
('CO-ATL-Soledad',9377,170,'{0393K,0393M,0396J,03966T,03968N,03968P,03968Q,03968R,03968S,03968V,03968Z,03969N,03969P,03969Q,03969R,03969S,03969T,03969V,0396CN,0396CP}'::text[]),
('CO-BOY-Tunja',9377,170,'{0975L,0975M,0977J,09774N,09774P,09774Q,09774R,09774S,09774T,09774V,09774Z,09775S,09775T,09775V,09775Z,09776N,09776P,09776Q,09776R,09776S,09776V,09776Z,09777N,09777P,09777Q,09777R,09777S,09777T,09777V,09777Z,0977CQ,0977DN}'::text[]),
('CO-CAQ-Solano',9377,170,'{150H,151G,151H,152G,152H,153G,153H,154G,155G,155H,157G,157H,160G,160H,161G,161H,162G,162H,163G,163H,164G,164H,165G,166G,19BH,19EG,19EH,19FG,19FH,1A}'::text[]),
('CO-CAU-Florencia',9377,170,'{149B5R,149B5V,149B5Z,149B7Q,149EJ,149E6S,149E6T,149E6V,149E6Z,149EL,149EM}'::text[]),
('CO-CUN-Narino',9377,170,'{0FB3CS,0FB3J,0FB3K,0FB3CN,0FB3CP,0FB3CQ,0FB3CR,0FB3CV,0FB3CZ,0FB3DN,0FB3DP,0FB3DQ,0FB3DR,0FB3DS,0FB3DT,0FB3DV,0FB3DZ,0FB3EQ,0FB3ER,0FB3EV,0FB3FN,0FB3FP,0FB3FQ,0FB3FR,0FB6L,0FBCJ}'::text[]),
('CO-DC-Bogota',9377,170,'{0FCG,0FCH,0FE3M,0FE6L,0FE6M,0FE3K,0FE6J,0FE6K,0FE1M,0FE4L,0FE1K,0FE4J,0FE4K,0FEEL,0FEEM,0FEFL,0FEBK,0FEEJ,0FEEK,0FEFJ,0FE9M,0FECL,0FECM,0FECJ,0FECK,0FEDJ,0944M,0944J,0944K,0945J,0FEDL,0FE4M}'::text[]),
('CO-GUA-Barrancominas',9377,170,'{110G,0F0H,0F1G,0F1H,0F3G,0F39J,0F39K,0F39L,0F39M,0F3CJ,0F3CK,0F3CL,0F3CM,0F3DJ,0F3DK,0F3DL,0F3DM,0F3EK,0F3FJ,0F3FK,0F3FL,0F3FM,0F4H,116G,0F6H,0F7G,0F7H,0FCG,0FDG,122H,17AH}'::text[]),
('CO-GUV-Calamar',9377,170,'{157H,15DG,15DH,15FG,162G,162H,163AAT,168G,168H,169G,169H,16AG,16AH,16BG,16BH}'::text[]),
('CO-GUV-SanJoseGuaviare',9377,170,'{0F5G,100G,101G,101H,104G,104H,105G,105H,0F0G,0F0H,15FG,15FH,16AG,16AH,16BH,16EH,16FH,17AH}'::text[]),
('CO-NSA-PuertoSantander',9377,170,'{073BM,073EL,07915N,07915P,07915Q,07915R,07915S,07915T,07915V,07915Z,07917N,07917P,07917Q,07917R,07917V,07940N,07940P,07940Q,07940R,07940S,07940T,07940V,07942N,07942P,07942S}'::text[]),
('CO-RIS-Dosquebradas',9377,170,'{08556V,08556Z,08557R,08557S,08557T,08557V,08557Z,0855CQ,0855CR,0855CV,0855CZ,0855DN,0855DP,0855DQ,0855DR,0855DS,0855DT,0855DV,0855DZ,0855EQ,0855FN,0855FP,0855FQ,0855FR,0855FS,0900J,0900L}'::text[]),
('CO-RIS-LaVirginia',9377,170,'{0854BZ,0854ER,0854ES,0854ET,0854EV,0854EZ,0854FN,0854FP,0854FS,0854FT,0854FV,0854FZ,08561Q,08564N,08564P,08564Q,08564R,08564V,08564Z,08565N,08565P,08565Q,08565R,08565S,08565T,08565V,08570N}'::text[]),
('CO-RIS-Pereira',9377,170,'{0854J,0854K,0854L,0854M,0855J,0855K,0855L,0855M,08565Q,08570N,0900J,0901K,0EFEL,0EFEM,0EFFL,0EFFM,0FAAL,0FAAM,0FABJ,0FABL,0FABM}'::text[]),
('CO-SUC-Since',9377,170,'{06A7K,06A7L,06A7M,06ADJ,06ADK,06ADL,06ADM,06AFK,06B2J,06B2L,06B2M,06B8J,06B8K,06B8L,06B8M,06B9J}'::text[]),
('CO-VAC-Ulloa',9377,170,'{0EFEM,0EFF6T,0EFF6Z,0EFFL,0EFFCN,0EFFCP,0EFFCQ,0EFFCR,0EFFCS,0EFFCT,0EFFCV,0EFFCZ}'::text[]),
('UY-CO-ColoniaSacramento',32721,858,'{0A1FM,0A4AJ,0A4AK,0A4AL,0A4AM,0A4BJ,0A4BL}'::text[])
;

------------------
-- Table coverage:

-- L0cover Colombia
--DELETE FROM libosmcodes.coverage  WHERE (id::bit(64)<<24)::bit(2) = 0::bit(2) AND (id::bit(64))::bit(10) = 170::bit(10);
INSERT INTO libosmcodes.coverage(id,bbox,geom,geom_srid4326)
SELECT (jurisd_base_id::bit(10) || 0::bit(14) || '00' ||
        (CASE WHEN ST_ContainsProperly(geom_country,geom_cell) IS FALSE THEN '1' ELSE '0' END) ||
        rpad((baseh_to_vbit(prefix,16))::text, 34, '0000000000000000000000000000000000'))::bit(64)::bigint,
        bbox, geom, ST_Transform(geom,4326)
FROM
(
  SELECT 170 AS jurisd_base_id,prefix,bbox,geom_country,
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,false,9377),geom_country) AS geom,
    str_ggeohash_draw_cell_bybox(bbox,false,9377) AS geom_cell
  FROM unnest
      (
      '{00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F,10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E,1F}'::text[],
      --'{0,1,2,3,4,5,6,7,8,9,B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,U,V,W,X,Y,Z}'::text[],
      array[0,45,37,38,39,31,32,33,25,26,27,28,29,18,19,20,21,22,23,12,13,14,15,16,17,8,9,10,3,4]
      ) t(prefix,quadrant),
      LATERAL (SELECT libosmcodes.ij_to_bbox(quadrant%6,quadrant/6,4180000.0,1035500.0,262144.0)) u(bbox),
      LATERAL (SELECT ST_Transform(geom,9377) FROM optim.vw01full_jurisdiction_geom g WHERE lower(g.isolabel_ext) = lower('CO') AND jurisd_base_id = 170) r(geom_country)
  WHERE quadrant IS NOT NULL AND quadrant > 0
) y
ORDER BY 1
;

-- L0cover Brasil
--DELETE FROM libosmcodes.coverage  WHERE (id::bit(64)<<24)::bit(2) = 0::bit(2) AND (id::bit(64))::bit(10) = 76::bit(10);
INSERT INTO libosmcodes.coverage(id,bbox,geom,geom_srid4326)
SELECT (jurisd_base_id::bit(10) || 0::bit(14) || '00' ||
        (CASE WHEN ST_ContainsProperly(geom_country,geom_cell) IS FALSE THEN '1' ELSE '0' END) ||
        rpad((baseh_to_vbit(prefix,16))::text, 34, '0000000000000000000000000000000000'))::bit(64)::bigint,
        bbox, geom, ST_Transform(geom,4326)
FROM
(
    SELECT 76 AS jurisd_base_id, prefix, bbox,geom_country,
      ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,false,952019),geom_country) AS geom,
      str_ggeohash_draw_cell_bybox(bbox,false,952019) AS geom_cell
    FROM unnest
        (
        '{00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F,10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E,1F}'::text[],
        array[20,21,22,23,15,16,17,18,19,11,12,13,6,7,8,2,24,14]
        ) t(prefix,quadrant),
        LATERAL (SELECT libosmcodes.ij_to_bbox(quadrant%5,quadrant/5,2715000.0,6727000.0,1048576.0)) u(bbox),
        LATERAL (SELECT ST_Transform(geom,952019) FROM optim.vw01full_jurisdiction_geom g WHERE lower(g.isolabel_ext) = lower('BR') AND jurisd_base_id = 76) r(geom_country)
    WHERE quadrant IS NOT NULL
) y
ORDER BY 1
;

-- L0cover Uruguai
--DELETE FROM libosmcodes.coverage  WHERE (id::bit(64)<<24)::bit(2) = 0::bit(2) AND (id::bit(64))::bit(10) = 858::bit(10);
INSERT INTO libosmcodes.coverage(id,bbox,geom,geom_srid4326)
SELECT (jurisd_base_id::bit(10) || 0::bit(14) || '00' ||
        (CASE WHEN ST_ContainsProperly(geom_country,geom_cell) IS FALSE THEN '1' ELSE '0' END) ||
        rpad((baseh_to_vbit(prefix,16))::text, 34, '0000000000000000000000000000000000'))::bit(64)::bigint,
        bbox, geom, ST_Transform(geom,4326)
FROM
(
  SELECT 858 AS jurisd_base_id,prefix,bbox,geom_country,
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,false,32721),geom_country) AS geom,
    str_ggeohash_draw_cell_bybox(bbox,false,32721) AS geom_cell
  FROM unnest
      (
        '{00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F,10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E,1F}'::text[],
        array[40,41,30,31,32,33,20,21,22,23,10,11,12,13,1,2,42,0,3]
      ) t(prefix,quadrant),
      LATERAL (SELECT libosmcodes.ij_to_bbox(quadrant%10,quadrant/10,353000.0,6028000.0,131072.0)) u(bbox),
      LATERAL (SELECT ST_Transform(geom,32721) FROM optim.vw01full_jurisdiction_geom g WHERE lower(g.isolabel_ext) = lower('UY') AND jurisd_base_id = 858) r(geom_country)
  WHERE quadrant IS NOT NULL
) z
;

-- L0cover Ecuador
--DELETE FROM libosmcodes.coverage  WHERE (id::bit(64)<<24)::bit(2) = 0::bit(2) AND (id::bit(64))::bit(10) = 218::bit(10);
INSERT INTO libosmcodes.coverage(id,bbox,geom,geom_srid4326)
SELECT (jurisd_base_id::bit(10) || 0::bit(14) || '00' ||
        (CASE WHEN ST_ContainsProperly(geom_country,geom_cell) IS FALSE THEN '1' ELSE '0' END) ||
        rpad((baseh_to_vbit(prefix,16))::text, 34, '0000000000000000000000000000000000'))::bit(64)::bigint,
        bbox, geom, ST_Transform(geom,4326)
FROM
(
  (
    SELECT 218 AS jurisd_base_id,prefix,bbox,geom_country,
      ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,false,32717),geom_country) AS geom,
      str_ggeohash_draw_cell_bybox(bbox,false,32717) AS geom_cell
    FROM unnest
        (
        '{00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F,10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E,1F}'::text[],
        array[60,50,51,55,56,40,41,45,46,47,30,31,35,36,37,25,26,27,15,16,5,6]
        ) t(prefix,quadrant),
        LATERAL (SELECT ARRAY[ -870000 + (quadrant%10)*262144, 9401000 + (quadrant/10)*(131072), -870000 + (quadrant%10)*262144+262144, 9401000 + (quadrant/10)*(131072)+131072 ]) u(bbox),
        LATERAL (SELECT ST_Transform(geom,32717) FROM optim.vw01full_jurisdiction_geom g WHERE lower(g.isolabel_ext) = lower('EC') AND jurisd_base_id = 218) r(geom_country)
    WHERE quadrant IS NOT NULL
  )
) z
;

-- de_para cover
--DELETE FROM libosmcodes.coverage WHERE (id::bit(64)<<24)::bit(2) <> 0::bit(2);
INSERT INTO libosmcodes.coverage(id,bbox,isolabel_ext,prefix,geom)
SELECT ((j_id_bit || l_id_bit || mun_princ || cover_parcial || order_prefix_5bits || prefix_bits_pad32)::bit(64))::bigint , bbox, isolabel_ext, prefix, geom
FROM
(
  SELECT j_id_bit, l_id_bit, '01' AS mun_princ,
  CASE
    WHEN ST_ContainsProperly(r.geom_transformed,str_ggeohash_draw_cell_bybox(bbox,false,p.srid)) IS FALSE
    THEN '1'
    ELSE '0'
  END AS cover_parcial,
  rpad(prefix_bits::text, 32, '00000000000000000000000000000000') AS prefix_bits_pad32,
  (order_prefix::int)::bit(5) AS order_prefix_5bits,
  q.isolabel_ext, prefix,
  ST_Intersection(r.geom_transformed,str_ggeohash_draw_cell_bybox(bbox,false,p.srid)) AS geom,
  bbox
  FROM
  (
    SELECT isolabel_ext, srid, jurisd_base_id, prefix,
           ROW_NUMBER() OVER (PARTITION BY isolabel_ext ORDER BY length(prefix), prefix ASC) AS order_prefix,
           baseh_to_vbit(prefix,16) AS prefix_bits
    FROM
    (
      SELECT isolabel_ext, srid, jurisd_base_id, unnest(cover) AS prefix
      FROM libosmcodes.tmp_coverage_city tc
    ) pp
  ) p
  -- new order isolevel=3, number -> 14 bits
  LEFT JOIN LATERAL
  (
    SELECT jurisd_base_id::bit(10) AS j_id_bit, gid::bit(14) AS l_id_bit, t.*
    FROM(
        SELECT ROW_NUMBER() OVER(ORDER BY jurisd_local_id ASC) AS gid, jurisd_base_id, jurisd_local_id, isolabel_ext
        FROM optim.jurisdiction
        WHERE jurisd_base_id=p.jurisd_base_id AND isolevel::int >2
        ORDER BY jurisd_local_id
    ) t
  ) q
  ON lower(p.isolabel_ext) = lower(q.isolabel_ext)
  -- geom jurisdiction
  LEFT JOIN LATERAL
  (
    SELECT isolabel_ext, jurisd_base_id, ST_Transform(geom,p.srid) AS geom_transformed, geom
    FROM optim.vw01full_jurisdiction_geom g
  ) r
  ON lower(r.isolabel_ext) = lower(q.isolabel_ext) AND r.jurisd_base_id = p.jurisd_base_id
  -- bbox prefix
  LEFT JOIN LATERAL
  (
    SELECT (CASE WHEN length(p.prefix)>1 THEN str_ggeohash_decode_box2(substring(p.prefix_bits from 9),bbox) ELSE bbox END) AS bbox
    FROM libosmcodes.coverage
    WHERE   (  (id::bit(64)    )::bit(10) = ((('{"CO":170, "BR":76, "UY":858, "EC":218}'::jsonb)->(upper(upper(split_part(p.isolabel_ext,'-',1)))))::int)::bit(10) )
        AND (  (id::bit(64)<<24)::bit(2) ) = 0::bit(2)
        AND ( ((id::bit(64)<<27)::bit(8) # prefix_bits::bit(8) ) = 0::bit(8)  )-- L0 2 dígitos base16h
  ) s
  ON TRUE

  ORDER BY q.isolabel_ext, order_prefix
) x
;
