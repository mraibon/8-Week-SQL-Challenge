# Case Study #2: Pizza Runner
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/case%20study.png?raw=true)

## Introduction
In this project, Danny opened a restaurant and wants to study basic customer data.

## Schema Relationship
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/schema.png?raw=true)

## Data Exploration and Cleaning

I noticed that the customer_orders table had blank and 'null' values in both the exclusions and extras columns. I decided to create a table and change all 'null' or NULL values (see screenshot below) to blanks.

### Original
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/customer_orders%20table%20(original).png?raw=true)

### SQL
```sql
select order_id
     , customer_id
	 , pizza_id
	 , case
	       when exclusions like '%null%' then ''
		   else exclusions
		end as exclusions
	 , case
	       when extras like '%null%' or extras is null then ''
		   else extras
		end as extras
     , order_time
  into pizza_runner.customer_orders_v2 
  from pizza_runner.customer_orders
```

### Updated
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/customer_orders%20table%20(updated).png?raw=true)

Similarly, I noticed inconsistencies in the runner_orders table:

### Original
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/runner_orders%20table%20(original).png?raw=true)

### SQL
```sql
select order_id
     , runner_id
	 , case
		   when pickup_time like '%null%' then ''
		   else pickup_time
		end as pickup_time
	, case
	      when distance like '%null%' then ''
		  when distance like '%km' then trim('km' from distance)
		  else distance
	   end as distance
	, case
		  when duration like '%null%' then ''
		  when duration like '%mins' then trim('mins' from duration)
		  when duration like '%minute' then trim('minute' from duration)
		  when duration like '%minutes' then trim('minutes' from duration)
	      else duration
	   end as duration
	, case
		  when cancellation is null or cancellation like '%null%' then ''
		  else cancellation
	   end as cancellation
  into pizza_runner.runner_orders_v2 
  from pizza_runner.runner_orders
```

### Updated
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/runner_orders%20table%20(updated).png?raw=true)

Lastly, I had to make sure the new temporary tables had the correct data type for each column. The new customer_orders_v2 had correct data types; however, the runner_orders_v2 needed to be updated:

```sql
select column_name, data_type
  from INFORMATION_SCHEMA.COLUMNS
where table_name = 'runner_orders_v2'
```
### Updated
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/runner_orders%20table_v2%20data%20type.png?raw=true)

pickup_time should be datetime, distance should be float, and duration should be integer. 
```sql
ALTER TABLE pizza_runner.runner_orders_v2
ALTER COLUMN pickup_time datetime,
ALTER COLUMN distance float,
ALTER COLUMN duration int
```

## Questions and Solutions

### A. Pizza Metrics

<b> 1. How many pizzas were ordered? </b>

```sql
select count(order_id) as pizza_orders
  from pizza_runner.customer_orders_v2
 ```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A1.png?raw=true)

 > There were 14 pizzas ordered.


<b> 2. How many unique customer orders were made? </b>

```sql
select count(distinct order_id) as pizza_orders_unique
  from pizza_runner.customer_orders_v2
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A2.png?raw=true)

<b> 3. How many successful orders were delivered by each runner? </b>

```sql
select runner_id
     , count(distinct order_id) as order_count
  from pizza_runner.runner_orders_v2
 where cancellation = ''
 group by runner_id
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A3.png?raw=true)

<b> 4. How many of each type of pizza was delivered? </b>

```sql
select pizza_name
     , count(customer.order_id) as order_count
  from pizza_runner.customer_orders_v2 as customer
  join pizza_runner.runner_orders_v2 as runner
    on customer.order_id = runner.order_id
  join pizza_runner.pizza_names as pizza
    on customer.pizza_id = pizza.pizza_id
 where runner.cancellation = ''
 group by pizza_name
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A4.png?raw=true)

<b> 5. How many Vegetarian and Meatlovers were ordered by each customer? </b>

```sql
select customer_id
	 , count(case when customer.pizza_id = 1 then 1 end) as meatlovers_count
	 , count(case when customer.pizza_id = 2 then 1 end) as veggie_count
  from pizza_runner.customer_orders_v2 as customer
  join pizza_runner.pizza_names as pizza
    on customer.pizza_id = pizza.pizza_id
 group by customer_id
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A5.png?raw=true)

<b> 6. What was the maximum number of pizzas delivered in a single order? </b>

```sql
with pizza_counts as (
select customer.order_id
     , count(customer.order_id) as pizza_per_order
  from pizza_runner.customer_orders_v2 as customer
  join pizza_runner.runner_orders_v2 as runner
    on customer.order_id = runner.order_id
 where cancellation = ''
 group by customer.order_id
)

select max(pizza_per_order) as max_pizza
  from pizza_counts
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A6.png?raw=true)

<b> 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes? </b>

```sql
select customer_id
	 , sum(case when exclusions <> '' or extras <> '' then 1 else 0 end) as one_or_more_change
	 , sum(case when exclusions = '' and extras = '' then 1 else 0 end) as no_change
  from pizza_runner.customer_orders_v2 as customer
  join pizza_runner.runner_orders_v2 as runner
    on customer.order_id = runner.order_id
 where cancellation = ''
 group by customer_id
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A7.png?raw=true)

<b> 8. How many pizzas were delivered that had both exclusions and extras? </b>

```sql
select sum(case when exclusions <> '' and extras <> '' then 1 else 0 end) as exclusions_and_extras
  from pizza_runner.customer_orders_v2 as customer
  join pizza_runner.runner_orders_v2 as runner
    on customer.order_id = runner.order_id
 where cancellation = ''
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A8.png?raw=true)

<b> 9. What was the total volume of pizzas ordered for each hour of the day? </b>

```sql
select datepart(hour, order_time) as hour_of_day
     , count(order_id) as pizza_count
  from pizza_runner.customer_orders_v2
 group by datepart(hour, order_time)
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A9.png?raw=true)

<b> 10. What was the volume of orders for each day of the week? </b>

```sql
select datename(weekday, datepart(weekday, order_time)) as day_of_week
     , count(order_id) as pizza_count
  from pizza_runner.customer_orders_v2
 group by datename(weekday, datepart(weekday, order_time))
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/A/A10.png?raw=true)


### B. Runner and Customer Experience

<b> 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) </b>

```sql
select datepart(week, registration_date) as reg_week
     , count(runner_id) as runner_count
  from pizza_runner.runners
 group by datepart(week, registration_date)
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/B/B1.png?raw=true)


<b> 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? </b>

```sql
select avg(pickup_diff) avg_diff
  from (
		select c.order_id
			 , datediff(minute, order_time, pickup_time) as pickup_diff
		  from pizza_runner.customer_orders_v2 as c
		  join pizza_runner.runner_orders_v2 as r
			on c.order_id = r.order_id
		 where cancellation = ''
		 group by c.order_id, datediff(minute, order_time, pickup_time)
		) diff_by_order
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/B/B2.png?raw=true)

<b> 3. Is there any relationship between the number of pizzas and how long the order takes to prepare? </b>

```sql
select number_of_pizzas
     , avg(prep_time) as avg_prep_time
  from (
		select c.order_id
			 , datediff(minute, order_time, pickup_time) as prep_time
			 , count(c.pizza_id) as number_of_pizzas
		  from pizza_runner.customer_orders_v2 as c
		  join pizza_runner.runner_orders_v2 as r
			on c.order_id = r.order_id
		 where cancellation = ''
		 group by c.order_id, datediff(minute, order_time, pickup_time)
		) diff_by_order
  group by number_of_pizzas
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/B/B3.png?raw=true)

<b> 4. What was the average distance travelled for each customer? </b>

```sql
select customer_id
     , avg(distance) as average_distance
  from pizza_runner.customer_orders_v2 as c
  join pizza_runner.runner_orders_v2 as r
    on c.order_id = r.order_id
 where cancellation = ''
 group by customer_id
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/B/B4.png?raw=true)

<b> 5. What was the difference between the longest and shortest delivery times for all orders? </b>

```sql
select max(duration) - min(duration) as long_short_diff
 from pizza_runner.runner_orders_v2
 where cancellation = ''
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/B/B5.png?raw=true)


<b> 6. What was the average speed for each runner for each delivery and do you notice any trend for these values? </b>

```sql
select runner_id
     , distance / duration * 60.0 as avg_speed
 from pizza_runner.runner_orders_v2
 where cancellation = ''
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/B/B6.png?raw=true)

<b> 7. What is the successful delivery percentage for each runner? </b>

```sql
select runner_id
     , round(sum(case when cancellation = '' then 1 else 0 end) * 100 / count(order_id),0) as completion_percentage
 from pizza_runner.runner_orders_v2
group by runner_id
```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%232/B/B7.png?raw=true)


### C. Ingredient Optimisation 

<b> 1. What are the standard ingredients for each pizza? </b>

<b> 2. What was the most commonly added extra? </b>

<b> 3. What was the most common exclusion? </b>

<b> 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
* Meat Lovers
* Meat Lovers - Exclude Beef
* Meat Lovers - Extra Bacon
* Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers </b>

<b> 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
* For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" </b>

<b> 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first? </b>