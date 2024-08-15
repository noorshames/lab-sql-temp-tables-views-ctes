USE SAKILA;
#1. Step 1: Create a View

#First, create a view that summarizes rental information for each customer. 
#The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_info AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.customer_id) AS rental_count

FROM customer AS c
JOIN rental AS r
on r.customer_id = c.customer_id

GROUP BY 
 c.customer_id, c.first_name, c.last_name, c.email;
#-------------------------------------------------------------------------------------------------
#Step 2: Create a Temporary Table

# Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
#The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate
# the total amount paid by each customer.
DROP TEMPORARY TABLE IF EXISTS total_amount_paid;
CREATE TEMPORARY TABLE total_amount_paid AS
SELECT cri.customer_id, cri.first_name, cri.last_name, cri.email, cri.rental_count, SUM(p.amount) AS paid_amount


FROM payment AS p
JOIN customer_rental_info AS cri
on cri.customer_id = p.customer_id


GROUP BY 
cri.customer_id, cri.first_name, cri.last_name, cri.email, cri.rental_count;
#-------------------------------------------------------------------------------------------------

#3 Step 3: Create a CTE and the Customer Summary Report

#Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
#The CTE should include the customer's name, email address, rental count, and total amount paid.
#Next, using the CTE, create the query to generate the final customer summary report.
#which should include: customer name, email, rental_count, total_paid and average_payment_per_rental
	#this last column is a derived column from total_paid and rental_count.
DROP TEMPORARY TABLE IF EXISTS total_amount_paid;
WITH customer_summary_report AS
 (SELECT 
	tp.customer_id, 
    tp.first_name,
    tp.last_name,
    tp.email,
    tp.rental_count,
	tp.paid_amount

FROM total_amount_paid tp)

SELECT 
	csr.customer_id, 
    csr.first_name,
    csr.last_name,
    csr.email,
    csr.rental_count,
	csr.paid_amount,
    (csr.paid_amount/csr.rental_count) AS average_payment_per_rental

FROM customer_summary_report AS csr;

