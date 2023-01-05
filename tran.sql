use Northwind
  go

  select *  into orders3  from orders;

  select*from orders3;

select*
from orders3
where CustomerID in (select CustomerID
                                             from Customers
											 where Country='USA');

--顯式交易 begin...[rollback]...commit
begin tran
delete from orders3
where CustomerID in (select CustomerID
                                             from Customers
											 where Country='USA');

select*
from orders3
where CustomerID in (select CustomerID
                                             from Customers
											 where Country='USA');

rollback

select*
from orders3
where CustomerID in (select CustomerID
                                             from Customers
											 where Country='USA');

begin tran
delete from orders3
where CustomerID in (select CustomerID
                                             from Customers
											 where Country='USA');
commit tran

rollback

select*
from orders3
where CustomerID in (select CustomerID
                                             from Customers
											 where Country='USA');

select *  into orders4  from orders;

select*from orders4;

select*
from orders4
where CustomerID in (select CustomerID
                                             from Customers
											 where Country='USA');

--隱式交易
delete from orders4
where CustomerID in (select CustomerID
                                             from Customers
											 where Country='USA');

rollback