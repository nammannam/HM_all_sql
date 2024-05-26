---CUSTOMERS---
--Add customer---
CREATE FUNCTION new_customer(rankid_in int, personalid_in varchar, firstname_in varchar, lastname_in varchar, birthdate_in date, gender_in char, email_in varchar, phone_in varchar, address_in varchar, OUT custadded_out BIGINT)
	RETURNS bigint 
	AS $$
	DECLARE find int;
	BEGIN
		SELECT count(*) INTO find
		FROM customers WHERE personalid = personalid_in;
		IF find = 0 THEN
		INSERT INTO 
			customers(rankid, 
					 personalid,
					 firstname,
					 lastname,
					 birthdate,
					 gender,
					 email,
					 phone,
					 address)
		VALUES (rankid_in,
			   personalid_in,
			   firstname_in,
			   lastname_in,
			   birthdate_in,
			   gender_in,
			   email_in,
			   phone_in,
			   address_in);
		SELECT currval(pg_get_serial_sequence('customers', 'customerid')) INTO custadded_out;
		
		ELSE
		custadded_out = 0;
		END IF;
	END
	$$
	LANGUAGE plpgsql;	
---
--TESTING--
select new_customer(3, '202215', 'Khanh Nam', 'Nguyen', '2004-02-21', 'M',null, '113', 'Hanoi')

select * from customers
	where customerid >= 500000
---

--Delete customer---
CREATE FUNCTION delete_customer(s_customerid bigint, s_personalid varchar, OUT res_del bigint)
	RETURNS bigint
	AS $$
	DECLARE row_returns int;
	BEGIN
		SELECT count(*) INTO row_returns
		FROM customers WHERE customerid = s_customerid OR personalid = s_personalid;
		IF row_returns = 1 THEN
			res_del = s_customerid;
			DELETE FROM customers
			WHERE customerid = s_customerid OR personalid = s_personalid;
			
		ELSE 
			res_del = 0;
		
		END IF;
		END
		$$
	LANGUAGE plpgsql;

---

--TESTING---
select delete_customer(500013, '20225749')
----

--Search customerID with pid or (name and phone)--
	CREATE FUNCTION search_customer(s_personalid varchar, s_fname varchar, s_lname varchar, s_phone varchar, OUT found_out bigint)
		RETURNS bigint 
		AS $$
		DECLARE row_returns int;
		BEGIN
			IF (s_fname IS NULL) AND (s_lname IS NULL) AND (s_phone IS NULL) AND (s_personalid IS NOT NULL) THEN
			
				SELECT count(*) INTO row_returns
				FROM customers WHERE personalid = s_personalid;
				
				IF row_returns = 1 THEN
				
				SELECT customerid INTO found_out
				FROM customers WHERE personalid = s_personalid;
				
				ELSE
				
				found_out = 0;
				
				END IF;
				
				
			ELSIF (s_fname IS NOT NULL) AND (s_lname IS NOT NULL) AND (s_phone IS NOT NULL) AND (s_personalid IS NULL) THEN
			
				SELECT count(*) INTO row_returns
				FROM customers 
				WHERE firstname = s_fname AND lastname = s_lname AND phone = s_phone;
				
				IF row_returns = 1 THEN
				
				SELECT customerid INTO found_out
				FROM customers 
				WHERE firstname = s_fname AND lastname = s_lname AND phone = s_phone;
				
				ELSE
				
				found_out = 0;
				
				END IF;
			ELSE
				--Khong thoa man tat ca
				found_out = 0;
				
			END IF;
		
		END
		$$
	LANGUAGE plpgsql;
	
------------------------
----------NOTE---------
--
--Phone nên để unique và mỗi khách có 1 sđt riêng 
--mới có thể sử dụng function search_customer trong TH không có personalID
--
------------------------

---TESTING---------------

select * from customers
	where customerid >= 500000

select count(customerid) as cnt from customers
	group by personalid
	having count(customerid) > 0;

--here--
select search_customer('202215', null,null,null);

---

--Search customer by customerID OR with PersonalID from above function
CREATE FUNCTION show_customer(pid_in varchar)
	RETURNS TABLE(	
	customerIDf bigint,
	rankIDf int,
	personalIDf varchar ,
	firstnamef varchar ,
	lastnamef varchar ,
	birthdatef date,
	genderf char,
	emailf varchar,
	phonef varchar,
	addressf varchar)
	AS
	$$
	DECLARE cid bigint;
	BEGIN
		cid = search_customer(pid_in, null, null, null);
		RETURN QUERY 
		SELECT * FROM customers
		WHERE customerid = cid;
	
	END
	$$
	LANGUAGE plpgsql;

---------
-----TESTING--------
explain analyze
SELECT * FROM customers
	WHERE customerid = 500017;

--TH này rất lâu lâu hơn nhiều so với TH trên
explain analyze
SELECT * FROM customers
	WHERE customerid = search_customer('202215', null,null,null);
	
--dùng như sau nhanh hơn
explain analyze
select * from show_customer('202216');

-------------------

------Edit customer--------

--dùng UPDATE cho từng thuộc tính cần chỉnh sửa

-----------------------

-----BOOKING------

------ADD BOOKING-------
	CREATE FUNCTION new_booking(customerid_in bigint, bookingdate_in date, bookingtype_in varchar, totaladult_in int, totalchild_in int, OUT add_bk bigint)
		RETURNS bigint
		AS
		$$
		DECLARE	check_cust int;
		BEGIN
		
			SELECT count(*) INTO check_cust
			FROM customers WHERE customerid = customerid_in;
			
			IF check_cust = 1 THEN
			
			INSERT INTO booking(
						customerid,
						bookingdate,
						bookingtype,
						totaladult,
						totalchild)
			VALUES (customerid_in,
				   	bookingdate_in,
				    bookingtype_in,
					totaladult_in,
					totalchild_in);
					
				SELECT currval(pg_get_serial_sequence('booking', 'bookingid')) INTO add_bk;
				
				--Tính số đơn đã đặt từ trước giờ của khách đó nếu chưa đặt đơn nào 0 thì phải tạo mới CUSTOMER
				--SELECT COUNT(bookingid) INTO count_bk
				--FROM booking 
				--GROUP BY customerid
				--HAVING customerid = customerid_in;
				
				--numberofbooking = count_bk;
				
			ELSE
				add_bk = 0;
				
			END IF;
		END
		$$
		LANGUAGE plpgsql;


-----TESTING--------

select * from booking
	where bookingid > 700000;
	
select * from customers
	where customerid >= 500000;
	
INSERT INTO booking(customerid, bookingdate, bookingtype, totaladult, totalchild)
VALUES (500006, current_date, 'pre ordered', 2,2);

SELECT new_booking(500016, current_date,'đặt tại chỗ',10,0);

--------------------








