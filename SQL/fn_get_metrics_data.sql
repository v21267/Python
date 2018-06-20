-- DROP FUNCTION fn_get_metrics_data;

CREATE OR REPLACE FUNCTION fn_get_metrics_data(p_date integer) 
RETURNS TABLE
(
	date integer,	
	code varchar(50),
	description varchar(100),
	type varchar(10),
	color varchar(30),
	value integer
)
AS $BODY$
BEGIN
    RETURN QUERY 
	SELECT
		p_date as date,
		def.MetricsCode as code,
		def.MetricsDescription as description,
		def.MetricsType as type,
		def.Color as color,
		COALESCE(d.MetricsValue, 0) AS value
	FROM
		MetricsDefinition def
	LEFT OUTER JOIN
		MetricsData d ON d.MetricsCode = def.MetricsCode
			     AND d.Date = p_date
	ORDER BY
		def.SortOrder;

    RETURN;
END
$BODY$
LANGUAGE plpgsql;


-- select * from fn_get_metrics_data(20120101)