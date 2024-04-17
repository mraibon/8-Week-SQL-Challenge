select runner_id
     , count(distinct order_id) as order_count
  from pizza_runner.runner_orders_v2
 where cancellation = ''
 group by runner_id

select pizza_name
     , count(customer.order_id) as order_count
  from pizza_runner.customer_orders_v2 as customer
  join pizza_runner.runner_orders_v2 as runner
    on customer.order_id = runner.order_id
  join pizza_runner.pizza_names as pizza
    on customer.pizza_id = pizza.pizza_id
 where runner.cancellation = ''
 group by pizza_name


select customer_id
	 , count(case when customer.pizza_id = 1 then 1 end) as meatlovers_count
	 , count(case when customer.pizza_id = 2 then 1 end) as veggie_count
  from pizza_runner.customer_orders_v2 as customer
  join pizza_runner.pizza_names as pizza
    on customer.pizza_id = pizza.pizza_id
 group by customer_id

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



select customer_id
	 , sum(case when exclusions <> '' or extras <> '' then 1 else 0 end) as one_or_more_change
	 , sum(case when exclusions = '' and extras = '' then 1 else 0 end) as no_change
  from pizza_runner.customer_orders_v2 as customer
  join pizza_runner.runner_orders_v2 as runner
    on customer.order_id = runner.order_id
 where cancellation = ''
 group by customer_id

select sum(case when exclusions <> '' and extras <> '' then 1 else 0 end) as exclusions_and_extras
  from pizza_runner.customer_orders_v2 as customer
  join pizza_runner.runner_orders_v2 as runner
    on customer.order_id = runner.order_id
 where cancellation = ''

 
select datepart(hour, order_time) as hour_of_day
     , count(order_id) as pizza_count
  from pizza_runner.customer_orders_v2
 group by datepart(hour, order_time)


select datename(weekday, datepart(weekday, order_time)) as day_of_week
     , count(order_id) as pizza_count
  from pizza_runner.customer_orders_v2
 group by datename(weekday, datepart(weekday, order_time))
 

