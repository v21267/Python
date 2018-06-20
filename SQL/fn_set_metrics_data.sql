-- DROP FUNCTION fn_set_metrics_data;

CREATE OR REPLACE FUNCTION fn_set_metrics_data
(
	p_date integer,
	p_code varcvhar(50),
	p_value integer
)
AS $BODY$
BEGIN
	INSERT INTO MetricsData
	(
		Date,
		MetricsCode,
		MetricsValue
	)
	SELECT
		p_date,
		p_code,
		p_value
	WHERE
		NOT EXISTS
		(
			SELECT
				1
			FROM
				MetricsData md
			WHERE
				md.Date = p_date
			AND	md.MetricsCode = p_code
		)
	;

	IF ROW_COUNT = 0
	BEGIN
		UPDATE
			MetricsData md
		SET
			MetricsValue = p_value
		WHERE
			md.Date = p_date
		AND	md.MetricsCode = p_code
	END IF;

	RETURN;
END
$BODY$
LANGUAGE plpgsql;


-- select * from fn_get_metrics_data(20120101)