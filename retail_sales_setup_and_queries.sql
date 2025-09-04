Create Database SalesAnalytics;

--Customers
Create Table Customers ( CustomerID Int Primary Key,
CustomerName varchar(100) NOT NULL,
Region varchar(30) NOT NULL);

--Products
Create Table Products ( productID Int Primary Key,
ProductName varchar(100) NOT NULL,
Department varchar(50) NOT NULL);

--Sales
Create Table Sales ( SaleID Int Primary Key,
CustomerID Int NOT NULL,
ProductID Int NOT NULL,
OrderDate Date NOT NULL,
Quantity Int NOT NULL,
SalesTarget Decimal(12,2) NOT NULL,
ActualSales Decimal(12,2) NOT NULL,
Constraint fk_sales_customer Foreign Key (CustomerID) References Customers(CustomerID),
Constraint fk_sales_product Foreign key (ProductID) References Products(ProductID) );

--Customers (spread across regions)
Insert into Customers (CustomerID, CustomerName, Region) Values
(1, 'Alice Retail', 'East'),
(2, 'Beta Traders', 'West'),
(3, 'Crest Corp', 'North'),
(4, 'Delta Ltd', 'South'),
(5, 'Echo Stores', 'East');

-- Products (across departments)
INSERT INTO Products (ProductID, ProductName, Department) VALUES
(101, 'Laptop',  'Electronics'),
(102, 'Monitor', 'Electronics'),
(103, 'Chair',   'Furniture'),
(104, 'Desk',    'Furniture'),
(105, 'Paper',   'Office Supplies'),
(106, 'Pen',     'Office Supplies');

-- Sales (Jan–Jun 2024)
INSERT INTO Sales (SaleID, CustomerID, ProductID, OrderDate, Quantity, SalesTarget, ActualSales) VALUES
(1001, 1, 101, '2024-01-15', 1, 1200, 1150),
(1002, 1, 105, '2024-01-20', 10, 300, 320),
(1003, 2, 103, '2024-02-05', 4, 500, 450),
(1004, 3, 102, '2024-02-18', 2, 800, 900),
(1005, 4, 104, '2024-03-04', 3, 700, 650),
(1006, 5, 106, '2024-03-21', 24, 200, 240),
(1007, 2, 101, '2024-04-10', 1, 1200, 1400),
(1008, 3, 105, '2024-04-15', 15, 300, 310),
(1009, 4, 103, '2024-05-09', 5, 500, 520),
(1010, 5, 102, '2024-05-22', 2, 800, 750),
(1011, 1, 104, '2024-06-02', 2, 700, 730),
(1012, 2, 106, '2024-06-18', 30, 200, 180),
(1013, 3, 101, '2024-06-25', 1, 1200, 1250),
(1014, 4, 105, '2024-04-30', 20, 300, 290),
(1015, 5, 103, '2024-02-27', 3, 500, 480),
(1016, 1, 102, '2024-03-28', 1, 800, 820);

Select* From Customers;
Select* from Products
Select* from Sales Order by OrderDate;

--Join Query(Details per Sale)
Select
s.SaleID,
s.OrderDate,
c.CustomerName,
c.Region,
p.ProductName,
p.Department,
s.Quantity,
s.SalesTarget,
s.ActualSales,
(Case when s.SalesTarget = 0 Then 0 Else (s.ActualSales / s.SalesTarget) End) As AchievementRatio
From Sales s
Join Customers c On s.CustomerID = c.CustomerID
Join Products p On s.ProductID = p.productID
Order by s.OrderDate, s.SaleID;

--Aggregations(Total Actual sales by Region)
Select
c.Region,
Sum(s.ActualSales) As  TotalactualSales
from Sales s
Join Customers c On s.CustomerID = c.CustomerID
Group by c.Region
Order by TotalactualSales Desc;

--Department Performance(Actual vs Target + %Achievement)
Select
Sum(s.SalesTarget) As TargetSum,
Sum(s.ActualSales) As ActualSum,
Case When Sum(s.SalesTarget) = 0 Then 0
Else Sum(s.ActualSales) / Sum(s.SalesTarget)
End As AchievementPct
From Sales s
Join Products p On s.ProductID = p.productID
Group By p.Department
Order by ActualSum Desc;

--Top 5 Products by Total Actual Sales
Select Top 5
p.ProductName,
Sum(s.Actualsales) As TotalActualSales
from Sales s
Join Products p on s.ProductID = p.productID
Group by p.ProductName
Order by TotalActualSales Desc;

--Monthly Trend(Actual vs Target)
Select 
Cast(Year(s.OrderDate) As varchar(4)) + '_' + Right('0' + Cast(Month(s.OrderDate) As varchar(2)), 2) As YearMonth,
Sum(s.SalesTarget) AS TargetSum,
Sum(s.ActualSales) As ActualSum
From Sales s
Group by Year(s.OrderDate), Month(s.OrderDate)
Order by Year(s.OrderDate), Month(s.OrderDate);




