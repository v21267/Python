-- DROP FUNCTION fn_set_metrics_data;

CREATE OR REPLACE FUNCTION fn_set_metrics_data
(
	p_date integer,
	p_code varchar(50),
	p_value integer
) RETURNS VOID
AS $BODY$
DECLARE
	v_row_count integer;
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
		);

	GET DIAGNOSTICS v_row_count = ROW_COUNT;
	IF v_row_count = 0
	THEN
		UPDATE
			MetricsData md
		SET
			MetricsValue = p_value
		WHERE
			md.Date = p_date
		AND	md.MetricsCode = p_code;
	END IF;

	RETURN;
END
$BODY$
LANGUAGE plpgsql;


-- select * from fn_get_metrics_data(20120101)
-- select fn_set_metrics_data(20120101, 'CALLS_LIVE', 13)