-- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
with total_spend as
(
select sum(cast(amount as bigint)) as total from Credit_card
),city_spend as(
select city,sum(amount) as spend from Credit_card
group by city)
select top 5 city,spend,(spend*1.0/total)*100 as con from city_spend
join total_spend on 1=1
order by con desc;


-- write a query to print highest spend month and amount spent in that month for each card type.
with highest_spend as (select card_type,datepart(year,date) as yr,datepart(month,date) as mnt,sum(amount) as spend from credit_card
group by card_type,datepart(month,date),datepart(year,date)
)
select * from (select *,rank() over(partition by card_type order by spend desc) as rn from highest_spend) a
where rn=1


/*write a query to print the transaction details(all columns from the table) for each card
type when it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)*/

with total_amt as (select *,sum(amount) over(partition by card_type order by date,indx) as cumulative_amount from credit_card)
,rnk as (select *,rank() over(partition by card_type order by cumulative_Amount) as rn from total_amt where cumulative_amount>1000000)
select * from rnk
where rn=1 

-- write a query to find city which had lowest percentage spend for gold card type
with cte as(select city,card_type,sum(amount) as total,sum(case when card_type='gold'then amount end ) as gold_amount from credit_card
group by city,card_type)
select top 1 city,sum(gold_amount)*1.0/sum(total) as perc from cte
group by city
having sum(gold_amount)>0
order by perc

-- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
with cte as(select city,Exp_type,sum(amount) as exp_amount from Credit_card
group by city,Exp_type),rnk as(
select *,rank() over(partition by city order by exp_amount ) as rank_asc,rank() over(partition by city order by exp_amount desc ) as rank_desc from cte)
select city,max(case when rank_asc=1 then exp_type end) as lowest_expense_type,min(case when rank_desc=1 then exp_type end) as highest_expense_type from rnk
group by city

-- write a query to find percentage contribution of spends by females for each expense type
with cte as(select Exp_type,sum(amount) as total,sum(case when gender='F' then amount end ) as female_amount from credit_card
group by Exp_type)
select Exp_type,sum(female_amount)*1.0/sum(total) as perc from cte
group by Exp_type

-- which card and expense type combination saw highest month over month growth in Jan-2014
with cte as(select card_type,exp_type,datepart(year,date) as yr,datepart(month,date) as mnt,sum(amount) as spend from credit_card
group by card_type,exp_type,datepart(year,date) ,datepart(month,date) ),
A as(select *,lag(spend) over(partition by card_type,exp_type order by yr,mnt)  as previous_month_spend from cte)
select top 1 * ,(spend-previous_month_spend )as mom_growth from A
where yr=2014 and mnt=1 and prev_mont_spend is not null
order by mom_growth desc

-- during weekends which city has highest total spend to total no of transcations ratio 
	select top 1 city,sum(amount) as spend from credit_card
	where datename(weekday,date) in ('saturday','sunday')
	group by city,datename(weekday,date)
	order by spend desc


-- which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as(select city,date,indx
,row_number() over(partition by city order by date,indx) as rn
from credit_card
)
select top 1 city,datediff(day,min(date),max(date)) as dys 
from cte
where rn=1 or rn=500 
group by city
having count(1)=2
order by dys
