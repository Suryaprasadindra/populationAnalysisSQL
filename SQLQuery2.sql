select * from project.dbo.Data1
select * from project.dbo.Data2

select count(*) from project..Data1
select count(*) from project..data2

--dataset for jarkhand and bihar

select * from project..data1 where state in ('jharkhand','bihar')

--population of india

select sum(population) from project..data2

---population of india with column name

select sum(population) as population from project..data2

--avg growth

select avg(growth)*100 as avg_growth from project..data1;

select state,avg(growth)*100 as avg_growth from project..data1 group by state;

select state,round(avg(sex_ratio),0) as avg_sex_ratio from project..data1 group by state order by avg_sex_ratio desc;

select state,round(avg(literacy),0) as avg_literacy from project..data1 group by state having round(avg(literacy),0) > 90 order by avg_literacy desc;

--top 3 states
select top 3 state,avg(growth)*100 as avg_growth from project..data1 group by state order by avg_growth desc;
--bottom 3 states
select top 3 state,avg(growth)*100 as avg_growth from project..data1 group by state order by avg_growth asc;

-- top 3 in temporay table

drop table  if exists top_table; 
create table top_table (
state nvarchar(255),
avg_literacy float)

insert into top_table select state,round(avg(literacy),0) as avg_literacy from project..data1 group by state order by avg_literacy desc;

select top 3 *from top_table

-- bottom 3 in temporary table

drop table if exists bottom_table;
create table bottom_table(state nvarchar(255),avg_literacy float)
insert into bottom_table select state,round(avg(literacy),0) as avg_literacy from project..data1 group by state order by avg_literacy asc;
select top 3 * from bottom_table;

--- top 3 and bottom 3 both in a single column

select * from (select top 3 * from top_table order by avg_literacy desc) a
union
select * from (select top 3 * from bottom_table order by avg_literacy asc) b;

-- states which are having first lettr a or end letter m ,a and  m

select distinct state from project..data1 where lower(state) like 'a%'  
select distinct state from project..data1 where lower(state) like 'a%' or lower(state) like '%m'  
select distinct state from project..data1 where lower(state) like 'a%' and lower(state) like '%m'  

-- joining both table using inner join 

select a.district,a.state,a.sex_ratio,b.population from project..data1 a inner join  project..data2 b on a.District = b.District 

--- calculating total number of males and females

select c.district,c.state,round(c.population/(1+c.sex_ratio),0) males,round(c.population * (c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from project..data1 a inner join  project..data2 b on a.District = b.District) c 

--- calculating total of males and females state wise

select d.state,sum(d.males) total_no_males,sum(d.females) total_no_females from
(select c.district,c.state,round(c.population/(1+c.sex_ratio),0) males,round(c.population * (c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from project..data1 a inner join  project..data2 b on a.District = b.District) c ) d
group by d.state 

-- calclulating total literacy people and total illiteracy people state wise

select d.state,sum(total_litercy_people) total_litercy_people,sum(total_illitercy_people) total_illitercy_people from
(select c.District,c.state,round(c.literacy_ratio*(c.Population),0) total_litercy_people,round((1-c.literacy_ratio)*(c.Population),0) total_illitercy_people  from
(select a.District,a.state,a.literacy/100 literacy_ratio,b.population from project..data1 a inner join project..data2 b on a.district = b.district) c ) d
group by d.State


-- calculating previous census population  and current sensu population

select sum(e.previous_population) previous_population,sum(e.current_population) current_population from
(select d.state,sum(d.previous_population) previous_population,sum(d.current_population) current_population from
(select c.district,c.state,round((c.population)/(1+ c.growth_rate),0) previous_population ,c.population current_population from
(select a.District,a.state,a.Growth growth_rate,b.population from project..data1 a inner join project..data2 b on a.district = b.district) c) d
group by d.State ) e

-- area vs population

select j.total_area/j.previous_population previous_population_vs_area, j.total_area/j.current_population current_population_vs_area from
(select h.*,i.total_area from
(select '1' as keyy,f.* from
(select sum(e.previous_population) previous_population,sum(e.current_population) current_population from
(select d.state,sum(d.previous_population) previous_population,sum(d.current_population) current_population from
(select c.district,c.state,round((c.population)/(1+ c.growth_rate),0) previous_population ,c.population current_population from
(select a.District,a.state,a.Growth growth_rate,b.population from project..data1 a inner join project..data2 b on a.district = b.district) c) d
group by d.State ) e)f)h inner join ( 

select '1' as keyy,g.* from
(select sum(area_km2) total_area from project..data2)g)i on h.keyy = i.keyy ) j

--- top 3 districts from each state with highest literacy rate

select a.district,a.state,a.literacy,a.rnk from
(select district,state,literacy,rank() over (partition by state order by literacy) rnk from project..data1 ) a
where a.rnk in (1,2,3) order by a.State

