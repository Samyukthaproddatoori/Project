--1 which team has won the maximum gold medals over the years.
select top 1 team,count(distinct event) as no_of_gold_medal from athletes a join athlete_events ae on a.id=ae.athlete_id
where medal ='gold'
group by team 
order by no_of_gold_medal desc
--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
with yr_medal as(select  team,year,count(distinct event) as silver_medals,rank() over(partition by team order by count(distinct event)) as rn from athletes a join athlete_events ae on a.id=ae.athlete_id
where medal ='silver'
group by team,year)
select team,sum(silver_medals) as total_silver_medals, max(case when rn=1 then year end) as  year_of_max_silver
from yr_medal
group by team;

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
with cte as(select name,medal from athletes a join athlete_events ae on a.id=ae.athlete_id)
select top 1 name,count(medal) gold_medal from cte 
where name not in (select distinct name from cte where medal in ('silver','bronze')) and medal='gold'
group by name
order by gold_medal desc


--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
with cte as(select name,count(event) as no_of_gold_medal,year  from athletes a join athlete_events ae on a.id=ae.athlete_id
where medal='gold'
group by name ,year),b as(
select name,year,no_of_gold_medal,rank() over(partition by year order by no_of_gold_medal desc) as rn from cte)
select year,no_of_gold_medal,STRING_AGG(name,',') as player_name from b 
where rn=1
group by year,no_of_gold_medal;



--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport
with cte as(select distinct team,medal,event,year  from athletes a join athlete_events ae on a.id=ae.athlete_id
where team='India' and medal != 'NA')
select * from (select team,medal,year,event,rank() over(partition by medal order by year) as rn from cte) A
where rn=1




--6 find players who won gold medal in summer and winter olympics both.
select distinct name,season  from athletes a join athlete_events ae on a.id=ae.athlete_id
where medal='gold' 
group by name,season
having count(distinct season)=2



--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select name,year  from athletes a join athlete_events ae on a.id=ae.athlete_id 
where medal!='NA'
group by name,year
having count(distinct medal)=3

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with cte as(select name,year,event  from athletes a join athlete_events ae on a.id=ae.athlete_id 
where medal='gold' and year >=2000 and season='Summer'
group by name,year,event),
B as(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte)
select * from B 
where year=prev_year+4 and year=next_year-4