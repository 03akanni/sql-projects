Create Database SalesAP;
Use SalesAP
Create Table Sales (
SalesID Int Primary key identity(1 , 1) ,
CustomerName Varchar(100), 
Department Varchar(50),
SalesDate Date,
Amount Decimal(10 , 2)
)
INSERT INTO Sales (CustomerName, Department, SalesDate, Amount)
VALUES
('John Doe', 'Electronics', '2025-01-15', 250.00),
('Jane Smith', 'Clothing', '2025-02-10', 120.00),
('Michael Brown', 'Groceries', '2025-02-12', 75.50),
('Emily Davis', 'Electronics', '2025-03-01', 560.00),
('Chris Johnson', 'Clothing', '2025-03-15', 300.00),
('Sarah Wilson', 'Groceries', '2025-03-20', 95.75),
('Daniel Lee', 'Electronics', '2025-04-05', 700.00),
('Sophia Martin', 'Clothing', '2025-04-12', 150.00),
('David Clark', 'Groceries', '2025-04-20', 200.00),
('Emma Lopez', 'Electronics', '2025-05-01', 450.00);
select *
from Sales

--select specific coloumn
Select CustomerName, Department, Amount
from Sales

--Filtering with WHERE
Select *
from Sales
where Amount > 200;

--filtering with Where
select *
from Sales
where Department = 'Electronics' ;

--Sorting with Order By
select *
from Sales
order by Amount desc;

--Aggregations
Select SUM(Amount) AS TotalSales
from Sales
Select AVg(Amount) AS AvgSale
from Sales
Select Max(Amount) AS MaxSale, MIN(Amount) AS MInSale
from Sales

--Grouping
Select department, Sum(Amount) AS Totalsales
from Sales
Group By Department
Select department, avg(Amount) AS Avgsales
from Sales
Group By Department

--Top customers by Sale
Select Top 5 CustomerName, Sum(Amount) AS Totalsales
from Sales
Group by CustomerName
Order by Totalsales desc;
--Result;
--Daniel Lee	700.00
--Emily Davis	560.00
--Emma Lopez	450.00
--Chris Johnson	300.00
--John Doe	250.00

--Monthly Sales Trend
SELECT FORMAT(SalesDate, 'yyyy-MM') AS Month, SUM(Amount) AS MonthlySales
FROM Sales
GROUP BY FORMAT(SalesDate, 'yyyy-MM')
ORDER BY Month;
--Result;
--Peak Month; April(1050.00)
--Lowest Month; February(195.00)

--Deparments with sales above 1000
select Department, Sum(Amount) AS TotalSales
from Sales
Group by Department
Having Sum(Amount) > 1000;
--Result;
--Electronics

--Best-Selling Department per Customer
Select CustomerName, Department, Sum(Amount) AS DeptSales
from Sales
Group by CustomerName, Department
Order by CustomerName, DeptSales desc;
--Result;
--Daniel Lee	Electronics	700.00



