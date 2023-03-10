/**********************************************************************
 *                   SQL  --> UPDATE, DELETE, INSERT           *
 *                   modifying data                                              *
 **********************************************************************/

/**********************************************************************
 * 新增資料 -->  INSER INTO                                           *  
 **********************************************************************/
-- INSERT INTO 標準用法與技巧

-- 預備動作: recreate table employee
create database mis;
USE mis;

IF EXISTS (SELECT * FROM sys.tables WHERE name='employee')
DROP TABLE employee   

create table employee
(
  emp_no	char(8) primary key,
  emp_name      char(12),
  dep                  char(6),
  address	char(30),
  sex                   char(1),
  salary               numeric(10,2),
  hired_date       char(10),
  is_foreign        char(1) default 'N'
);
go

sp_help employee
select * from  employee;
----------------------------------------------------------------------
/*  insert into method 1:完整指定資料行 */
use mis;
go

  -- 檢視欄位:
select * from employee;

  -- 新增資料(完整欄位)
insert into employee
values('E0010003','jack','D11000','kao','M',20000,'2000/10/10',default);

select * from employee;
                --錯誤 欄位不符
--------------------------------------------------------------------------------------
   -- 修改 (default 討論)
insert into employee
values('E0010003','jack','D11000','kao','M',20000,'2000/10/10',default)
 
   -- (null 討論)
insert into employee
values('E0010006','white','D11000','kao','F',null,'2000/10/11',default);

select * from employee;

-- 練習: ('E0010008','black','D11001','tpi','M',40000,'2000/12/25','Y' )
insert into employee
values('E0010008','black','D11001','tpi','M',40000,'2000/12/25','Y' );

select * from employee;
----------------------------------------------------------------------------------------
/* insert into method 2: 指定部分資料行 */
--example 1:
insert into employee (emp_no, emp_name, salary) --指定欄位
values ('E0010004','mary',40000);
          -- 有default 設 default 
          -- 沒 default 設 null
          -- not null field 則此 insert 指令失敗

select * from employee;
--example 2: (not null field)
   -- 修改 emp_name 為 not null
   alter table employee
   alter column  emp_name char(12) not null;

alter table employee
alter column emp_name char(12) not null;          

insert into employee (emp_no,emp_name,salary)
values ('E1093001','mary hang',43000);

   --訊息 515，層級 16，狀態 2，行 1
   --無法插入 NULL 值到資料行 'emp_name'，資料表 'mis.dbo.employee'; 資料行不得有 Null。INSERT 失敗。

insert into employee (emp_no,emp_name,salary)
values ('E1093001','mary hang',43000);


-- 練習:(emp_no=E002001, emp_name=smith, salary=34000, dep=D11001)
use mis;
insert into employee(emp_no,emp_name,salary,dep)
values ('E002001','smith','34000','D11001');
select * from employee;
--------------------------------------------------------------------------------
/*  insert into with select clause 
     using the INSERT...SELECT statement */
-- example 1:
-- 預備動作: recreate table emp_tmp1
USE mis
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name='emp_tmp1')
DROP TABLE emp_tmp1;   

create table emp_tmp1
(
  emp_no	char(8) primary key,
  emp_name      char(12),
  dep                  char(6),
  address	char(30),
  sex                   char(1),
  salary               numeric(10,2),
  hired_date       char(10),
  is_foreign        char(1) default 'N'
)

select*
into new_t
from employee;

select*from new_t;

select*
into emp_tmp2
from employee
where emp_no is null;

  -- 另一種方法 copy table employee (emp_tmp2)
select *
into emp_tmp2
from employee
where emp_no is null;

select * from emp_tmp1;
select * from emp_tmp2;



select * into emp_tmp2 from employee
where emp_no is null
---------------------------------------------------------------------------------
  
  -- insert into with select clause (part I)
insert into emp_tmp1
select *               -- VALUES 子句以 SELECT 子句取代
from employee
where sex='M';

select*from emp_tmp1
---------------------------------------------------------------------------------

  -- insert into with select clause (part II)
insert into emp_tmp1(emp_no,emp_name)
select emp_no,emp_name
from employee
where sex='F';

-------------------------------------------------------------------
/* insert into 使用系統函數及select 填值 */
-- example : 訂單統計
use Northwind
go  

drop table 訂單統計;
  -- step 1. create 訂單統計 table
  create table 訂單統計
  (年度 int,
   客戶代號 nchar(5),
   公司名稱 nvarchar(40),  --客戶公司名稱
   訂單數 int,
   統計日期 date)
  


  -- step 2. insert data
  insert into 訂單統計
  select YEAR(OrderDate),CustomerID,'尚未求出',COUNT(*),GETDATE()
  from Orders                        --fill data        --system function
  group by year(OrderDate),CustomerID
  
  delete from 訂單統計;
  -- step 3. 檢視 訂單統計
  select * from 訂單統計

  go
  use northwind;
  select * from 訂單統計;
delete from 訂單統計


------------------------------------------------------------------------
-- 練習1:完成上例中 '尚未求出' 之companyname   

年度        客戶代號  公司名稱                                 訂單數       統計日期
----------- -----     ---------------------------------------- ----------- ----------
1997        ALFKI     Alfreds FutterkisteAAAA                  3           2010-09-30
1998        ALFKI     Alfreds FutterkisteAAAA                  3           2010-09-30
1997        ANATR     Ana Trujillo Emparedados y helados       2           2010-09-30
1998        ANATR     Ana Trujillo Emparedados y helados       1           2010-09-30
1997        ANTON     Antonio Moreno Taquería                  5           2010-09-30
......

-- 解答:  
  use Northwind
  go

   insert into 訂單統計
 select  YEAR(OrderDate),c.CustomerID,c.CompanyName,count(*),GETDATE()
 from Orders as o inner join Customers as c on (o.CustomerID=c.CustomerID)
   group by YEAR(OrderDate),c.CustomerID,CompanyName;

   select * from 訂單統計;

-- 練習 2:銷售排行榜:分別將1997、1998年接單前三名員工
          資料依序寫入資料表TopSales)(from northwind.orders, employees)
		 use Northwind
		 go
		 insert into TopSales

		  select top 3 e.FirstName+' '+e.LastName as '員工姓名',count(*) as '接單數'
		  from Orders as o inner join employees as e on (o.employeeID=e.employeeID)
		  where year(o.orderdate) in (1997)
		  group by year(o.orderdate),e.EmployeeID,e.LastName,e.FirstName
		  order by count(*) desc
		  union
		  select top 3 e.FirstName+' '+e.LastName as '員工姓名',count(*) as '接單數'
		  from Orders as o inner join employees as e on (o.employeeID=e.employeeID)
		  where year(o.orderdate) in (1998)
		  group by year(o.orderdate),e.EmployeeID,e.LastName,e.FirstName
		  order by count(*) desc;


-- step 1. create table TopSales
use mis
go

create table TopSales
( 年度 smallint,
  員工姓名 nvarchar(60),
  接單數   smallint)

年度     員工姓名                     接單數
------ ------------------------------ ----------
1997   Margaret Peacock                 81
1997   Janet Leverling                  71
1997   Nancy Davolio                    55
1998   Margaret Peacock                 44
1998   Nancy Davolio                    42
1998   Andrew Fuller                    39

(6 個資料列受到影響)

-- 解答: 
use mis
go
   -- 1997 top 3
insert into TopSales
select top 3 1997......

insert into TopSales
select top 3 1997,

    -- 1998 top3
insert into TopSales

-- 驗證: 
select * from TopSales
-- 本練習進階討論:可否一氣呵成 (union) 
=================================================================================
-- 進階討論:INSERT statement 會自動觸發交易(transaction)
   1. Autocommit transactions:(自動認可交易)
   2. 資料放置於 資料分頁(data page), 如果新增資料有對應得索引(index),會一併在
      索引分頁 (index page) 新增一筆紀錄
   3. SQL Server Profiler 追蹤 
      3.1. 開啟 SQL Server Profiler
      3.2. 執行追蹤
      3.3. 執行新增作業 
           USE mis
           GO
           
           INSERT INTO employee(emp_no,emp_name,salary)
           VALUES ('E099','Jolin',46000),
                  ('E098','Joe',50000),
                  ('E097','Moon',32000)
           
   4. 檢視追蹤檔案       
=================================================================================
/* insert into new method: T-SQL 資料列建構函數 (SQL Server 2008) */
use mis
go

insert into employee (emp_no,emp_name,salary)
values ('E0991','TOM',40000),
       ('E0992','BOB',43000),
       ('E0993','SCOTT',45000)
---------------------------------------------------------------------------------
/* insert into with stored procedure :exec (execte) */
  --step 1: 先 create 一個stored procedure
use mis
go 

create procedure sp_test1 as
select emp_no, emp_name
from employee
where dep='D11000'

  --step 2: insert into with stored peocedure
insert into emp_tmp2(emp_no,emp_name)
execute sp_test1 

         --驗證
select * from emp_tmp2
---------------------------------------------------------------------------------
/**********************************
 * INSERT 具IDENTITY屬性欄位 討論 *
 **********************************/
 -- 預設IDENTITY是無法手動給值
 -- 如果要手動給值 -->更改設定
    --example:
    USE mis
    GO
         -- create table test99
    CREATE TABLE TEST99
    (F1 INT IDENTITY(100,2),
     F2 CHAR(10))
         -- insert
    INSERT INTO TEST99(F1,F2)
    VALUES(120,'ASXZ')   --X
         
         --修改設定
    SET IDENTITY_INSERT TEST99 ON
    
         -- 再次insert
    INSERT INTO TEST99(F1,F2)
    VALUES(120,'ASXZ')    --ok (注意!!必須是欄外顯格式)
     
    INSERT INTO TEST99
    VALUES(121,'AxXZ')    --X
    
    --修改設定 OFF
    SET IDENTITY_INSERT TEST99 OFF
    
         -- 再次insert
    INSERT INTO TEST99(F1,F2)
    VALUES(123,'SSXZ')    --X  
---------------------------------------------------------------------------------
   -- IDENTITY屬性欄位 進階討論 @@IDENTITY
   INSERT INTO TEST99
   VALUES ('SSTZ')
   
   SELECT @@IDENTITY  --最近新增資料後所產生的序號
      
---------------------------------------------------------------------------------
/*******************************************************************
 * 填入資料表 --> SELECT INTO, bcp, BULK INSERT                    *
 *******************************************************************/

=================================================================================
/*********************************************************
 * 刪除資料 --> DELETE  and TRUNCATE      *
 *********************************************************/
/* DELETE : delete all data from table */
 -- syntax of DELETE statement
     [ WITH <common_table_expression> [ ,...n ] ]
    DELETE 
    [ TOP ( expression ) [ PERCENT ] ] 
    [ FROM ] 
    { <object> | rowset_function_limited 
      [ WITH ( <table_hint_limited> [ ...n ] ) ]
    }
    [ <OUTPUT Clause> ]
    [ FROM <table_source> [ ,...n ] ] 
    [ WHERE { <search_condition> 
            | { [ CURRENT OF 
                   { { [ GLOBAL ] cursor_name } 
                       | cursor_variable_name 
                   } 
                ]
              }
            } 
    ] 
    [ OPTION ( <Query Hint> [ ,...n ] ) ] 
    [; ]

    <object> ::=
    { 
       [ server_name.database_name.schema_name. 
         | database_name. [ schema_name ] . 
         | schema_name.
       ]
         table_or_view_name 
    }
-----------------------------------------------------------

 -- Each deleted row is logged in the transaction log.
 -- example:
use mis
delete from emp_tmp2  
---------------------------------------------------------------------------------
/* delete with where clause */
--example 1: (1997年以前訂單刪除)
use Northwind
go

  -- step 1. select ... into copy table orders to #orders_tmp
  drop table orders_tmp_1;

  select *
  into orders_tmp_1
  from Orders
  
  select*from orders_tmp_1;
  -- step 2. 1997年以前訂單刪除
  delete from orders_tmp_1
  where year(OrderDate) <= 1997
  
-- 練習1: 刪除前面10%的訂單 (#orders_tmp) (提示: top)
-- 驗證(前):

delete top(10)percent
from orders_tmp_1;

   select COUNT(*) from orders_tmp_1
      --270
-- 解答:
   delete ...... from #orders_tmp 

-- 驗證(後):
   select COUNT(*) from #orders_tmp
      --243
      
-- 練習2: 刪除澳洲(Austria)客戶的訂單
-- 解答:
go
use Northwind

   delete from orders_tmp_1
   where customerID in    (select CustomerID
                                                  from Customers
                                                  where country='Austria' )
   

-- 練習3: 刪除25%的加拿大(Canada)客戶訂單
-- 解答:
     delete top (25) percent from orders_tmp_1
   where customerID in    (select CustomerID
                                                  from Customers
                                                  where country='Canada' )
   
           
---------------------------------------------------------------------------------
/* delete with select clause */
--example: (刪除單價高於平均單價的產品)
use mis
select * into products_tmp
from northwind..products

delete from products_tmp
where unitprice> (select avg(unitprice) from products_tmp) 
-------------------------------------------------------------------------------------------
/* Deleting Rows Based on Other Tables */
/* @@ROWCOUNT 變數說明 */
--example: (刪除加拿大(Canada)客戶訂單
use Northwind
go
  --step 1. copy table orders into table orders_tmp2
select * into orders_tmp2
from Orders

  --step 2. (檢視)加拿大(Canada)客戶代號 (frome customers)
  Select customerid
  from Customers
  where Country = 'canada'
  
  --step 3. 從 northeind.orders_tmp2 中, 刪除加拿大(Canada)客戶訂單 
  delete from orders_tmp2
  where customerid in 
                      (Select customerid
                       from Customers
                       where Country = 'canada')  
  
  select @@ROWCOUNT '總刪除筆數' -- 使用@@ROWCOUNT 變數
  go


-- 練習:將1998/04/14 的訂單明細項刪除 
-- 解答:
use northwind
go
   --step 1. copy table 
   select * into [order details tmp2] from [Order Details]
  
   --step 2. delete 
   ...
------------------------------------------------------------------
/* 搭配 BEGIN TRANSACTION:交易初步說明*/
  --syntax:
  BEGIN TRANSACTION
  ...
  ROLLBACK TRANSACTION
  ...
  COMMIT TRANSACTION
  ...
  -- example 1: 刪除加拿大(USA)客戶訂單
  use Northwind
  go
  
    -- step 1: (檢視)
    select * from orders2
    where customerid in 
                       (Select customerid
                        from Customers
                        where Country = 'USA')
    
    select @@ROWCOUNT 'USA客戶訂單筆數' -- 使用@@ROWCOUNT 變數
    go
    
    -- step 2. BEGIN TRANSACTION (delete)
	select*
	into orders2
	from Orders;

    BEGIN TRANSACTION
      delete from orders2
      where customerid in 
                         (Select customerid
                          from Customers
                          where Country = 'USA') 
         
         -- (99 個資料列受到影響)
    -- step 3. 檢視 delete 後結果
       select * from orders2
       where customerid in 
                          (Select customerid
                           from Customers
                           where Country = 'USA') 
                           
         -- (0 個資料列受到影響) 
         -- 刪除動作有執行，但尚未確認(COMMIT)...
    -- step 4-1. ROLLBACK TRANSACTION (資料復原到初始狀態)
       
       ROLLBACK TRANSACTION
       
       -- 重新檢視: 
       select * from orders2
       where customerid in 
                          (Select customerid
                           from Customers
                           where Country = 'USA')
                           
            -- (99 個資料列受到影響)                
            -- 資料復原到初始狀態
     
     -- step 4-2. COMMIT TRANSACTION (資料確認被永久刪除)
        BEGIN TRANSACTION
          delete from orders_tmp2
          where customerid in 
                             (Select customerid
                              from Customers
                              where Country = 'USA')
        COMMIT TRANSACTION
        
           -- (99 個資料列受到影響)
        
        -- (檢視)
        select * from orders_tmp2
        where customerid in 
                           (Select customerid
                            from Customers
                            where Country = 'USA') 
          
           -- (0 個資料列受到影響)  
        
        -- 無法再 ROLLBACK,資料被永久刪除
        ROLLBACK TRANSACTION                    

------------------------------------------------------------------------
/* TRUNCATE TABLE */
 -- perform a nonlogged deletion of all rows 
 1. TRUNCATE TABLE 不能指定(搭配) WHERE 條件區間，因此影響的是整個資料表
 2. TRUNCATE TABLE 比 DELETE TABLE 速度快
 3. 使用權限: ALTER,table_owner,sysadmin,db_owner,db_ddladmin
 4. TRUNCATE 會重置 IDENTITY 數值
 
 -- example 1: 
 truncate table northwind..orders4
 
   --檢視結果
 select * from northwind..orders4
   
        --(0 個資料列受到影響) 
        
 -- example 2: 重置 IDENTITY 數值
    
    --step 0. preparatory action
    use mis
    go
    
      -- create table empauto
    if exists (select * from sys.tables where name='empauto')
    drop table empauto
    go
    
    create table empauto
    (empid int identity (10,1) not null,
     empname varchar(30),
     dep varchar(10)
    )
    go 
    
       --insert data
    insert into empauto
    values ('jack','F04'),('mary','F04'),('tom','F05')
    
       --檢視
    select * from empauto 
    
       --delete all
    delete from empauto 
    
       --insert data again
    insert into empauto
    values ('jack','F04'),('mary','F04'),('tom','F05')
    
       --再檢視 (序號繼續)
    select * from empauto 
    
       --truncate table
    truncate table empauto 
    
       --insert data again
    insert into empauto
    values ('jack','F04'),('mary','F04'),('tom','F05')
    
       --再檢視 (序號重置)
    select * from empauto       
         
  /**********************************************
   *                比較                 *
   **********************************************/
    -- delete from table
    -- drop table
    -- truncate table 
---------------------------------------------------------------------------------------------------
/***************************************************************
 *  異動資料 --> UPDATE                                        *
 ***************************************************************/
--syntax:
/* UPDATE tablename (viewname)
    SET fieldname1=value1,fieldname2=value2,... 
    [FROM {<table_source>},[...n]]
    [WHERE <search_condition>]   */
------------------------------------------------------------------------------------------
/* 所有資料異動 */
-- 先看原來的值
use mis
go
select * from employee

-- 異動所有資料: 加薪2000
update employee
set salary=salary+2000

-- 驗證 
select * from employee
------------------------------------------------------------------------------------------
/* update with where */
--example 1: 只有女孩子調薪7%
update employee
set salary=salary*1.07
where sex='F'

--example 2: 
update employee
set address='kao',dep='D11000'
where dep is null and address is null
------------------------------------------------------------------------------------------
/* update with select */
-- Updating Rows Based on Other Tables
  -- Specifying Rows to Update Using Subqueries
  -- example: northwind , 將supplier country為USA的product unitprice加10% ( for tax )
  
  use northwind
  go
  
   update products
   set unitprice = unitprice * 1.1
   from products inner join suppliers
      on porducts.supplierid = suppliers.supplierid
   where suppliers.country = 'USA'
  
  -- or
  update products
  set unitprice = unitprice * 1.1
  where supplierid in
               (select supplierid 
                from suppliers
                where country = 'USA')
----------------------------------------------------              
/* update with corelated subquery */
-- example:
use tempdb
go
--建立一個統計資料表
create table OrdersSummary  
( CustomerId nchar(5),
  OrderCount int)
--填入customer id
insert into OrdersSummary
select CustomerID,0
from Northwind..Customers
--以銷售總計資料更新每筆ID
update OrdersSummary 
set OrderCount=OrderCount+(select count(OrderID)
                                               from northwind..orders o
                                               where OrdersSummary.customerid=o.customerid
                                               and orderdate between '1997-7-1' and '1997-7-31')
-- 驗證:
select * from orderssummary
order by ordercount desc 
--更新1997/8資料
update OrdersSummary 
set OrderCount=OrderCount+(select count(OrderID)
                                               from northwind..orders o
                                               where OrdersSummary.customerid=o.customerid
                                               and orderdate between '1997-8-1' and '1997-8-31') 
-- 驗證:
select * from orderssummary
order by ordercount desc 
-------------------------------------------------------------------------------------
 -- 練習一 : 將銷售總量不到50的書打85折(pubs.titles,sales)  
 -- 解答:
 use pubs
 go
 update titles
 ......

 -- 練習二: 將今天的訂單所有訂項加十個(northwind.orders,orderdetail)
use northwind
go

----------------------------------------------------------------------
/* update with CASE statement */
-- example 1: 分階牌價調整(unitprice)
   --step 0. copy products_tmp from products
   use northwind
   go
   
   select * into #products_tmp from products

   --step 1. update product.unitprice with CASE statement
   update #products_tmp
   set unitprice=
   case
       when (unitprice <= 100) then unitprice*1.07
       when (unitprice > 100 and unitprice <= 200) then unitprice*1.05
       when (unitprice > 200) then unitprice*1.03
   end
   go 
   
--練習: 分國別牌價調整(#products_tmp.unitprice)。
        產品供應商(suppliers)國別為 'USA'    -- 調漲 4%,
                                    'canada'-- 調漲 8%,
                                    其他國家 -- 調漲 2%
                                    
--解答:
--step 0. copy products_tmp from products
   use northwind
   go
   
   select * into #products_tmp from products

   --step 1. update product.unitprice with CASE statement
   update #products_tmp
   set unitprice=
   case 
       when SupplierID IN 
       ...
       ...
       ...
       else  unitprice*1.02
   end
   output deleted.productid 產品代號,deleted.unitprice 調整前單價,inserted.unitprice 調整後單價
   go 
-----------------------------------------------------------------------------------------------
/* update with composite operator (複合運算子) */
-- 複合運算子: +=, -=, *=, /=,...
-- example: 
use mis
go
   -- +=
update employee
set salary += 2000
where sex='M' 

  -- *=
update employee
set salary *=1.07
where sex='M'  
----------------------------------------------------------------------
  
/* 大量資料異動 */
 -- 清除TRANSACTION LOG 
 -- BACKUP LOG WITH TRUNCATE_ONLY
BACKUP LOG mis WITH TRUNCATE_ONLY

============================================================================================
/*  輸出更動的資料 : OUTPUT */
--使用INSERT、UPDATE、DELETE 敘述時, SQL Server 只會傳回受影響的列數, 無法得知哪些資料被更動
--使用 OUTPUT 子句來搭配 INSERT、UPDATE、DELETE 敘述,可以傳回資料被更動之前或之後的內容
--OUTPUT 子句的基本語法如下：
  OUTPUT {DELETED | INSERTD}.{*|column_name}
  
  --DELETED 、INSERTED是 2 個虛擬資料表, 內含所有被異動到的記錄。
    --DELETED 中儲存著異動前的舊資料
    --INSERTED 中則儲存著異動後的新資料
    --page 8-30
    --這兩個表格主要用於trigger

--example 1: (INSERT / INSERTED)
  USE mis
  GO
  
  INSERT INTO employee (emp_no,emp_name,salary)
  OUTPUT inserted.*
  VALUES ('E004','JACK',80000),
         ('E005','MARY',68000),
         ('E007','JOHN',43000)
  
--example 2: (UPDATE / INSERTED, DELETED)
  UPDATE employee 
  SET salary = salary*1.07
  OUTPUT deleted.emp_no AS 員工編號,deleted.salary 原先薪資,inserted.salary 調整後薪資
  WHERE salary <= 70000
  
--example 3: (DELETE / DELETED)
  DELETE employee
  OUTPUT deleted.*
  WHERE salary >= 80000  
----------------------------------------------------------------
/* 將更動的資料輸出至其他資料表或table變數 */
-- 語法:
   OUTPUT {DELETED | INSERTED}.{*|column_name}
   INTO {output_table | @table_variable}[(column_list)]

--example 1:
  --step 1: create table #emp_tmp1
    USE mis
    GO
    
    CREATE TABLE #emp_tmp1
    (員工編號 char(8),
     原先薪資 numeric(10,2),
     調整後薪資 numeric(10,2))
 
  --step 2:          
    UPDATE employee 
    SET salary = salary*0.98
    OUTPUT deleted.emp_no AS 員工編號,deleted.salary 原先薪資,inserted.salary 調整後薪資
    INTO #emp_tmp1(員工編號,原先薪資,調整後薪資)
    WHERE salary > 40000 
    
  --step 3: 驗證
    SELECT * FROM #emp_tmp1 
    
 --練習1:修改上例，令OUPPUT 輸出到 #emp_tmp2,加上調整日期，結果如下:
 員工編號  原先薪資                  調整後薪資             調整日期
--------  -------------------------- ---------------------- -----------------------
E0010004   42000.00                   41160.00              2010-10-06 09:44:27.373
E0991      42000.00                   41160.00              2010-10-06 09:44:27.373
E0992      45000.00                   44100.00              2010-10-06 09:44:27.373
E0993      47000.00                   46060.00              2010-10-06 09:44:27.373

(4 個資料列受到影響)        
         
 --解答:
        -- step 1. create table #empl_tmp2
        USE mis
        GO
        
        
      --step 2:          
      UPDATE employee 
      ......
      
      --step 3: 驗證
      SELECT * FROM #emp_tmp2 
 /* 合併資料 MERGE */       
 -- https://www.sqlservertutorial.net/sql-server-basics/sql-server-merge/
 -- merge_20200816.pptx
 -- SQL Server MERGE statement example:

 -- use database and create table and insert sample data:
 use adventureworks
 go
    --create table sales.category
 CREATE TABLE Sales.category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);
  -- insert data into sales.category
INSERT INTO sales.category(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (2,'Comfort Bicycles',25000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',10000);
	
	-- create table sales.category_staging
CREATE TABLE sales.category_staging (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);
  -- insert data into sales.category_staging
INSERT INTO sales.category_staging(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',20000),
    (5,'Electric Bikes',10000),
    (6,'Mountain Bikes',10000);

  --merge
  --sales.category (target table) / sales.category_staging (source table)
MERGE sales.category as t 
    USING sales.category_staging as s
ON (s.category_id = t.category_id)
WHEN MATCHED
    THEN UPDATE SET 
        t.category_name = s.category_name,
        t.amount = s.amount
WHEN NOT MATCHED BY TARGET 
    THEN INSERT (category_id, category_name, amount)
         VALUES (s.category_id, s.category_name, s.amount)
WHEN NOT MATCHED BY SOURCE 
    THEN DELETE;

  -- 查看merge執行後結果
select * from Sales.category; --target table
select * from Sales.category_staging; --cource table