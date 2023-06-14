CREATE OR REPLACE FUNCTION shortest_path_distance(_network_table TEXT, _source INTEGER, _target INTEGER, _directed BOOLEAN)
RETURNS DOUBLE PRECISION AS $$
DECLARE
    result DOUBLE PRECISION;
BEGIN
    EXECUTE format(
        'SELECT SUM(pt_agg.agg_cost)
        FROM pgr_dijkstra(
            ''SELECT id, source, target, length AS cost FROM %I'',
            $1,
            $2,
            directed := $3
        ) AS pt_agg',
        _network_table
    ) INTO result USING _source, _target, _directed;

    RETURN result;
END;
$$ LANGUAGE plpgsql;
