-- Who is the most senier employee based on job title?
select first_name,last_name from employee
order by levels desc
limit 1

-- Which country has most invoices?
select count(*) as count_invoice, billing_country from invoice
group by billing_country
order by count_invoice desc
limit 1

-- What are top 3 values of total invoices?
select total from invoice
order by total desc
limit 3

-- Which city has the best customers? We would give the promotional music festival in the city we made the most money.
-- Write a query that returns the city which have highest number invoice total.
select sum(total) as total_invoice, billing_city from invoice
group by billing_city
order by total_invoice desc
limit 1

-- Who is the best customer? Customer who has spent the most money will be declaed as the best customer.
-- Write a query which returns the name of best customer.
select first_name, last_name, sum(invoice.total) as total_invoice from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total_invoice desc
limit 1

-- Write a query that returns the email,fist name, last name and genre of all rock music listners.
-- Return email alpabetically.
select distinct email,first_name, last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id  = invoice_line.invoice_id
where track_id in (
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name = 'Rock'
)
order by email

		-- OR THIS QUERY	
		
select distinct email,first_name, last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id  = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
order by email

-- Let's invite the artists who has written most rock music.
-- Write a query that returns artists name and total track count of top 10 rock bands.
select artist.name, count(artist.artist_id) as number_of_songs from track
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10

-- Return all the track name having song length longer than average song length.
-- Return name and milliseconds for each track.
-- Order by song length with the longest songs listed first.
select name, milliseconds from track
where milliseconds > (
	select avg(milliseconds) from track
)
order by milliseconds desc

-- Find how much amount spent by each customer on artists?
-- Write a query to return customer name,artist name and total spent.
with best_artist as (
select artist.artist_id, artist.name, sum(invoice_line.quantity * invoice_line.unit_price) from invoice_line
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by artist.artist_id
order by 3 desc
limit 1
)

select customer.first_name, customer.last_name, best_artist.name, sum(invoice_line.quantity * invoice_line.unit_price) from invoice
join customer on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id  = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join best_artist on album.artist_id = best_artist.artist_id
group by 1,2,3
order by 4 desc

-- Find out the most popular genre for each country. We determine the most popular genre which has the highest amount of purchase.
-- Write a query that return each country along with top genre.
with popular_genre as(
select count(invoice_line.quantity), genre.genre_id, genre.name, customer.country,
row_number() over(partition by(customer.country) order by count(invoice_line.quantity) desc) from invoice_line
join invoice on invoicrow_nume_line.invoice_id = invoice.invoice_id
join customer on invoice.customer_id = customer.customer_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
group by 2,3,4
order by 4 asc,1 desc
)
select * from popular_genre where row_number <=1

-- Write a query that determines the customers that has spend the most on music for each country.
-- Write a query that returns the country name along with the top customers and how much they spent.
-- For the countries where the top amount is shared, provide all cusomters who spent this amount.
with recursive customer_with_country as (
select customer.customer_id, customer.first_name, customer.last_name, billing_country, sum(total) as total_spending from invoice
join customer on invoice.customer_id = customer.customer_id
group by 1,2,3,4
order by 5 desc ),

country_max_spending  as (
select max(total_spending) as max_spending, billing_country from customer_with_country
group by billing_country )

select cc.billing_country, cc.customer_id, cc.first_name, cc.last_name, cc.total_spending from customer_with_country cc
join country_max_spending cs on cc.billing_country = cs.billing_country
where cc.total_spending = cs.max_spending
order by 1
