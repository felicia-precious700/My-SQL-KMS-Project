Create Database [Kultra_Mega_Stores_Inventory_DB]

----Import Table----
----CSV 1. [dbo].[KMS Sql Case Study]
----CSV 2. [dbo].[Order_Status]


-----Table----

Select * From [dbo].[KMS Sql Case Study]

Select * From [dbo].[Order_Status]


CREATE VIEW vw_dbokmsdboord
AS
SELECT
    kms.[Row_ID],
    kms.[Order_ID],
    kms.[Order_Date],
    kms.[Order_Priority],
    kms.[Order_Quantity],
    kms.[Sales],
    kms.[Discount],
    kms.[Ship_Mode],
    kms.[Shipping_Cost],
    kms.[Customer_Name],
    kms.[Province],
    kms.[Region],
    kms.[Customer_Segment],
    kms.[Product_Category],
    kms.[Product_Sub_Category],
    kms.[Product_Name],
    kms.[Product_Container],
    kms.[Product_Base_Margin],
    kms.[Ship_Date],
    ord.[status]
From [dbo].[KMS Sql Case Study] kms
inner join [dbo].[Order_Status] ord
on kms.Order_ID = ord.Order_ID

----Select View----

Select * From [dbo].[vw_dbokmsdboord]

----Update  View----

UPDATE [dbo].[vw_dbokmsdboord]
SET [Product_Base_Margin] = COALESCE([Product_Base_Margin], 0.00)
WHERE [Product_Base_Margin] IS NULL

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----Question 1: Which product category had the highest sales?

Select Top 1
      Product_Category,
	  Sum(Sales) As Total_Sales
From [dbo].[vw_dbokmsdboord]
Group by Product_Category
Order by Total_Sales Desc

----Answer: Product Category = (Technology) --- Sales = $605,426.04


----Question 2: What are the top 3 and bottom 3 regions in terms of sales----

Select top 3
    Region,
	Sum(Sales) As Total_Sales
From [dbo].[vw_dbokmsdboord]
Group by Region
Order by Total_Sales DESC

----Answer: Top 3 Regions: Ontario= $471,161.63, West= $375,122.37, Praire= $296,732.24.

---Bottom 3

Select Top 3
      Region,
	  Sum(Sales) As Total_Sales
From [dbo].[vw_dbokmsdboord]
Group by  Region
Order by Total_Sales Asc

----Answer: Bottom 3 Regions: Nunavit = $228.41, Yukon = $99201.53, Quebec = $103447.03

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----Question 3: What are the total sales of appliances in Ontario?

SELECT Product_Sub_Category, Region,
    SUM(Sales) AS Total_Sales
FROM [dbo].[vw_dbokmsdboord]
WHERE Region = 'Ontario'
  And Product_Sub_Category = 'appliances'
Group By Product_Sub_Category, Region

----Answer: Total sales of appliances in Ontario = $17,648.37

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----select view----
Select * from [dbo].[vw_dbokmsdboord]

----Question 4: Advise the management of KMS on what to do to increase the revenue from the bottom 10 customers


SELECT Top 10
      Customer_Name,
	  Sum(Sales) As Total_Revenue
From [dbo].[vw_dbokmsdboord]
Group by Customer_Name
Order by Total_Revenue Asc


----My advice to the management of KMS on what to do to increase the revenue:

 -------a- Extract the 10 lowest-performing customers by total sales.
--------b- Analyze customer purchase patterns and feedback.
--------c- Offer targeted promotions or loyalty incentives.
--------d- Assign dedicated account managers or support for better engagement.
--------e- Upsell or cross-sell complementary products.
--------f- Enhance delivery efficiency and customer service quality.

-------Bottom 10 Customers------

--Customer Name              Total Sales
--John Grady          =   $5.06 
--Frank Atkinson      =   $10.48
--Sean Wendt          =   $12.80
--Sandra Glassco      =   $16.24
--Katherine Hughes    =   $17.77
--Bobby Elias         =   $22.56
--Noel Staavos        =   $24.91
--Thomas Boland       =   $28.01
--Brad Eason          =   $35.17
--Theresa Swint       =   $38.51


select * from [dbo].[vw_dbokmsdboord]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----Question 5: KMS incurred the most shipping cost using which shipping method?

SELECT Top 1
     Order_Priority, Ship_Mode,
	  SUM(Shipping_Cost) AS Total_Cost
From [dbo].[vw_dbokmsdboord]
Group by Order_Priority, Ship_Mode
Order by Total_Cost DESC


----Answer : Shipping Method: Delivery Truck = $1,659.14

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----Question 6: Who are the most valuable customers, and what products or services do they typically purchase?

 
    SELECT
        Customer_Name,
        Customer_Segment,
        SUM(Sales) AS Total_Revenue
    FROM [dbo].[vw_dbokmsdboord]
    GROUP BY Customer_Name, Customer_Segment
),
CustomerProductRevenue AS (
    SELECT 
        Customer_Name,
        Product_Name,
		Order_Quantity,
        SUM(Sales) AS Product_Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY Customer_Name 
            ORDER BY SUM(Sales) DESC, Product_Name DESC
        ) AS Product_Rank
    FROM [dbo].[vw_dbokmsdboord]
    GROUP BY Customer_Name, Product_Name, Order_Quantity
)
SELECT TOP 5
    cr.Customer_Name,
    cr.Customer_Segment,
    cpr.Product_Name AS Top_Product,
	cpr.Order_Quantity,
    cr.Total_Revenue
FROM CustomerRevenue cr
JOIN CustomerProductRevenue cpr 
    ON cr.Customer_Name = cpr.Customer_Name 
    AND cpr.Product_Rank = 1
ORDER BY cr.Total_Revenue DESC

----Answer: We have identified our most valuable customers, along with the products they purchased are as follosw:

------Customer_Name       Customer_Segment    Top_Product                                                                        Total_Revenue                         

---1--John Lucas          Small Business       Chromcraft Bull-Nose Wood 48" x 96" Rectangular Conference Tables                  37,919.43
---2--Lycoris Saunders    Corporate            Bretford CR8500 Series Meeting Room Furniture                                      30.948.18
---3--Grant Carroll       Small Business       Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind        26,485.12
---4--Erin Creighton      Corporate            Polycom VoiceStation 100                                                           26,443.02
---5--Peter Fuller        Corporate            Panasonic KX-P3626 Dot Matrix Printer                                              26,382.21

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---Question 7: Which (Small business customer) had the highest sales?

WITH CustomerRevenue AS (
    SELECT 
        Customer_Name,
        Customer_Segment,
        SUM(Sales) AS Total_Revenue
    FROM [dbo].[vw_dbokmsdboord]
	Where Customer_Segment = 'Small Business'
    GROUP BY Customer_Name, Customer_Segment
),
CustomerProductRevenue AS (
    SELECT 
        Customer_Name,
        Product_Name,
		Order_Quantity,
        SUM(Sales) AS Product_Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY Customer_Name 
            ORDER BY SUM(Sales) DESC, Product_Name DESC
        ) AS Product_Rank
    FROM [dbo].[vw_dbokmsdboord]
    GROUP BY Customer_Name, Product_Name, Order_Quantity
)
SELECT TOP 1
    cr.Customer_Name,
    cr.Customer_Segment,
    cpr.Product_Name AS Top_Product,
	cpr.Order_Quantity,
    cr.Total_Revenue
FROM CustomerRevenue cr
JOIN CustomerProductRevenue cpr 
    ON cr.Customer_Name = cpr.Customer_Name 
    AND cpr.Product_Rank = 1
ORDER BY cr.Total_Revenue DESC

---Answer: The small business customer with the highest sales = (John Lucas) with Total_Revenue = $37,919.43

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



------Question 8: Which corporate customer placed the most number of orders in 2009 - 2012?


SELECT TOP 1
   Customer_Segment, Customer_Name,
    SUM(Order_Quantity) AS Total_Orders
FROM [dbo].[vw_dbokmsdboord]
WHERE Customer_Segment = 'Corporate'
    AND Ship_Date BETWEEN '2009-01-01' AND '2012-12-31'
GROUP BY Customer_Segment, Customer_Name
ORDER BY Total_Orders DESC


----Answer: The corporate customer with the most placed order in 2009 - 2012 = Name: Erin Creighton with Total Orders = 261

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-----Question 9: Which consumer customer was the most profitable one?

SELECT TOP 1
    Customer_Segment, Customer_Name,
    SUM(Sales) AS Total_Revenue
FROM [dbo].[vw_dbokmsdboord]
WHERE Customer_Segment = 'Consumer'
GROUP BY Customer_Segment, Customer_Name
ORDER BY Total_Revenue Desc

---Answer: The consumer customer with the most profitabe one: Darren Budd with total revenue = $23,034.35 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


------Question 10: Which customer returned items, and what segment do they belong to?


SELECT TOP 872
   Customer_Name, Customer_Segment,
    max([Status]) AS Total_Returned_Items
FROM [dbo].[vw_dbokmsdboord]
GROUP BY Customer_Segment, Customer_Name, [Status]
ORDER BY Total_Returned_Items Desc

----ANSWERS: All customers returned items according to their data provided.


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----Question 11: If the delivery truck is the most economical but the slowest shipping method and 
---Express Air is the fastest but the most expensive one, do you think the company 
---appropriately spent shipping costs based on the Order Priority? (Explain your answer)

SELECT  
    Order_Priority,  
    Ship_Mode,  
    SUM(Shipping_Cost) AS Total_Cost  
FROM  [dbo].[vw_dbokmsdboord]
WHERE Ship_Mode IN ('Express Air', 'Delivery Truck')  
GROUP BY Order_Priority, Ship_Mode  
ORDER BY Ship_Mode, Total_Cost DESC

----Answer: Based on Order Priority				Ship Mode					Total Cost

-----		Low									Delivery Truck				$1,659.14
-----		High								Delivery Truck				$1,274.98
-----		Not	Specified						Delivery Truck				$1,040.76
-----		Medium								Delivery Truck				$925.25
-----		Critical							Delivery Truck				$829.01
-----		Low									Express Air					$289.95
-----		Not	Specified						Express Air					$257.40
-----		Critical							Express Air					$195.19
-----		Medium								Express Air					$167.27
-----		High								Express Air					$108.92

------Was shipping cost appropriately spent based on Order Priority?
----a Appropriate spending depends on matching high-priority orders with fast (Express Air) shipping and low-priority orders with economical (Delivery Truck) methods.
----b If there are mismatches (e.g., urgent items shipped via Delivery Truck), the spending is inappropriate.
----c A proper audit of the data would confirm alignment.
