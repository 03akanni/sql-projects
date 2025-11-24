Create Database T_Global_db
Select Top 5 * from global_customers;
Select Top 5 * from global_products;
Select Top 5 * from global_orders;
Select Top 5 * from global_order_details;

--Total Revenue, Total Quantity Sold, Total Orders
SELECT
    SUM(od.TotalSales) AS TotalRevenue,
    SUM(od.Quantity) AS TotalQuantitySold,
    COUNT(DISTINCT o.OrderID) AS TotalOrders
FROM global_order_details od
INNER JOIN global_orders o ON od.OrderID = o.OrderID;

--Revenue by Product
SELECT
    p.Category,
    SUM(od.TotalSales) AS Revenue
FROM global_order_details od
JOIN global_products p ON od.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY Revenue DESC;

--Monthly Revenue Trend
SELECT
    DATENAME(MONTH, o.OrderDate) AS MonthName,
    MONTH(o.OrderDate) AS MonthNumber,
    SUM(od.TotalSales) AS Revenue
FROM global_order_details od
JOIN global_orders o ON od.OrderID = o.OrderID
GROUP BY DATENAME(MONTH, o.OrderDate), MONTH(o.OrderDate)
ORDER BY MonthNumber;

--Top 10 Customers by Spend
SELECT TOP 10
    c.CustomerName,
    SUM(od.TotalSales) AS Revenue
FROM global_order_details od
JOIN global_orders o ON od.OrderID = o.OrderID
JOIN global_customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerName
ORDER BY Revenue DESC;

--Highest Selling Products(Units)
SELECT TOP 1
    p.ProductName,
    SUM(od.Quantity) AS UnitsSold
FROM global_order_details od
JOIN global_products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY UnitsSold DESC;

--Monthly YoY Growth(%)
WITH MonthlyRevenue AS (
    SELECT
        YEAR(o.OrderDate) AS Yr,
        MONTH(o.OrderDate) AS Mn,
        SUM(od.TotalSales) AS Revenue
    FROM global_order_details od
    JOIN global_orders o ON od.OrderID = o.OrderID
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
),
GrowthCalc AS (
    SELECT 
        Yr,
        Mn,
        Revenue,
        LAG(Revenue) OVER (ORDER BY Yr, Mn) AS PrevRevenue
    FROM MonthlyRevenue
)
SELECT
    Yr,
    Mn,
    Revenue,
    PrevRevenue,
    ((Revenue - PrevRevenue) / PrevRevenue) * 100 AS YoY_Growth_Percent
FROM GrowthCalc
ORDER BY Yr, Mn;

--Customer Retention (Returning vs New Customers)
WITH FirstOrder AS (
    SELECT 
        CustomerID,
        MIN(OrderDate) AS FirstPurchaseDate
    FROM global_orders
    GROUP BY CustomerID
)
SELECT
    CASE 
        WHEN o.OrderDate = f.FirstPurchaseDate THEN 'New Customer'
        ELSE 'Returning Customer'
    END AS CustomerType,
    COUNT(DISTINCT o.CustomerID) AS CustomerCount,
    SUM(od.TotalSales) AS Revenue
FROM global_orders o
JOIN global_order_details od ON o.OrderID = od.OrderID
JOIN FirstOrder f ON f.CustomerID = o.CustomerID
GROUP BY CASE 
        WHEN o.OrderDate = f.FirstPurchaseDate THEN 'New Customer'
        ELSE 'Returning Customer'
    END;

	--Contribution of Top 20% Customers to Revenue (Pareto)
	WITH RevenueByCustomer AS (
    SELECT 
        c.CustomerID,
        SUM(od.TotalSales) AS Revenue
    FROM global_order_details od
    JOIN global_orders o ON od.OrderID = o.OrderID
    JOIN global_customers c ON o.CustomerID = c.CustomerID
    GROUP BY c.CustomerID
),
Ranked AS (
    SELECT
        CustomerID,
        Revenue,
        NTILE(5) OVER (ORDER BY Revenue DESC) AS Bucket
    FROM RevenueByCustomer
)
SELECT
    Bucket,
    SUM(Revenue) AS Revenue
FROM Ranked
GROUP BY Bucket
ORDER BY Bucket;

