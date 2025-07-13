-- Stored Procedure: InsertOrderDetails
CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount FLOAT = 0
AS
BEGIN
    DECLARE @Stock INT, @ReorderLevel INT;
    SELECT @Stock = UnitsInStock, @ReorderLevel = ReorderLevel
    FROM Products
    WHERE ProductID = @ProductID;

    IF @Stock IS NULL OR @Stock < @Quantity
    BEGIN
        PRINT 'Insufficient stock or product not found.';
        RETURN;
    END

    IF @UnitPrice IS NULL
        SELECT @UnitPrice = UnitPrice FROM Products WHERE ProductID = @ProductID;

    INSERT INTO [Order Details](OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;

    IF @Stock - @Quantity < @ReorderLevel
        PRINT 'Warning: Stock below reorder level.';
END;

-- Stored Procedure: UpdateOrderDetails
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    UPDATE od
    SET 
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        Quantity = ISNULL(@Quantity, Quantity),
        Discount = ISNULL(@Discount, Discount)
    FROM [Order Details] od
    WHERE OrderID = @OrderID AND ProductID = @ProductID;
END;

-- Stored Procedure: GetOrderDetails
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM [Order Details] WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist';
        RETURN 1;
    END
    SELECT * FROM [Order Details] WHERE OrderID = @OrderID;
END;

-- Stored Procedure: DeleteOrderDetails
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM [Order Details] WHERE OrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'Invalid parameters. Order or Product not found.';
        RETURN -1;
    END

    DELETE FROM [Order Details] WHERE OrderID = @OrderID AND ProductID = @ProductID;
END;

-- Function: Convert to MM/DD/YYYY
CREATE FUNCTION dbo.fn_ConvertToMMDDYYYY (@inputDate DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN FORMAT(@inputDate, 'MM/dd/yyyy');
END;

-- Function: Convert to YYYYMMDD
CREATE FUNCTION dbo.fn_ConvertToYYYYMMDD (@inputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN CONVERT(VARCHAR(8), @inputDate, 112);
END;

-- View: vwCustomerOrders
CREATE VIEW vwCustomerOrders AS
SELECT c.CompanyName, o.OrderID, o.OrderDate, od.ProductID, p.ProductName, 
       od.Quantity, od.UnitPrice, od.Quantity * od.UnitPrice AS Total
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;

-- View: vwCustomerOrdersYesterday
CREATE VIEW vwCustomerOrdersYesterday AS
SELECT * FROM vwCustomerOrders
WHERE OrderDate = CAST(GETDATE() - 1 AS DATE);

-- View: MyProducts
CREATE VIEW MyProducts AS
SELECT p.ProductID, p.ProductName, p.QuantityPerUnit, p.UnitPrice,
       s.CompanyName, c.CategoryName
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE p.Discontinued = 0;

-- Trigger: Instead of Delete on Orders
CREATE TRIGGER trg_InsteadOfDeleteOrders
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM [Order Details] WHERE OrderID IN (SELECT OrderID FROM DELETED);
    DELETE FROM Orders WHERE OrderID IN (SELECT OrderID FROM DELETED);
END;

-- Trigger: Insert check for stock on Order Details
CREATE TRIGGER trg_CheckStockBeforeInsert
ON [Order Details]
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT, @Stock INT;
    SELECT @ProductID = ProductID, @Quantity = Quantity FROM INSERTED;
    SELECT @Stock = UnitsInStock FROM Products WHERE ProductID = @ProductID;

    IF @Stock IS NULL OR @Stock < @Quantity
    BEGIN
        PRINT 'Order cannot be fulfilled due to insufficient stock.';
        RETURN;
    END

    INSERT INTO [Order Details]
    SELECT * FROM INSERTED;

    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;
END;
