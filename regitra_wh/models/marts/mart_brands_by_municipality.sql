SELECT
    marke,
    apskritis,
    COUNT(*) AS daznis
FROM
    {{ ref("int_vehicle_park__flagged") }}
WHERE
    is_automobile
    AND is_natural_person
    AND is_road_ready
GROUP BY
    1,
    2
ORDER BY
    apskritis,
    daznis DESC
