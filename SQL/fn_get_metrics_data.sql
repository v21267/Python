--DROP FUNCTION fn_get_metrics_data;

CREATE OR REPLACE FUNCTION fn_get_metrics_data(p_date date) 
RETURNS TABLE
(
	"Date" date,	
	"MetricsCode" varchar(50),
	"MetricsDescription" varchar(100),
	"MetricsType" varchar(10),
	"Color" varchar(30),
	"MetricsValue" decimal
)
AS $BODY$
BEGIN
    RETURN QUERY 
	SELECT
		p_date as "Date",
		def.MetricsCode,
		def.MetricsDescription,
		def.MetricsType,
		def.Color,
		COALESCE(d.MetricsValue::decimal, 0::decimal) AS MetricsValue
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


--select * from fn_get_metrics_data('2012/01/01')