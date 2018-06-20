-- DROP FUNCTION fn_get_chart_data;

CREATE OR REPLACE FUNCTION fn_get_chart_data
(
	p_date_range varchar(10),
	p_code varchar(50)
) 
RETURNS TABLE
(
	"periodName" varchar(30),
	"startDate" integer,
	"endDate" integer,
	value bigint
)
AS $BODY$
DECLARE
	v_period_count integer;
	v_i integer;
	v_date1 date;
	v_date2 date;
	v_month integer;
BEGIN
	CREATE TEMP TABLE ChartPeriod
	(
		StartDate integer,
		EndDate integer,
		PeriodName varchar(50)
	);

	IF p_date_range IN ('7', '30')
	THEN
		v_date1 := TO_DATE(TO_CHAR(CURRENT_DATE, 'YYYYMMDD'), 'YYYYMMDD');
		v_period_count := p_date_Range::integer;
		FOR v_i IN 1 .. v_period_count
		LOOP
			INSERT INTO ChartPeriod
			(
				StartDate,
				EndDate,
				PeriodName
			)
			VALUES
			(
				TO_CHAR(v_date1, 'YYYYMMDD')::integer,
				TO_CHAR(v_date1, 'YYYYMMDD')::integer,
				(CASE WHEN p_date_range = '7'
				      THEN LEFT(TO_CHAR(v_date1, 'Day'), 1)
				      ELSE LTRIM(TO_CHAR(v_date1, 'MM/'), '0') ||
					   LTRIM(TO_CHAR(v_date1, 'DD/'), '0') ||
					   TO_CHAR(v_date1, 'YY')
				 END)
			);
			
			v_date1 := v_date1 - 1;
		END LOOP;
	ELSIF p_date_range = 'M'
	THEN
		v_date1 := TO_DATE(TO_CHAR(CURRENT_DATE, 'YYYYMM01'), 'YYYYMMDD');
		v_date2 := (v_date1 + interval '1 month')::date - 1;
		FOR v_i IN 1 .. 7
		LOOP
			INSERT INTO ChartPeriod
			(
				StartDate,
				EndDate,
				PeriodName
			)
			VALUES
			(
				TO_CHAR(v_date1, 'YYYYMMDD')::integer,
				TO_CHAR(v_date2, 'YYYYMMDD')::integer,
				TO_CHAR(v_date1, 'Mon-YY')
			);
			
			v_date1 = (v_date1 - interval '1 month')::date;
			v_date2 = (v_date1 + interval '1 month')::date - 1;
		END LOOP;
	ELSIF p_date_range = 'Q'
	THEN
		v_date1 := TO_DATE(TO_CHAR(CURRENT_DATE, 'YYYYMMDD'), 'YYYYMMDD');
		v_month = TO_CHAR(v_date1, 'MM');
		v_month = ((v_month - 1) / 3 + 1) * 3 - 2;
		v_date1 = TO_DATE(TO_CHAR(CURRENT_DATE, 'YYYY') || LPAD(v_month::varchar, 2, '0') || '01', 'YYYYMMDD');
		v_date2 = (v_date1 + interval '1 month' * 3)::date - 1;
		FOR v_i IN 1 .. 5
		LOOP
			INSERT INTO ChartPeriod
			(
				StartDate,
				EndDate,
				PeriodName
			)
			VALUES
			(
				TO_CHAR(v_date1, 'YYYYMMDD')::integer,
				TO_CHAR(v_date2, 'YYYYMMDD')::integer,
				'Q' || TO_CHAR(v_date1, 'Q-YY')
			);
			
			v_date1 = (v_date1 - interval '1 month' * 3)::date;
			v_date2 = (v_date1 + interval '1 month' * 3)::date - 1;
		END LOOP;
	END IF;

	RETURN QUERY 
		SELECT 
			cp.PeriodName,
			cp.StartDate,
			cp.EndDate,
			COALESCE(SUM(md.MetricsValue::bigint), 0::bigint)::bigint AS Value
		FROM
			ChartPeriod cp
		LEFT OUTER JOIN 
			MetricsData md ON md.Date BETWEEN cp.StartDate and cp.EndDate
						  AND md.MetricsCode = p_code
		GROUP BY 
			cp.StartDate, 
			cp.EndDate, 
			cp.PeriodName
		ORDER BY
			cp.StartDate;


	DROP TABLE ChartPeriod;
	
	RETURN;
END
$BODY$
LANGUAGE plpgsql;


--select * from fn_get_chart_data('7', 'CALLS_LIVE');
--select * from fn_get_chart_data('30', 'CALLS_LIVE');
--select * from fn_get_chart_data('M', 'CALLS_LIVE');
--select * from fn_get_chart_data('Q', 'CALLS_LIVE');