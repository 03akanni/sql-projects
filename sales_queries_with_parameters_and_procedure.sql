--Customers Table
Create Table Customers (
CustomerID Int Primary Key,
CustomerName Varchar(100),
Region Varchar(50)
);

--Products Table
Create Table Products (
ProductID Int Primary Key,
ProductName Varchar(100),
Category Varchar(50)
);

--Sales Table
Create Table Sales (
SaleID Int Primary Key,
CustomerID Int,
ProductID Int,
SaleDate Date,
Quantity Int,
Amount Decimal(10,2),
Foreign Key (CustomerID) References Customers(CustomerID),
Foreign Key (ProductID) References Products(ProductID)
);

-- Insert Customers
INSERT INTO Customers (CustomerID, CustomerName, Region)
VALUES
(1, 'John Smith', 'North'),
(2, 'Mary Johnson', 'South'),
(3, 'David Brown', 'East'),
(4, 'Linda White', 'West'),
(5, 'James Green', 'North');

-- Insert Products
INSERT INTO Products (ProductID, ProductName, Category)
VALUES
(101, 'Laptop', 'Electronics'),
(102, 'Smartphone', 'Electronics'),
(103, 'Desk Chair', 'Furniture'),
(104, 'Notebook', 'Stationery'),
(105, 'Pen', 'Stationery');

-- Insert Sales
INSERT INTO Sales (SaleID, CustomerID, ProductID, SaleDate, Quantity, Amount)
VALUES
(1001, 1, 101, '2023-01-15', 2, 2000.00),
(1002, 2, 102, '2023-02-10', 1, 800.00),
(1003, 3, 103, '2023-03-05', 5, 750.00),
(1004, 1, 104, '2023-03-20', 10, 50.00),
(1005, 4, 105, '2023-04-02', 20, 40.00),
(1006, 5, 101, '2023-04-15', 1, 1000.00),
(1007, 2, 103, '2023-05-01', 3, 450.00),
(1008, 3, 102, '2023-05-12', 2, 1600.00),
(1009, 4, 104, '2023-06-03', 15, 75.00),
(1010, 5, 105, '2023-06-20', 30, 60.00);

Select * from Customers
Select * from Products
Select * from Sales

--Join Tables
Select
s.SaleID,
c.CustomerName,
p.ProductName,
p.Category,
s.Quantity,
s.SaleDate,
s.Amount
From Sales s
Join Customers c On s.CustomerID = c.CustomerID
Join Products p On s.ProductID = p.ProductID;

--Aggregations (Total revenue by product)
Select
p.Category,
Sum(s.Amount) As TotalRevenue,
Count(s.SaleID) As TotalOrders
From Sales s
Join Products p On s.ProductID = p.ProductID
Group By p.Category;

--Filtering & Insights(Top 3 Customers by total spend)
Select Top 3
c.CustomerName,
Sum(s.Amount) As TotalSpent
From Sales s
Join Customers c On s.CustomerID = c.CustomerID
Group by c.CustomerName
Order By TotalSpent Desc;

--Monthly Sales Trend
Select 
Format(s. SaleDate, 'yyyy-MM') As SaleMonth,
Sum(s.Amount) As MonthlyRevenue
From Sales s
Group By Format(s.SaleDate, 'yyyy-MM')
Order By SaleMonth;

--Yearly Sales Trend
Select 
Year(s.SaleDate) As SaleYear,
Sum(s.Amount) As YearlyRevenue
From Sales s
Group by Year(s.SaleDate)
Order by SaleYear;

--Revenue by Region Over Time
--Monthly Revenue by Region
SELECT 
  CAST(YEAR(s.SaleDate) AS VARCHAR(4))
    + '-' + RIGHT('0' + CAST(MONTH(s.SaleDate) AS VARCHAR(2)), 2) AS YearMonth,
  c.Region,
  SUM(s.Amount) AS MonthlyRevenue
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY YEAR(s.SaleDate), MONTH(s.SaleDate), c.Region
ORDER BY YEAR(s.SaleDate), MONTH(s.SaleDate), c.Region;

--Create Views
Create View vw_MonthlyRevenueByRegion As
Select
cast(Year(s.SaleDate) As varchar(4))
+ '-' + Right('0' + Cast(Month(s.SaleDate) As Varchar(2)), 2) As YearMonth,
c.Region,
Sum(s.Amount) As MonthlyRevenue
From Sales s
Join Customers c On s.CustomerID = c.CustomerID
Group by Year(s.SaleDate), Month(s.SaleDate), c.Region;


--Detailed Dataset(Joins)
CREATE VIEW vw_SalesDetails AS
SELECT 
    s.SaleID,
    s.SaleDate,
    c.CustomerName,
    c.Region,
    p.ProductName,
    p.Category AS ProductCategory,
    s.Quantity,
    s.Amount
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Products p ON s.ProductID = p.ProductID;

--Revenue by Region
CREATE VIEW vw_RevenueByRegion AS
SELECT 
    c.Region,
    SUM(s.Amount) AS TotalRevenue
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY c.Region;

--Revenue by Region Over Time
--Monthly Revenue by Region
SELECT 
  CAST(YEAR(s.SaleDate) AS VARCHAR(4))
    + '-' + RIGHT('0' + CAST(MONTH(s.SaleDate) AS VARCHAR(2)), 2) AS YearMonth,
  c.Region,
  SUM(s.Amount) AS MonthlyRevenue
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY YEAR(s.SaleDate), MONTH(s.SaleDate), c.Region
ORDER BY YEAR(s.SaleDate), MONTH(s.SaleDate), c.Region;

Select * From vw_SalesDetails;
Select * from vw_RevenueByRegion;
Select * from vw_MonthlyRevenueByRegion;

--Indexing
Create Index idx_sales_customerID On Sales(CustomerID);
Create Index idx_sales_productID On Sales(ProductID);
Create Index idx_sales_Saledate On Sales(SaleDate);

--Parameterized Query
DECLARE @CustomerID NVARCHAR(50);
SET @CustomerID = 2;

SELECT 
    s.SaleID,
    c.CustomerName,
    p.ProductName,
    s.SaleDate,
    s.Amount
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Products p ON s.ProductID = p.ProductID
WHERE s.CustomerID = @CustomerID;

--Add a Date Filter Parameter
DECLARE @StartDate DATE, @EndDate DATE;
SET @StartDate = '2023-04-01';
SET @EndDate   = '2023-04-30';

SELECT 
    s.SaleID,
    c.CustomerName,
    p.ProductName,
    s.SaleDate,
    s.Amount
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Products p ON s.ProductID = p.ProductID
WHERE s.SaleDate BETWEEN @StartDate AND @EndDate;

--Combine Parameters (Customer + Date Range)
DECLARE @CustomerID INT = 1;  
DECLARE @StartDate DATE = '2023-01-01';  
DECLARE @EndDate DATE = '2023-12-31';  

SELECT 
    s.SaleID, 
    c.CustomerName, 
    p.ProductName, 
    s.Quantity, 
    s.SaleDate, 
    s.Amount
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Products p ON s.ProductID = p.ProductID
WHERE s.CustomerID = @CustomerID
  AND s.SaleDate BETWEEN @StartDate AND @EndDate;


  --Stored Procedure Version
CREATE PROCEDURE GetSalesByCustomerAndDate
    @CustomerID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT 
        s.SaleID, 
        c.CustomerName, 
        p.ProductName, 
        s.Quantity, 
        s.SaleDate, 
        s.Amount
    FROM Sales s
    JOIN Customers c ON s.CustomerID = c.CustomerID
    JOIN Products p ON s.ProductID = p.ProductID
    WHERE s.CustomerID = @CustomerID
      AND s.SaleDate BETWEEN @StartDate AND @EndDate;
END;

Exec GetSalesByCustomerAndDate @CustomerID = 1,
@StartDate = '2022-01-01',
@EndDate = '2023-12-31';













