CREATE OR REPLACE PROCEDURE GetThirdHighestOrderDetails (p_cursor OUT SYS_REFCURSOR) IS
BEGIN
    OPEN p_cursor FOR
    SELECT
        TO_NUMBER(REGEXP_SUBSTR(Order_Ref, '\d+')) AS Order_Reference,
        TO_CHAR(Order_Date, 'Month DD, YYYY') AS Order_Date,
        UPPER(Supplier_Name) AS Supplier_Name,
        TO_CHAR(Order_Total_Amount, '999,999,990.00') AS Order_Total_Amount,
        Order_Status,
        LISTAGG(Invoice_Reference, ', ') WITHIN GROUP (ORDER BY Invoice_Reference) AS Invoice_References
    FROM (
        SELECT
            Order_Ref,
            Order_Date,
            Supplier_Name,
            Order_Total_Amount,
            Order_Status,
            Invoice_Reference,
            ROW_NUMBER() OVER (ORDER BY Order_Total_Amount DESC) AS rn
        FROM Orders
        LEFT JOIN Invoices ON Orders.Order_ID = Invoices.Order_ID
    )
    WHERE rn = 3;

END GetThirdHighestOrderDetails;
/



DECLARE
    v_cursor SYS_REFCURSOR;
BEGIN
    GetThirdHighestOrderDetails(v_cursor);
    -- Now you can fetch the result from the cursor and use it as needed
END;
/