SELECT
    marke,
    komercinis_pav,
    degalai,
    spalva,
    kilmes_salis,
    apskritis,
    pirm_reg_data,
    CURRENT_DATE() - pirm_reg_data AS laikas_nuo_pirm_reg_datos
FROM
    {{ ref("int_vehicle_park__flagged") }}
WHERE
    is_automobile
    AND is_natural_person
    AND is_road_ready
    AND NOT is_anonymized
ORDER BY
    apskritis
