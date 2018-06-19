CREATE TABLE MetricsDefinition
(
	MetricsCode varchar(50) NOT NULL,
	MetricsDescription varchar(100) NOT NULL,
	MetricsType varchar(10) NOT NULL DEFAULT 'COUNT',
	Color varchar(30) NOT NULL,
	SortOrder int NOT NULL,

	PRIMARY KEY (MetricsCode)
);


--drop TABLE MetricsData;

CREATE TABLE MetricsData
(
	Date integer NOT NULL,
	MetricsCode varchar(50) NOT NULL REFERENCES MetricsDefinition(MetricsCode),
	MetricsValue integer NOT NULL DEFAULT 0,
 
	PRIMARY KEY (Date, MetricsCode)
);

