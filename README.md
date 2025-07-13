# Level-B-Task

## 🧠 Description

This project showcases advanced SQL capabilities using Microsoft SQL Server and the AdventureWorks database. The tasks involve:

- Writing **stored procedures** for CRUD operations on order data.
- Creating **user-defined functions** for custom date formatting.
- Building **views** to simplify common query patterns.
- Implementing **triggers** for data consistency and automation.

## 🧩 Requirements

- **Microsoft SQL Server 2019/2022**
- **AdventureWorks** sample database (e.g., `AdventureWorks2019` or `AdventureWorksDW2022`)
- Tools like:
  - SQL Server Management Studio (SSMS) **or**
  - Azure Data Studio

## ✅ Features

### 1. Stored Procedures
- `InsertOrderDetails`: Adds an order line, handles inventory check, and alerts low stock.
- `UpdateOrderDetails`: Updates order lines with partial input, retains existing values if NULL.
- `GetOrderDetails`: Retrieves all lines of a given order.
- `DeleteOrderDetails`: Validates and removes order details and associated inventory.

### 2. Scalar Functions
- `fn_FormatDate_MMDDYYYY`: Converts `datetime` to `MM/DD/YYYY`.
- `fn_FormatDate_YYYYMMDD`: Converts `datetime` to `YYYYMMDD`.

### 3. Views
- `vwCustomerOrders`: Displays customer order summaries.
- `vwCustomerOrders_Yesterday`: Filters orders placed yesterday.
- `MyProducts`: Shows non-discontinued products with supplier and category info.

### 4. Triggers
- `trg_DeleteOrder`: Deletes order details before deleting order record (`INSTEAD OF DELETE`).
- `trg_OrderCheckStock`: Validates stock availability before inserting into `OrderDetails`.

## 🧪 How to Use

1. **Clone the repo**:
   ```bash
   git clone https://github.com/prathameshlad1213/Level-B-Task.git
