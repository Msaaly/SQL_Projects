USE mavenfuzzyfactory;

/*
1. The CEO of the company wants to show their volume growth. they asked to pull overall session and order volume,
trended by quarter for the life of the buisiness? handle the most recent quarter since the data for that quarter is incomplete.
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qrt,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders
From website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id= orders.website_session_id
where website_sessions.created_at < '2014-12-30'
GROUP BY 1, 2
ORDER BY 1, 2;

/*
2. CEO wants to showcase all of the efficiency improvements. She would like to show quarterly figures
since the company launched, for session-to-order conversion rate, revenue per order, and revenue per session.
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qrt,
	COUNT(DISTINCT website_sessions.website_session_id)/COUNT(DISTINCT orders.order_id) AS session_to_order_cr,
    SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS revenue_per_order,
    COUNT(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id= orders.website_session_id
where website_sessions.created_at < '2014-12-30'
GROUP BY 1, 2
ORDER BY 1, 2;

/* 
3. CEO wants to show how specific selling channels have grown. She asked to pull a quarterly view of orders 
from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qrt,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_search_orders,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_type_in_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2014-12-30'
GROUP BY 1,2
ORDER BY 1,2;

/*
4. The CEO wants to show the overall session-to-order conversion rate trends for those same channels
by quarter.
*/
SELECT 
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qrt,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
    / COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rt,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_conv_rt,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2014-12-30'
GROUP BY 1,2
ORDER BY 1,2; 

/*
5. CEO aasked to pull monthly trending for revenue and margin by product, along with
total sales and revenue.
*/
SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
	SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_product_rev,
 	SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_product_marg,
	SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_product_rev,
 	SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS love_bear_product_marg,    
	SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_product_rev,
 	SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_product_marg,   
 	SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_product_rev,
 	SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_product_marg,
    sum(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items
GROUP BY 1,2
ORDER BY 1,2; 
 
 -- Inspection: looking at the results, it seems that there is a spike in sales around month of February. The products were initially aimed to be 
 -- sold to couples. As planned, the product sale increased during valentine's day each year.
 
 /* 
 6. CEO wants to look at the impact of introducing new products. She asked to pull monthly sessions to the /products page, and show how the % of 
 those sessions clicking through another page has changed over time, along with a view of how conversion from /products to placing an order has improved.
 */
 -- first we want to identify all the views of /products page
CREATE TEMPORARY TABLE products_pageviews
SELECT
    website_pageview_id,
    website_session_id,
    created_at AS saw_product_page_at
FROM website_pageviews
WHERE pageview_url = '/products';
 
SELECT
	YEAR(saw_product_page_at) as yr,
    MONTH(saw_product_page_at) as mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS cliked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id)/ COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rt,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.website_session_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS products_ro_order_rt
FROM products_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id=products_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
    LEFT JOIN orders
		ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1, 2;
 
/*
7. The compacny made their 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item).
CEO asked to pull sales data since then, and show how well each product cross-sells from one another?
*/

CREATE TEMPORARY TABLE primary_products
SELECT 
	order_id, 
    primary_product_id, 
    created_at AS ordered_at
FROM orders 
WHERE created_at > '2014-12-05' -- when the 4th product was added 
;

SELECT 
	primary_product_id, 
    COUNT(DISTINCT order_id) AS total_orders, 
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM
(
SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0 -- only bringing in cross-sells
) AS primary_w_cross_sell
GROUP BY 1;










