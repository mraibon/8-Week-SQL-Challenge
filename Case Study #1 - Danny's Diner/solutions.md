# Case Study #1: Danny's Diner
![image](https://8weeksqlchallenge.com/images/case-study-designs/1.png)

## Introduction
In this project, Danny opened a restaurant and wants to study basic customer data.

## Schema Relationship
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/casestudy1.png?raw=true)

## Questions and Solutions

<b> 1. What is the total amount each customer spent at the restaurant? </b>

```sql
select customer_id
     , sum(price) as amount_spent
  from sales 
  join menu
    on sales.product_id = menu.product_id
 group by customer_id
 ```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q1.png?raw=true)

 >* Customer A spent $76
 >* Customer B spent $74
 >* Customer C spent $36

 <b> 2. How many days has each customer visited the restaurant? </b>

 ```sql
 select customer_id
     , count(distinct order_date) as restaurant_visits
  from sales
 group by customer_id
 ```

 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q2.png?raw=true)

> * Customer A has visited 4 times.
> * Customer A has visited 6 times.
> * Customer B has visited twice.

 <b> 3. What was the first item from the menu purchased by each customer? </b>

```sql
with all_orders as(

select customer_id
     , product_name
	 , rank() over(partition by customer_id order by order_date asc) as order_of_orders
  from sales
  join menu 
    on sales.product_id = menu.product_id
)

select customer_id
     , product_name
  from all_orders
 where order_of_orders = 1
 ```
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q3.png?raw=true)

> * Customer A ordered sushi and curry first
> * Customer B ordered curry first
> * Customer C ordered ramen first

<b> 4. What is the most purchased item on the menu and how many times was it purchased by all customers? </b>

```sql
select product_name
     , count(product_name) as times_purchased
  from sales
  join menu
    on sales.product_id = menu.product_id
 group by product_name
```
 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q4.png?raw=true)

> Ramen is the most purchased item. It has been purchased 8 times. 

<b> 5. Which item was the most popular for each customer? </b>

```sql
select customer_id
     , product_name
	 , count(sales.product_id) as times_ordered
  from sales 
  join menu
    on sales.product_id = menu.product_id
 group by customer_id, product_name
 order by 1 asc, 3 desc
```
 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q5.png?raw=true)

 > * For Customer A, ramen was the most popular item.
 > * For Customer B, he ordered all three item the same number of times.
 > * For Customer C, ramen was the most popular item.

<b> 6. Which item was purchased first by the customer after they became a member? </b>

```sql
with member_purchases as (
select sales.customer_id
     , product_name
	 , order_date
	 , row_number() over (partition by sales.customer_id order by order_date asc) as order_no
  from sales
  join menu
    on sales.product_id = menu.product_id
  join members
    on sales.customer_id = members.customer_id
   and sales.order_date > members.join_date
)

select customer_id
     , product_name
  from member_purchases
 where order_no = 1
```
 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q6.png?raw=true)

> * After becoming a member, Customer A ordered ramen.
> * After becoming a member, Customer B ordered sushi.

<b> 7. Which item was purchased just before the customer became a member? </b>

```sql
with member_purchases as (
select sales.customer_id
     , product_name
	 , order_date
	 , row_number() over (partition by sales.customer_id order by order_date desc) as order_no
  from sales
  join menu
    on sales.product_id = menu.product_id
  join members
    on sales.customer_id = members.customer_id
   and sales.order_date < members.join_date
)

select customer_id
     , product_name
  from member_purchases
 where order_no = 1
```
 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q7.png?raw=true)

> Just before becoming members, both Customer A and Customer B ordered sushi.

<b> 8. What is the total items and amount spent for each member before they became a member? </b>

```sql
select sales.customer_id
     , count(product_name) as total_products
	 , sum(price) as total_sales
  from sales 
  join menu
    on sales.product_id = menu.product_id
  join members
    on sales.customer_id = members.customer_id
   and sales.order_date < members.join_date
 group by sales.customer_id
 order by sales.customer_id
```
 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q8.png?raw=true)

> * Customer A ordered 2 items and spent $25 before becoming a member.
> * Customer B ordered 3 items and spent $40 before becoming a member.

<b> 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? </b>

```sql
select customer_id 
     , sum(points) as total_points
  from sales
  join (
		select product_name
		     , product_id
			 , case 
				   when product_name = 'sushi' then price * 20
				   else price * 10
				end as points
		  from menu
	   ) menu
    on sales.product_id = menu.product_id
 group by customer_id
```
 ![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q9.png?raw=true)

> * Customer A would have 860 points.
> * Customer B would have 940 points.
> * Customer C would have 360 points.

<b> 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi. How many points do customer A and B have at the end of January? </b>

```sql
select customer_id
     , sum(price) as totalpoints
  from (
select sales.customer_id
     , case 
	       when datediff(day, join_date, order_date) between 0 and 6 then price * 20
		   when product_name = 'sushi' then price * 20
		   else price * 10
		end as price
  from sales
  join menu
    on sales.product_id = menu.product_id
  join members
    on sales.customer_id = members.customer_id
 where month(order_date) = 1
	   ) as points
 group by customer_id
```
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/q10.png?raw=true)

> * Customer A has 1,370 points.
> * Customer B has 820 points.

<b> Bonus Questions </b>

Desiginating if a customer is a member or not
```sql
select sales.customer_id
     , sales.order_date
	 , menu.product_name
	 , menu.price
	 , case 
	       when join_date is not null then 'Y'
		   else 'N'
		end as member_sts	 
  from sales
  join menu
    on sales.product_id = menu.product_id
  left join members
    on sales.customer_id = members.customer_id
```
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/bonus1.png?raw=true)

Ranking of products for members
```sql
with cte as (
select sales.customer_id
     , sales.order_date
	 , menu.product_name
	 , menu.price
	 , join_date
	 , case 
	       when join_date is not null and order_date >= join_date then 'Y'
		   else 'N'
		end as member_sts
  from sales
  join menu
    on sales.product_id = menu.product_id
  left join members
    on sales.customer_id = members.customer_id
)
select customer_id
     , order_date
	 , product_name
	 , price
	 , member_sts
 	 , case 
	       when member_sts = 'Y' then rank() over(partition by customer_id, member_sts order by order_date asc) 
		   else null
		end as ranking
  from cte
```
![image](https://github.com/mraibon/8-Week-SQL-Challenge/blob/main/SQL%20Challenge%20Screenshots/Case%20Study%20%231/bonus2.png?raw=true)