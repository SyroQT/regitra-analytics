SELECT
    *,
    kategorija_klase = 'M1' AS is_automobile,
    marke = 'NUASMENINTA' AS is_anonymized,
    vald_tipas = 'FIZINIS' AS is_natural_person,
    dae_statusas = 'T' AS is_road_ready
FROM
    {{ ref("stg_vehicle_park__small") }}
