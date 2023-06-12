CREATE OR REPLACE FUNCTION create_full_network(
    result_table text,
    bikeways_table text,
    osm_table text
) RETURNS void AS $$
BEGIN
    EXECUTE format(
        'CREATE TABLE %I AS SELECT ST_Union(a.geom, b.geom) as union_geometry 
        FROM %I AS a, %I AS b 
        WHERE ST_Intersects(a.geom, b.geom)', 
        result_table, bikeways_table, osm_table
    );
END;
$$ LANGUAGE plpgsql;
