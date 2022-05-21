 -- Finding inmates 25 or younger at time of execution
SELECT TOP 3
	Last_Name,
	First_Name,
	Age_at_Execution,
	YEAR(Date_of_Offence) year_of_offence,
	YEAR(Execution_Date) year_of_execution
FROM tx_deathrow
WHERE Age_at_Execution <= 25

--WILDCARDS
	--Using wildcards to find the execution date of a Raymond Landry
SELECT 
	First_Name, 
	Last_Name,
	Execution_Date
FROM tx_deathrow
WHERE First_Name like 'Ray%'
	AND Last_Name like 'Land%'

	-- Finding Napoleon Beazley last statement
SELECT
	First_Name,
	Last_Name,
	Age_at_Execution,
	DATEDIFF(YEAR, Date_of_Birth, Date_of_Offence) Age_at_Offence,
	Last_Statement
FROM tx_deathrow
WHERE First_Name like '%poleon'
	AND Last_Name like 'Beaz%y'

	-- Last statements pleading for innocence
SELECT
	First_Name,
	Last_Name,
	Last_Statement
FROM tx_deathrow
WHERE Last_Statement like '%innocence%'
	OR Last_Statement like '%not guilty%'

-- No of inmates over the age of 50 at execution
SELECT 
	COUNT(execution) no_of_inmates
FROM tx_deathrow
WHERE Age_at_Execution >= 50

-- Aggreggate Functions
	-- Min, Max and Avg age at execution
SELECT
	MIN(age_at_execution) min_age_at_execution,
	AVG(age_at_execution) avg_age_at_execution,
	MAX(age_at_execution) max_age_at_execution
FROM tx_deathrow

	-- Avg length of last statements
SELECT
	AVG(LEN(last_statement))
FROM tx_deathrow


-- Group by
	--Proportion of last statement
SELECT 
	YEAR(execution_date) execution_year,
	COUNT(last_statement) last_statement,
	COUNT(execution) no_of_executions,
	CONCAT(CEILING((COUNT(last_statement) * 1.0 / COUNT(execution)) * 100), '%') percent_of_last_statement
FROM tx_deathrow
GROUP BY YEAR(Execution_Date)

	-- No of execution per county
SELECT
	County,
	COUNT(execution) no_of_execution
FROM tx_deathrow
GROUP BY County
ORDER BY 2 DESC

	-- No of execution with/without last statement per county
WITH exec_death AS (
	SELECT *,
	CASE
		WHEN Last_Statement IS NOT NULL THEN 1
		ELSE 0
	END ls_statement
FROM tx_deathrow
)

SELECT
	county,
	ls_statement has_last_statement,
	COUNT(ls_statement) no_of_execution
FROM exec_death
GROUP BY County, ls_statement
ORDER BY 1

	-- First and last name of the person with the longest last statement
SELECT
	first_name, 
	last_name, 
	LEN(last_statement) len_of_last_statement, 
	Last_Statement
FROM tx_deathrow
WHERE LEN(last_statement) = 
	(SELECT TOP 1
		LEN(last_statement)
	FROM tx_deathrow
	ORDER BY LEN(last_statement) DESC)

SELECT TOP 1
	first_name, 
	last_name, 
	LEN(last_statement) len_of_last_statement, 
	Last_Statement
FROM tx_deathrow
ORDER BY 3 DESC

	-- Percentage of execution by county
SELECT
	county,
	100.0 * COUNT(execution) / (SELECT COUNT(execution) FROM tx_deathrow) pct
FROM tx_deathrow
GROUP BY county
ORDER BY 2 DESC

-- Day difference between executions
SELECT
	First_Name,
	Last_Name,
	Execution_Date,
	LAG(Execution_Date) OVER (ORDER BY execution) previous_execution_date,
	DATEDIFF(DAY, LAG(Execution_Date) OVER (ORDER BY execution), Execution_Date) day_difference
FROM tx_deathrow
ORDER BY 5 DESC

-- Year on year change in numbe of executions
WITH execution_chg AS (
	SELECT *,
	LAG(no_of_execution) OVER (ORDER BY execution_year) prev_no_of_execution
FROM
	(SELECT
		YEAR(execution_date) execution_year,
		COUNT(execution) no_of_execution
	FROM tx_deathrow
	GROUP BY YEAR(execution_date)) tx_death)

SELECT *,
	CONCAT(CEILING((100.0 * (no_of_execution - prev_no_of_execution)/prev_no_of_execution)), '%') yoy_exec_chg
FROM execution_chg