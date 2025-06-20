--query for complete 1QTR data 
-- with chat, email, call transcipt with its genai summery
--final version
WITH keywords AS (
    SELECT 'empty package'::TEXT AS kw
),
livechat_filtered AS (
    SELECT
        lc.caseid::TEXT AS case_id,
        lc.case_number_for_bot__c::TEXT AS case_nbr,
        lc.createddate AS message_date,
        'LiveChat'::TEXT AS message_type,
        kw.kw AS keyword,
        lc.body AS message_body 
    FROM sfdc_livechattranscript lc
    JOIN keywords kw ON lc.body ILIKE '%' || kw.kw || '%'
    WHERE lc.createddate >= DATE '2025-02-01' AND lc.createddate < DATE '2025-05-01'
),
email_filtered AS (
    SELECT
        ed.case_id::TEXT AS case_id,
        lc.case_number_for_bot__c::TEXT AS case_nbr,
        ed.src_crt_dts AS message_date,
        'Emaildtl'::TEXT AS message_type,
        kw.kw AS keyword,
        ed.email_body_txt AS message_body
    FROM sfdc_email_dtl ed
    JOIN sfdc_livechattranscript lc ON ed.case_id = lc.caseid
    JOIN keywords kw ON ed.email_body_txt ILIKE '%' || kw.kw || '%'
    WHERE ed.src_crt_dts >= DATE '2025-02-01' AND ed.src_crt_dts < DATE '2025-05-01'
),
voice_filtered AS (
    SELECT
        sctd.case_id::TEXT AS case_id,
        lc.case_number_for_bot__c::TEXT AS case_nbr,
        sctd.src_crt_dts AS message_date,
        'Calltxnsrpt'::TEXT AS message_type,
        kw.kw AS keyword,
        call_txnsrpt_smry_txt AS message_body
    FROM sfdc_call_txnsrpt_dtl sctd
    JOIN sfdc_livechattranscript lc ON sctd.case_id = lc.caseid
    JOIN keywords kw ON sctd.genai_voice_smry_desc ILIKE '%' || kw.kw || '%'
    WHERE sctd.src_crt_dts >= DATE '2025-02-01' AND sctd.src_crt_dts < DATE '2025-05-01'
),
all_messages AS (
    SELECT * FROM livechat_filtered
    UNION ALL
    SELECT * FROM email_filtered
    UNION ALL
    SELECT * FROM voice_filtered
)
SELECT
    am.*,
    sc.genai_case_summary__c
FROM all_messages am
LEFT JOIN sfdc_case sc ON am.case_nbr = sc.casenumber
ORDER BY am.message_date DESC;
