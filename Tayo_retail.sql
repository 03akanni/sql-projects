EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
EXEC sp_MSforeachtable 'DROP TABLE ?';

USE Sales_Analytics_DB;
GO

-- Step 1: Drop all foreign key constraints
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) 
    + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) 
    + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.foreign_keys;

EXEC sp_executesql @sql;

-- Step 2: Drop all tables
EXEC sp_MSforeachtable 'DROP TABLE ?';
GO

Select * From sys.tables;

Select * From Customers;
Select * From Products;
Select * From Orders;
Select * From Order_Details;


-- Link Orders → Customers
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customers
FOREIGN KEY (CustomerID)
REFERENCES Customers(CustomerID);

-- Link Orders → Products

--  Link OrderDetails → Orders
ALTER TABLE Order_Details
ADD CONSTRAINT FK_OrderDetails_Orders
FOREIGN KEY (OrderID)
REFERENCES Orders(OrderID);

-- Link OrderDetails → Products
ALTER TABLE Order_Details
ADD CONSTRAINT FK_OrderDetails_Products
FOREIGN KEY (ProductID)
REFERENCES Products(ProductID);

--Total Sales, Profit, and Average Discount
Select
sum(TotalSales) as Total_Sales,
sum(Profit) as Total_Profit,
avg(Discount) as Average_Discount
From [dbo].[order_details]

--Top 10 Product by Revenue
SELECT 
    p.ProductName,
    SUM(od.TotalSales) AS Total_Sales
FROM Order_Details od
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY Total_Sales DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--Sales & Profit by Region
SELECT 
  c.Region,
  SUM(od.TotalSales) AS Total_Sales,
  SUM(od.Profit)     AS Total_Profit
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Region
ORDER BY SUM(od.TotalSales) DESC;

--Top 10 Customers by Total Purchases
SELECT
  c.FullName,
  c.Country,
  SUM(od.TotalSales) AS Total_Sales,
  SUM(od.Profit)     AS Total_Profit,
  COUNT(DISTINCT o.OrderID) AS Orders_Count
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY c.FullName, c.Country
ORDER BY SUM(od.TotalSales) DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--Profit Margin by Product Category
SELECT
  c.FullName,
  c.Country,
  SUM(od.TotalSales) AS Total_Sales,
  SUM(od.Profit)     AS Total_Profit,
  COUNT(DISTINCT o.OrderID) AS Orders_Count
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY c.FullName, c.Country
ORDER BY SUM(od.TotalSales) DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--Monthly Sales Trend
SELECT 
    YEAR(o.OrderDate) AS Order_Year,
    MONTH(o.OrderDate) AS Order_Month,
    SUM(od.TotalSales) AS Monthly_Sales,
    SUM(od.Profit) AS Monthly_Profit
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
ORDER BY Order_Year, Order_Month;

--Top Countries by Profit
SELECT 
    c.Country,
    SUM(od.TotalSales) AS Total_Sales,
    SUM(od.Profit) AS Total_Profit
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY c.Country
ORDER BY SUM(od.Profit) DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

--High-Value Customers(VIPs)
SELECT 
    c.FullName,
    SUM(od.TotalSales) AS Total_Sales,
    SUM(od.Profit) AS Total_Profit,
    COUNT(o.OrderID) AS Total_Orders
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY c.FullName
HAVING SUM(od.TotalSales) > 5000  
ORDER BY SUM(od.TotalSales) DESC;

--Discount Impact on Profit
SELECT 
    CASE 
        WHEN od.Discount BETWEEN 0 AND 0.05 THEN '0-5%'
        WHEN od.Discount BETWEEN 0.051 AND 0.10 THEN '6-10%'
        WHEN od.Discount BETWEEN 0.101 AND 0.20 THEN '11-20%'
        ELSE 'Above 20%'
    END AS Discount_Range,
    ROUND(SUM(od.Profit) / NULLIF(SUM(od.TotalSales), 0) * 100, 2) AS Profit_Margin
FROM Order_Details od
GROUP BY 
    CASE 
        WHEN od.Discount BETWEEN 0 AND 0.05 THEN '0-5%'
        WHEN od.Discount BETWEEN 0.051 AND 0.10 THEN '6-10%'
        WHEN od.Discount BETWEEN 0.101 AND 0.20 THEN '11-20%'
        ELSE 'Above 20%'
    END
ORDER BY Profit_Margin DESC;

--Customer Sales Insights
SELECT TOP 10
    C.FullName       AS [Customer],
    C.Country,
    COUNT(O.OrderID)     AS [Total Orders],
    SUM(OD.TotalSales)   AS [Total Spent ($)],
    SUM(OD.Profit)       AS [Total Profit ($)]
FROM Customers C
JOIN Orders O       ON C.CustomerID = O.CustomerID
JOIN Order_Details OD ON O.OrderID  = OD.OrderID
GROUP BY C.FullName, C.Country
ORDER BY [Total Spent ($)] DESC;





