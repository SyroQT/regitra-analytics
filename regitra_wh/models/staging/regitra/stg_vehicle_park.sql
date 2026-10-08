WITH source AS (
    SELECT
        *
    FROM
        {{ source(
            'regitra_raw',
            'raw_park_data'
        ) }}
),
renamed AS (
    -- needs id
    SELECT
        UPPER(marke) AS marke,
        UPPER(komercinis_pav) AS komercinis_pav,
        gamintojo_pav,
        gamintojo_pav_baz,
        tipas,
        variantas,
        versija,
        es_tipo_patvirtinimo_nr,
        nac_tipo_patvirtinimo_nr,
        individual_patvirtinimo_nr,
        interpoliacija,
        uzbaigtumo_pakopa,
        vairas_desineje,
        kategorija_pilnai,
        kategorija_klase,
        keb_kodas,
        keb_pavadinimas,
        spec_kodas,
        spec_pavadinimas,
        keb_kodas_es,
        nuosava_mase,
        nuosava_mase_baz,
        maks_mase,
        maks_mase_f2,
        maks_mase_f5,
        bandomoji_mase,
        darbinis_turis,
        galia,
        sukiu_sk,
        galia_elektr,
        UPPER(degalai) AS degalai,
        degalu_rezimas,
        elektrine_tp,
        hibridines_tp_kategorija,
        pavaru_dezes_tipas,
        co2_kiekis,
        co2_kiekis_wltp,
        eko_naujoves_kodas,
        co2_sumazejimas_nedc,
        co2_sumazejimas_wltp,
        elektr_energ_sanaud_nedc,
        elektr_energ_sanaud_wltp_e,
        elektr_energ_sanaud_wltp_h,
        elektrine_rida_nedc,
        elektrine_rida_wltp_e,
        elektrine_rida_wltp_h,
        tersalu_lygis,
        tersalu_norm_akto_nr,
        ratu_baze,
        tv_plotis1,
        tv_plotis2,
        UPPER(spalva) AS spalva,
        galios_mases_sant,
        maks_greitis,
        sedimu_vietu_sk,
        stovimu_vietu_sk,
        gamybos_metai,
        modelio_metai,
        rida,
        pirm_reg_data,
        pirm_reg_data_lt,
        galiojimo_laik,
        paskutines_reg_data,
        dae_statusas,
        UPPER(kilmes_salis) AS kilmes_salis,
        UPPER(vald_tipas) AS vald_tipas,
        vald_gim_dat_int,
        savivaldybe,
        UPPER(apskritis) AS apskritis
    FROM
        source
),
filtered AS (
    SELECT
        *
    FROM
        renamed
    WHERE
        apskritis NOT LIKE '-%'
),
cleaned AS (
    SELECT
        s.* exclude (
            marke,
            komercinis_pav
        ),
        COALESCE(
            m.clean_marke,
            s.marke
        ) AS marke,
        -- strip the make (repeated, whole word) from the start or end of the model name;
        -- keep the original if nothing would be left (e.g. model "MINI" for make MINI)
        COALESCE(
            NULLIF(
                TRIM(
                    REGEXP_REPLACE(
                        s.komercinis_pav,
                        '^(' || regexp_escape(UPPER(COALESCE(m.clean_marke, s.marke))) || '(\s+|$))+' || '|(^|\s+)(' || regexp_escape(UPPER(COALESCE(m.clean_marke, s.marke))) || '(\s+|$))+$',
                        '',
                        'g'
                    )
                ),
                ''
            ),
            s.komercinis_pav
        ) AS komercinis_pav
    FROM
        filtered AS s
        LEFT JOIN {{ ref('marke_mapping') }} AS m
        ON TRIM(
            s.marke
        ) = TRIM(
            m.raw_marke
        )
),
hashed AS (
    SELECT
        MD5(CAST(s AS VARCHAR)) AS id,
        DATE_TRUNC('month', CURRENT_DATE()) AS ingestion_month,
        s.*,
    FROM
        cleaned AS s)
    SELECT
        *
    FROM
        hashed qualify ROW_NUMBER() over (
            PARTITION BY id
        ) = 1
