CREATE OR REPLACE PROCEDURE GenerateOrderSummaryReport (p_cursor OUT SYS_REFCURSOR) IS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        TO_NUMBER(REGEXP_SUBSTR(Order_Ref, '\d+')) AS Order_Reference,
        TO_CHAR(Order_Date, 'MON-YY') AS Order_Period,
        INITCAP(Supplier_Name) AS Supplier_Name,
        TO_CHAR(Order_Total_Amount, '999,999,990.00') AS Order_Total_Amount,
        Order_Status,
        Invoice_Reference,
        TO_CHAR(Invoice_Amount, '999,999,990.00') AS Invoice_Total_Amount,
        CASE 
            WHEN MAX(Invoice_Status) = 'Paid' THEN 'OK'
            WHEN MAX(Invoice_Status) = 'Pending' THEN 'To follow up'
            ELSE 'To verify'
        END AS Action
    FROM Orders
    LEFT JOIN Invoices ON Orders.Order_ID = Invoices.Order_ID
    GROUP BY 
        Order_Ref,
        Order_Date,
        Supplier_Name,
        Order_Total_Amount,
        Order_Status,
        Invoice_Reference,
        Invoice_Amount
    ORDER BY Order_Date DESC;

END GenerateOrderSummaryReport;
/