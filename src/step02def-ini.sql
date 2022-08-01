------------------
-- Table l0cover:
/*
CREATE TABLE libosmcodes.l0cover (
  jurisd_base_id int   NOT NULL,
  srid           int   NOT NULL,
  prefix_l032    text  NOT NULL,
  prefix_l016h   text  NOT NULL,
  bbox           int[] NOT NULL,
  subcells_l032  text[],
  subcells_l016h text[],
  geom           geometry,
  geom_srid4326  geometry
);
*/
INSERT INTO libosmcodes.l0cover(jurisd_base_id,srid,prefix_l032,prefix_l016h,bbox,subcells_l032,subcells_l016h,geom,geom_srid4326)
(
  SELECT
    170 AS jurisd_base_id,
    9377 AS srid,
    prefix_l032, prefix_l016h,  bbox, null::text[], null::text[],
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,false,9377),ST_Transform(geom,9377)) AS geom,
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,true, 9377),geom) AS geom_srid4326
  FROM unnest
      (
      '{0,1,2,3,4,5,6,7,8,9,B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,U,V,W,X,Y,Z}'::text[],
      '{00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F,10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E,1F}'::text[],
      array[0,45,37,38,39,31,32,33,25,26,27,28,29,18,19,20,21,22,23,12,13,14,15,16,17,8,9,10,3,4]
      ) t(prefix_l032,prefix_l016h,quadrant),
      LATERAL (SELECT libosmcodes.ij_to_bbox(quadrant%6,quadrant/6,4180000,1035500,262144)) u(bbox),
      LATERAL (SELECT geom FROM optim.vw01full_jurisdiction_geom g WHERE lower(g.isolabel_ext) = lower('CO') AND jurisd_base_id = 170) r(geom)
  WHERE quadrant IS NOT NULL AND quadrant > 0
)
UNION
(
  SELECT 
    76 AS jurisd_base_id,
    952019 AS srid,
    prefix_l032, prefix_l016h, bbox, (CASE WHEN quadrant=2 THEN '{P,R,N,Q}'::text[] ELSE null::text[] END), (CASE WHEN quadrant=2 THEN '{A,B,T}'::text[] ELSE null::text[] END),
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,false,952019),ST_Transform(geom,952019)) AS geom,
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,true, 952019),geom) AS geom_srid4326
  FROM unnest
      (
      '{0,1,2,3,4,5,6,7,8,9,B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,U,V,W,X,Y,Z}'::text[],
      '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F}'::text[],
      array[20,21,22,23,15,16,17,18,19,11,12,13,6,7,8,2]
      ) t(prefix_l032,prefix_l016h,quadrant),
      LATERAL (SELECT libosmcodes.ij_to_bbox(quadrant%5,quadrant/5,2715000,6727000,1048576)) u(bbox),
      LATERAL (SELECT geom FROM optim.vw01full_jurisdiction_geom g WHERE lower(g.isolabel_ext) = lower('BR') AND jurisd_base_id = 76) r(geom)
  WHERE quadrant IS NOT NULL
)
UNION
(
  SELECT 76,952019,'H','F', bbox, '{H,G}'::text[], '{7,R}'::text[],
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,false,952019),ST_Transform(geom,952019)) AS geom,
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,true, 952019),geom) AS geom_srid4326
  FROM
  (SELECT libosmcodes.ij_to_bbox(24%5,24/5,2715000,6727000,1048576) AS bbox, geom FROM optim.vw01full_jurisdiction_geom g WHERE lower(g.isolabel_ext) = lower('BR') AND jurisd_base_id = 76) r
)
UNION
(
  SELECT 76,952019,'H','F', bbox, '{8,9,B,C}'::text[], '{4,5,Q}'::text[],
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,false,952019),ST_Transform(geom,952019)) AS geom,
    ST_Intersection(str_ggeohash_draw_cell_bybox(bbox,true, 952019),geom) AS geom_srid4326
  FROM
  (SELECT libosmcodes.ij_to_bbox(14%5,14/5,2715000,6727000,1048576) AS bbox, geom FROM optim.vw01full_jurisdiction_geom g WHERE lower(g.isolabel_ext) = lower('BR') AND jurisd_base_id = 76) r
)
ORDER BY 1,3
;

------------------
-- Table de-para (cover):

CREATE TABLE libosmcodes.tmpcover (
  isolabel_ext text   NOT NULL,
  srid         int    NOT NULL,
  jurisd_base_id int NOT NULL,
  cover        text[] NOT NULL
);
--DELETE FROM libosmcodes.tmpcover;
INSERT INTO libosmcodes.tmpcover(isolabel_ext,srid,jurisd_base_id,cover) VALUES
('CO-AMA-Leticia',9377,170,'{X3T,X3U,X3V,X5,X65,X66,X67,X6C,X6D,X6F,X6G,X6H,X6J,X6K,X6L,X6M,X6S,X6T,X6U,X6V,X6W,X6Y,X7,XJ,XL,XM,XT}'::text[]),
('CO-ANT-Itagui',9377,170,'{9J8W,9J8X,9J8Z,9JB2,9JB3,9JB8,9JB9,9JBB,9JBC,9JBD,9JBF,9JBG,9JBH,9JC1,9JC4,9JC5}'::text[]),
('CO-ANT-Medellin',9377,170,'{8UXZ,8UZ,8VP,8VR,9JB,9JC,9JG,9K0,9K1,9K2,9K3,9K4}'::text[]),
('CO-ATL-Soledad',9377,170,'{3LF,3LH,3LS,3LTP,3LU0,3LU1,3LU2,3LU3,3LU4,3LU6,3LU7,3LU8,3LU9,3LUB,3LUC,3LUD,3LUF,3LUG,3LV0,3LV1}'::text[]),
('CO-CAQ-Solano',9377,170,'{P1,P2,P3,P4,P5,P6,P7,P8,PB,PC,PG,PH,Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,QB,QD,TR,TW,TX,TY,TZ,U}'::text[]),
('CO-CAU-Florencia',9377,170,'{NMFC,NMFG,NMFH,NMFU,NMS,NMTN,NMTP,NMTQ,NMTR,NMU,NMV}'::text[]),
('CO-CUN-Narino',9377,170,'{HQH4,HQD,HQF,HQH0,HQH1,HQH2,HQH3,HQH6,HQH7,HQH8,HQH9,HQHB,HQHC,HQHD,HQHF,HQHG,HQHH,HQHL,HQHM,HQHQ,HQHS,HQHT,HQHU,HQHV,HQU,HRJ}'::text[]),
('CO-DC-Bogota',9377,170,'{HS, HT, HWH, HWU, HWV, HWF, HWS, HWT, HW7, HWL, HW5, HWJ, HWK, HXU, HXV, HXY, HXF, HXS, HXT, HXW, HX7, HXL, HXM, HXJ, HXK, HXN, 98M, 98J, 98K, 98N, HXQ, HWM}'::text[]),
('CO-GUA-Barrancominas',9377,170,'{K0,H1,H2,H3,H6,H74,H75,H76,H77,H7J,H7K,H7L,H7M,H7N,H7P,H7Q,H7R,H7T,H7W,H7X,H7Y,H7Z,H9,KD,HF,HG,HH,HS,HU,L5,RP}'::text[]),
('CO-GUV-Calamar',9377,170,'{PH,PU,PV,PY,Q4,Q5,Q7BP,QJ,QK,QL,QM,QN,QP,QQ,QR}'::text[]),
('CO-GUV-SanJoseGuaviare',9377,170,'{HB,J0,J2,J3,J8,J9,JB,JC,H0,H1,PY,PZ,QN,QP,QR,QX,QZ,RP}'::text[]),
('CO-NSA-PuertoSantander',9377,170,'{77H,77U,7L58,7L59,7L5B,7L5C,7L5D,7L5F,7L5G,7L5H,7L5S,7L5T,7L5U,7L5V,7L5Y,7LJ0,7LJ1,7LJ2,7LJ3,7LJ4,7LJ5,7LJ6,7LJJ,7LJK, 7LJN}'::text[]),
('CO-RIS-Dosquebradas',9377,170,'{8BPQ,8BPR,8BPV,8BPW,8BPX,8BPY,8BPZ,8BR2,8BR3,8BR6,8BR7,8BR8,8BR9,8BRB,8BRC,8BRD,8BRF,8BRG,8BRH,8BRL,8BRS,8BRT,8BRU,8BRV,8BRW,900,902}'::text[]),
('CO-RIS-Pereira',9377,170,'{8BJ,8BK,8BL,8BM,8BN,8BP,8BQ,8BR,8BTB,8BW0,900,905,GZU,GZV,GZY,GZZ,HPB,HPC,HPD,HPG,HPH}'::text[]),
('CO-RIS-LaVirginia',9377,170,'{8BLZ,8BMM,8BMN,8BMP,8BMQ,8BMR,8BMS,8BMT,8BMW,8BMX,8BMY,8BMZ,8BSB,8BT0,8BT1,8BT2,8BT3,8BT6,8BT7,8BT8,8BT9,8BTB,8BTC,8BTD,8BTF,8BTG,8BW0}'::text[]),
('CO-VAC-Ulloa',9377,170,'{GZV,GZXP,GZXR,GZY,GZZ0,GZZ1,GZZ2,GZZ3,GZZ4,GZZ5,GZZ6,GZZ7}'::text[]),
('CO-SUC-Since',9377,170,'{6NX,6NY,6NZ,6PN,6PP,6PQ,6PR,6PX,6Q8,6QB,6QC,6R0,6R1,6R2,6R3,6R4}'::text[]),
('CO-BOY-Tunja',9377,170,'{9GQ,9GR,9GW,9GX0,9GX1,9GX2,9GX3,9GX4,9GX5,9GX6,9GX7,9GXD,9GXF,9GXG,9GXH,9GXJ,9GXK,9GXL,9GXM,9GXN,9GXQ,9GXR,9GXS,9GXT,9GXU,9GXV,9GXW,9GXX,9GXY,9GXZ,9GZ2,9GZ8}'::text[]),
('BR-PB-Cuitegi',952019,76,'{8JH4,8JH1,8JH7,8JH6,8JH3}'::text[]),
('BR-RN-Passagem',952019,76,'{8K7C,8K7G,8K7H1,8K7H3,8K7H4,8K7H5,8K7H6,8K7H7,8K7HF,8K7HH,8K7HJ,8K7HK,8K7HL,8K7HM,8K7HN,8K7HP,8K7HQ,8K7HR,8K7HS,8K7HT,8K7HU,8K7HV,8K7HW,8K7HX,8K7HY,8K7HZ,8K7UJ,8KL58,8KL5B}'::text[]),
('BR-PB-Piloezinhos',952019,76,'{8JH4,8JH5,8JH6,8JH7,8JHJ,8JHL0,8JHL1,8JHL2,8JHL3,8JHL4,8JHL5,8JHL6,8JHL7,8JHL8,8JHL9,9JHLD,8JHLF,8JHLJ,8JHLL,8JHLS}'::text[]),
('BR-PE-FernandoNoronha',952019,76,'{9RNQ,8RNR,8RNX}'::text[]),
('BR-RS-Esteio',952019,76,'{3YJ,F3YK,F3YL,F3YM,F3YS2,F3YS3,F3YS4,F3YS6,F3YS8,F3YS9}'::text[]),
('BR-PB-Cabedelo',952019,76,'{8JT7,8JTF,8JTL,8JTS,8JTT,8JTW}'::text[]),
('BR-RS-SaoPedroSerra',952019,76,'{F6KP,F6KRB,F6KRC,F6KRG,F6KRH,F6KRS,F6KRT,F6KRU,F6KRV,F6KRW,F6KRX,F6KRY,F6KRZ,F6KX,F6M0,F6M2,F6M8}'::text[]),
('BR-SC-Bombinhas',952019,76,'{FSN3,FSN9,FSND,FSNF}'::text[]),
('BR-PE-Olinda',952019,76,'{85V3,85V4,85V5,85V6,85V7,85VJ,85VL}'::text[]),
('BR-AM-Apui',952019,76,'{5F8,5F9,6FB,5FC,5FD,5FF,5FG,5FH,5FS,5FT,5FU,5FV,5FW,5FX,5FY,5FY6,5FZ,5L,5M,5S,5T}'::text[]),
('BR-PA-PortoMoz',952019,76,'{21P,21R,22B,22C,22G,22H,22U,230,231,232,233,234,235,236,237,238,239,23D,23F,23G,23H,23J,23L,23S,23U}'::text[]),
('BR-BA-FormosaRioPreto',952019,76,'{6CM,6CN,6CP,6CQ,6CR,6CT,6CW,6CX,6CY,6CZ,6GP,710,712,713,716,717,718,719,81B,71C,71D,71F,71G,71H,740,741,742,743,744}'::text[]),
('BR-RR-Caroebe',952019,76,'{F6,1F7,1F9,1FC,1FD,1FF,1FG,1FH,1FL,1FS,1FU,1S1,1S3,1S4,1S5,1S6,1S7,1SJ,1SL}'::text[]),
('BR-BA-CasaNova',952019,76,'{76T,76V,76W,76X,76Y,76Z,77K,77N,77P,77Q,77R,77X,7DB,7DC,7F0,7F1,7F2,7F3,7F8}'::text[]),
('BR-PI-Urucui',952019,76,'{75U,75V,7J5,7J7,7JF,7JH,7JJ,7JK,7JL,7JM,7JN,7JQ,7JS,7JT,7JU,7JV,7JW,7JY,7KK,7KN}'::text[]),
('BR-PA-Itaituba',952019,76,'{1B5,5U,5V,5Y,5Z1,5Z4,5Z5,5Z6,5Z7,5ZD,5ZF,5ZH,5ZJ,5ZK,5ZL,5ZM,5ZN,5ZP,5ZQ,5ZR,5ZS,5ZT,5ZU,5ZW,5ZX,5ZY,5ZZ,6K,6N,6P}'::text[]),
('BR-RO-PortoVelho',952019,76,'{5GF,5GS,5GT,5GU,5GV,5GW,5GX,5GY,5GZ,54,55,57,57B,57C07,57CD,5J,5L}'::text[]),
('BR-AP-LaranjalJari',952019,76,'{25Z,26,26F,26LP,26S,27,2JF,2JG,2JH,2JM,2JP,2JQ,2JR,2JS,2JT,2JU,2JV,2JW,2JX,2JY,2JZ,2K4,2K5,2KJ,2KK,2KN,2KP,2L,2M0}'::text[]),
('BR-RR-Amajari',952019,76,'{1K,1M,1N1,1N2,1N3,1N4,1N5,1N6,1N7,1N8,1NJ,1NK,1NL,1NM,1NN,1NP,1NR,1Q,1QKC}'::text[]),
('BR-PA-Obidos',952019,76,'{1C,1G,1H,1UP,1UR,1UX,1UZ,1VP,21,218,24,25,2J,2K0}'::text[]),
('BR-AM-Maraa',952019,76,'{0CK,0CL,0CM,0CN,0CP,0CQ,0CR,0CS,0CT,0CU,0CV,0CW,0CX,10,11,5P}'::text[]),
('BR-PA-Altamira',952019,76,'{22,65,66,67,6J,6K,6L,6M,6N,6P,6Q,6R}'::text[]),
('BR-AM-Barcelos',952019,76,'{0C,10,11,12,13,14,15,16,17,1J,1L}'::text[]),
('BR-AM-SaoGabrielCachoeira',952019,76,'{06,07,09,0C,0D,0F,0G,0H,0L,0S,0U}'::text[]),
('BR-MG-SantaCruzMinas',952019,76,'{C1J97,C1J9F,C1J9L,C1J9M,C1J9Q,C1J9S,C1J9T,C1J9W}'::text[]),
('BR-SP-SaoCaetanoSul',952019,76,'{FYUZP,FYUZQ,FYUZR,FYUZW,FYUZX,FYUZY,FYUZZ,FYVP0,FYVP1,FYVP2,FYVP3,FYVP8,FYVP9,FYVPB,FYVPC,FYVPD,FYVPG,FZJBN,FZJBP,FZJBR,FZK00,FZK01,FZK02,FZK03,FZK04,FZK06}'::text[]),
('BR-SP-Jandira',952019,76,'{FZ5CV,FZ5CW,FZ5CX,FZ5CY,FZ5CZ,FZ5GK,FZ5GM,FZ5GN,FZ5GP,FZ5GQ,FZ5GR,FZ5GS,FZ5GT,FZ5GU,FZ5GV,FZ5GW,FZ5GX,FZ5GY,FZ5HJ,FZ5HK,FZJ18,FZJ19,FZJ1B,FZJ1C,FZJ1D,FZJ1G,FZJ40,FZJ41,FZJ44,FZJ45}'::text[]),
('BR-SP-Campinas',952019,76,'{FZD,FZF,FZH,FZS,FZ7}'::text[]),
('BR-SP-SaoPaulo',952019,76,'{FYS,FYU,FZG,FZKN,FZKK,FZKJ,FZK5,FZK4,FZK1,FZK0,FYVP,FZK7,FZK6,FZK3,FZK2,FYVR,FZKF,FZKD,FZK9,FZK8,FYVX}'::text[]),
('BR-RJ-RioJaneiro',952019,76,'{GPT,GPW,GPQ,GPX5,GPX4,GPX1,GPX0,GPRP,GPRN,GPX7,GPX6,GPX3,GPX2,GPRR,GPRQ,GPXD,GPX9,GPX8,GPRX,GPRW}'::text[]),
('BR-RS-SantaVitoriaPalmar',952019,76,'{HNZ,HQB,HPP,HR0,HR1,HPR,HR2,HR3,HR6,HR8,HR9,HRD}'::text[]);

/*
CREATE TABLE libosmcodes.de_para (
  id bigint NOT NULL,
  isolabel_ext text NOT NULL,
  prefix       text NOT NULL,
  index        text NOT NULL,
  geom         geometry -- in default srid
);
*/
--DELETE FROM libosmcodes.de_para;
INSERT INTO libosmcodes.de_para(id,isolabel_ext,prefix,index,geom)
SELECT ((j_id_bit || l_id_bit || mun_princ || cover_parcial ||  sufix_bits)::bit(64))::bigint , isolabel_ext, cell, ordered_cover, geom
FROM
(
  SELECT j_id_bit, l_id_bit, '01' AS mun_princ,
  CASE
  WHEN ST_ContainsProperly(r.geom_transformed,str_ggeohash_draw_cell_bybox(bbox,false,p.srid)) IS FALSE
  THEN '1'
  ELSE '0'
  END AS cover_parcial,
  rpad(cell_bits::text, 37, '0000000000000000000000000000000000000') AS sufix_bits, q.isolabel_ext, cell, ordered_cover,
  ST_Intersection(r.geom_transformed,str_ggeohash_draw_cell_bybox(bbox,false,p.srid)) AS geom
  FROM
  (
    SELECT isolabel_ext, srid, jurisd_base_id, cell, ordered_cover, baseh_to_vbit(cell,32) AS cell_bits,
    upper(substr(cell,1,1)) AS l0prefix
    FROM libosmcodes.tmpcover tc, unnest('{0,1,2,3,4,5,6,7,8,9,B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,U,V,W,X,Y,Z}'::text[],(ARRAY(SELECT i FROM unnest(cover) t(i) ORDER BY length(i), 1 ASC))) td(ordered_cover,cell)
    WHERE cell IS NOT NULL
  ) p
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
  LEFT JOIN LATERAL
  (
    SELECT isolabel_ext, jurisd_base_id, ST_Transform(geom,p.srid) AS geom_transformed, geom
    FROM optim.vw01full_jurisdiction_geom g
  ) r
  ON lower(r.isolabel_ext) = lower(q.isolabel_ext) AND r.jurisd_base_id = p.jurisd_base_id
  LEFT JOIN LATERAL
  (
    SELECT (CASE WHEN length(p.cell)>1 THEN str_ggeohash_decode_box2(substring(p.cell_bits from 6),bbox) ELSE bbox END) AS bbox
    FROM libosmcodes.l0cover
    WHERE jurisd_base_id = (('{"CO":170, "BR":76}'::jsonb)->(upper(split_part(p.isolabel_ext,'-',1))))::int AND ( prefix_l032 = (substr(p.cell,1,1))   )
    AND
        CASE
        WHEN subcells_l032 IS NOT NULL THEN (subcells_l032 @> array[substr(p.cell,2,1)]::text[])
        ELSE TRUE
        END
  ) s
  ON TRUE
 
  ORDER BY q.isolabel_ext, ordered_cover
) x
;

DROP TABLE libosmcodes.tmpcover;
