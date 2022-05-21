-- How many olympic games have been held
SELECT count(distinct(games)) total_olympic_games
FROM dbo.olympics_history

-- List all olympic games held so far
SELECT distinct(year), season, city
FROM dbo.olympics_history
ORDER BY 1 desc

-- Total number of nations who participated  in each olympics game
SELECT games, count(distinct(region)) total_countries
FROM dbo.olympics_history oh
JOIN olympics_history_noc_regions ohr
ON oh.noc = ohr.noc
GROUP BY games
ORDER BY 1
 
-- Highest and lowest number of countries
SELECT top 1
	games,
	count(distinct(region)) lowest_countries
FROM dbo.olympics_history oh
JOIN olympics_history_noc_regions ohr
ON oh.noc = ohr.noc
GROUP BY games
ORDER BY 2
UNION
SELECT top 1
	games, 
	count(distinct(region)) highest_countries
FROM dbo.olympics_history oh
JOIN olympics_history_noc_regions ohr
ON oh.noc = ohr.noc
GROUP BY games
ORDER BY 2 desc

--Nations that has participated in all games
SELECT region country, sum(part) total_participated_games
FROM
	(SELECT games, region, count(distinct(region)) part
	FROM dbo.olympics_history  oh
	JOIN olympics_history_noc_regions ohr
	ON oh.noc = ohr.noc
	GROUP BY games, region) games
GROUP BY region
HAVING sum(part) = (SELECT count(distinct(games)) total_games
			FROM olympics_history)

-- Sports played in all Summer olympics
SELECT sport, sum(sport_count) no_of_games
FROM
	(SELECT games, sport, count(distinct(sport)) sport_count
	FROM olympics_history
	GROUP BY games, sport
	HAVING games like '%Summer') games
GROUP BY sport
HAVING sum(sport_count) = (SELECT count(distinct(games)) total_games
				FROM olympics_history
				WHERE games like '%Summer')

--Sports played just once in the olypmics
SELECT sport, sport_count no_of_games, games
FROM
	(SELECT *,
	CASE
		WHEN sport = lead(sport) over (order by sport) then 'No'
		WHEN sport = lag(sport) over (order by sport) then 'No'
		ELSE 'Yes'
	END played_once
	FROM
		(SELECT games, sport, count(distinct(sport)) sport_count
		FROM olympics_history
		GROUP BY games, sport) games) sports_once
WHERE played_once = 'Yes'
				--OR
with t1 as
(select distinct games, sport
from olympics_history),

t2 as 
(select sport, count(sport) no_of_games
from t1
group by sport)

select t2.*, t1.sport
from t2
join t1
on t2.sport = t1.sport
where t2.no_of_games = 1

--Total no of sports played in each games
with t1 as
(select distinct games, sport
from olympics_history)

select games, count(games) no_of_games
from t1
group by games
order by 2 desc

--Details of oldest athletes to win an olympic medal
select top 1 with ties
	age, team, name, games, sport, city, medal
from olympics_history
where age <> 'NA'
and medal like '%old'
order by convert(int, age) desc

--Ratio of males and females participants
with t1 as 
	(select distinct name, sex
	from olympics_history),

t2 as
	(select sex, count(sex) nos
	from t1
	group by sex),

t2_fem as
(select nos
from t2
where sex = 'F'),

t2_male as
(select nos
from t2
where sex = 'M')

select concat('1:',round(convert(float,t2_male.nos)/t2_fem.nos,2)) ratio
from t2_fem, t2_male

--Top 5 athletes with the most gold medals
select top 5 with ties
	name, count(medal) total_gold_medal
from olympics_history
where medal like '_old'
group by name
order by 2 desc
         --OR
select name, gold_medals
from
	(select *,
	dense_rank() over (order by gold_medals desc) dns_rnk
	from
		(select
			name, count(medal) gold_medals
		from olympics_history
		where medal like '_old'
		group by name) gold) dense_rank_gold
where dns_rnk <=5

-- Top 5 athletes with the most medals
select name, medals
from
	(select *,
	dense_rank() over (order by medals desc) dns_rnk
	from
		(select
			name, count(medal) medals
		from olympics_history
		where medal in ('Gold', 'Silver', 'Bronze')
		group by name) med) dense_rank_med
where dns_rnk <=5
			--OR
select top 5 with ties
	name, count(medal) total_medal
from olympics_history
where medal in ('Gold', 'Silver', 'Bronze')
group by name
order by 2 desc

-- Top 5 most successful countries in olympics
select top 5
	region, count(medal) total_medal
from olympics_history oh
join olympics_history_noc_regions ohr
on oh.noc = ohr.noc
where medal in ('Gold', 'Silver', 'Bronze')
group by region
order by 2 desc

-- Total gold, silver and bronze medals won by each country.
select *
from 
	(select region, medal
	from olympics_history oh
	join olympics_history_noc_regions ohr
	on oh.noc = ohr.noc) reg_med
pivot (
	count(medal)
	for medal in ([Gold], [SIlver], [Bronze])
) piv
order by Gold desc, Silver desc, Bronze desc

-- Total gold, silver and bronze medals won by each country corresponding to each olympic games.
select *
from
	(select games,region, medal
	from olympics_history oh
	join olympics_history_noc_regions ohr
	on oh.noc = ohr.noc)gam_med
pivot (
	count(medal)
	for medal in ([Gold], [SIlver], [Bronze])
) piv
order by games asc, Gold desc, Silver desc, Bronze desc

-- Countries that won the most gold, most silver and most bronze medals in each olympic games
with t1 as (
	select
		games,
		region,
		sum(case when medal = 'Gold' then 1 else 0 end) Gold,
		sum(case when medal = 'Silver' then 1 else 0 end) Silver,
		sum(case when medal = 'Bronze' then 1 else 0 end) Bronze
	from olympics_history oh
	join olympics_history_noc_regions as ohr
	on oh.noc = ohr.noc
	group by games, region
)

select 
	distinct(games),
	Concat(FIRST_VALUE(region) over (partition by games order by Gold desc), ' - ',
	first_value(Gold) over (partition by games order by Gold desc)) Max_Gold,
	Concat(FIRST_VALUE(region) over (partition by games order by Silver desc), ' - ',
	first_value(Silver) over (partition by games order by Silver desc)) Max_Silver,
	Concat(FIRST_VALUE(region) over (partition by games order by Bronze desc), ' - ',
	first_value(Bronze) over (partition by games order by Bronze desc)) Max_Bronze
from t1

-- Countries that won the most gold, most silver, most bronze medals and the most medals in each olympic games
with t1 as (
	select
		games,
		region,
		sum(case when medal = 'Gold' then 1 else 0 end) Gold,
		sum(case when medal = 'Silver' then 1 else 0 end) Silver,
		sum(case when medal = 'Bronze' then 1 else 0 end) Bronze,
		sum(case when medal in ('Gold', 'Silver', 'Bronze') then 1 else 0 end) Total
	from olympics_history oh
	join olympics_history_noc_regions as ohr
	on oh.noc = ohr.noc
	group by games, region
)

select 
	distinct(games),
	Concat(FIRST_VALUE(region) over (partition by games order by Gold desc), ' - ',
	first_value(Gold) over (partition by games order by Gold desc)) Max_Gold,
	Concat(FIRST_VALUE(region) over (partition by games order by Silver desc), ' - ',
	first_value(Silver) over (partition by games order by Silver desc)) Max_Silver,
	Concat(FIRST_VALUE(region) over (partition by games order by Bronze desc), ' - ',
	first_value(Bronze) over (partition by games order by Bronze desc)) Max_Bronze,
	Concat(FIRST_VALUE(region) over (partition by games order by Total desc), ' - ',
	first_value(Total) over (partition by games order by Total desc)) Max_Medals
from t1

-- Countries that have never won gold medal but have won silver/bronze medals
select *
from
	(select
		region,
		sum(case when medal = 'Gold' then 1 else 0 end) as Gold,
		sum(case when medal = 'Silver' then 1 else 0 end) Silver,
		sum(case when medal = 'Bronze' then 1 else 0 end) Bronze
	from olympics_history oh
	join olympics_history_noc_regions as ohr
	on oh.noc = ohr.noc
	group by region) medal_table
where Gold = 0
and (Silver > 0 or Bronze > 0)
order by 3 desc, 4 desc

-- Countries with the highest medals in sports
select
	distinct(sport),
	first_value(region) over (partition by sport order by Total desc) region,
	first_value(total) over (partition by sport order by Total desc) num_of_medals
from 
	(select 
		sport,
		region,
		sum(case when medal in ('Gold', 'Silver', 'Bronze') then 1 else 0 end) Total
	from olympics_history oh
	join olympics_history_noc_regions ohr
	on oh.noc = ohr.noc
	group by sport, region) sp_reg_medal