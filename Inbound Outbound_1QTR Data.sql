--query output data
--for 1QTR 1Feb2025 to 30Apr2025

SELECT
  scd.case_nbr,
  scd.case_crt_dts,
  swd.wo_nbr,
  swd.wo_svc_type_val,
  sdid.instrn_desc,

  OREPLACE(
    STRTOK( STRTOK( sdid.instrn_desc, ':', 2 ), ' ', 1 ),
    'Box'
  ) AS otbnd_trckng_id,

  STRTOK( sdid.instrn_desc, ':', 3 ) AS inbnd_trckng_id

FROM

  svc_base.sfdc_case_dtl AS scd

JOIN

  svc_base.sfdc_wo_dtl AS swd
    ON swd.case_id = scd.case_idD

JOIN

  svc_base.sfdc_dspch_instrn_dtl AS sdid
    ON sdid.sfdc_wo_id = swd.sfdc_wo_id

WHERE

  CAST( scd.case_crt_dts AS DATE FORMAT 'yyyy-mm-dd' ) BETWEEN DATE '2025-02-01' AND DATE '2025-04-30' AND

  swd.wo_svc_type_val = 'Mail-In' AND

  sdid.instrn_desc LIKE 'EMPTY BOX SENT%'  
  
 -- scd.case_nbr='209162784'
  

ORDER BY

  scd.case_nbr ASC,
  swd.wo_nbr ASC,
  sdid.instrn_desc ASC;