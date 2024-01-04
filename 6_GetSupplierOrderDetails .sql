CREATE OR REPLACE PROCEDURE GetSupplierOrderDetails (
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_cursor OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_cursor FOR
    SELECT
        Supplier_Name,
        Supplier_Contact_Name,
		TRIM(SUBSTR(Supplier_Contact_Number, 1, INSTR(Supplier_Contact_Number, ',') - 1)) AS Supplier_Contact_No_1,
        TRIM(SUBSTR(Supplier_Contact_Number, INSTR(Supplier_Contact_Number, ',') + 1)) AS Supplier_Contact_No_2,
        COUNT(DISTINCT Orders.Order_ID) AS Total_Orders,
        TO_CHAR(SUM(Order_Total_Amount), '999,999,990.00') AS Order_Total_Amount
    FROM Suppliers
    JOIN Orders ON Suppliers.Supplier_ID = Orders.Supplier_ID
    WHERE Orders.Order_Date BETWEEN p_start_date AND p_end_date
    GROUP BY
        Supplier_Name,
        Supplier_Contact_Name,
        Supplier_Contact_Number1,
        Supplier_Contact_Number2
    ORDER BY Supplier_Name;

END GetSupplierOrderDetails;
/


CREATE OR REPLACE FUNCTION ExtractContactNumbers(
    p_contact_number1 VARCHAR2,
    p_contact_number2 VARCHAR2
) RETURN VARCHAR2 IS
    v_number1 VARCHAR2(20);
    v_number2 VARCHAR2(20);
BEGIN
    -- Extracting the first and second numbers from contact_number1
    v_number1 := CASE 
                   WHEN REGEXP_REPLACE(p_contact_number1, '[^0-9]', '') IS NOT NULL
                   THEN TO_CHAR(TO_NUMBER(REGEXP_REPLACE(p_contact_number1, '[^0-9]', '')), '999-9999')
                   ELSE NULL
                END;

    -- Extracting the first and second numbers from contact_number2
    v_number2 := CASE 
                   WHEN REGEXP_REPLACE(p_contact_number2, '[^0-9]', '') IS NOT NULL
                   THEN TO_CHAR(TO_NUMBER(REGEXP_REPLACE(p_contact_number2, '[^0-9]', '')), '999-9999')
                   ELSE NULL
                END;

    -- Handling the case when only one number exists
    IF v_number1 IS NOT NULL AND v_number2 IS NULL THEN
        RETURN v_number1 || ', ';
    ELSIF v_number1 IS NULL AND v_number2 IS NOT NULL THEN
        RETURN ', ' || v_number2;
    ELSE
        RETURN v_number1 || ', ' || v_number2;
    END IF;
END ExtractContactNumbers;
/
