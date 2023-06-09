CREATE OR REPLACE FUNCTION shortest_path_distance(_source INTEGER, _target INTEGER)
RETURNS DOUBLE PRECISION AS $$
DECLARE
    result DOUBLE PRECISION;
BEGIN
    SELECT SUM(pt_agg.agg_cost)
    INTO result
    FROM pgr_dijkstra(
        'SELECT id, source, target, length AS cost FROM my_network_table',
        _source,
        _target,
        directed := false
    ) AS pt_agg;

    RETURN result;
END;
$$ LANGUAGE plpgsql;