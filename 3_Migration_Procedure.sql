-- Create Sequences for Primary Keys
CREATE SEQUENCE SupplierSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE OrderSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE OrderLineSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE InvoiceSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE PaymentSeq START WITH 1 INCREMENT BY 1;

-- Create or replace the package
CREATE OR REPLACE PACKAGE OrderMigrationPackage AS
  -- Procedure to migrate data from XXBCM_ORDER_MGT to normalized tables
  PROCEDURE MigrateData;
END OrderMigrationPackage;
/

-- Create or replace the package body
CREATE OR REPLACE PACKAGE BODY OrderMigrationPackage AS
  -- Procedure to migrate data from XXBCM_ORDER_MGT to normalized tables
  PROCEDURE MigrateData IS
   v_date_str VARCHAR2(20);
   v_date     DATE;
   v_formatted_date VARCHAR2(20);
  BEGIN
    FOR order_rec IN (SELECT * FROM XXBCM_ORDER_MGT) LOOP
      -- Insert data into Suppliers table
      INSERT INTO Suppliers (
        Supplier_ID,
        Supplier_Name,
        Supplier_Contact_Name,
        Supplier_Address,
        Supplier_Contact_Number,
        Supplier_Email
      ) VALUES (
        SupplierSeq.NEXTVAL,
        order_rec.SUPPLIER_NAME,
        order_rec.SUPP_CONTACT_NAME,
        order_rec.SUPP_ADDRESS,
        order_rec.SUPP_CONTACT_NUMBER,
        order_rec.SUPP_EMAIL
      );

      -- Start Handling date issue
       v_date_str := order_rec.ORDER_DATE;
      BEGIN
         v_date := TO_DATE(v_date_str, 'DD-MON-YYYY');
      EXCEPTION
         WHEN OTHERS THEN
            v_date := TO_DATE(v_date_str, 'DD-MM-YYYY');
      END;
      v_formatted_date := TO_CHAR(v_date, 'DD-MON-YYYY');
      v_date := TO_DATE(v_formatted_date, 'DD-MON-YYYY');
      -- End Handling Date Issue

      -- Insert data into Orders table
      INSERT INTO Orders (
        Order_ID,
        Order_Ref,
        Order_Date,
        Supplier_ID,
        Order_Total_Amount,
        Order_Description,
        Order_Status
      ) VALUES (
        OrderSeq.NEXTVAL,
        order_rec.ORDER_REF,
        TO_DATE(v_date, 'DD-MON-YYYY'),  -- Adjust the date format if needed
        SupplierSeq.CURRVAL,
        TO_NUMBER(REPLACE(TRANSLATE(NVL(order_rec.ORDER_TOTAL_AMOUNT, '0'), 'OoIiSs-', '0011550'), ',', '')),
        order_rec.ORDER_DESCRIPTION,
        order_rec.ORDER_STATUS
      );

      -- Insert data into OrderLines table
      INSERT INTO OrderLines (
        OrderLine_ID,
        Order_ID,
        Order_Line_Amount
      ) VALUES (
        OrderLineSeq.NEXTVAL,
        OrderSeq.CURRVAL,
        TO_NUMBER(REPLACE(TRANSLATE(NVL(order_rec.ORDER_LINE_AMOUNT, '0'), 'OoIiSs-', '0011550'), ',', ''))
      );

       -- Start Handling date issue
       v_date_str := order_rec.INVOICE_DATE;
      BEGIN
         v_date := TO_DATE(v_date_str, 'DD-MON-YYYY');
      EXCEPTION
         WHEN OTHERS THEN
            v_date := TO_DATE(v_date_str, 'DD-MM-YYYY');
      END;
      v_formatted_date := TO_CHAR(v_date, 'DD-MON-YYYY');
      v_date := TO_DATE(v_formatted_date, 'DD-MON-YYYY');
      -- End Handling Date Issue

      -- Insert data into Invoices table
      INSERT INTO Invoices (
        Invoice_ID,
        Order_ID,
        Invoice_Reference,
        Invoice_Date,
        Invoice_Status,
        Invoice_Hold_Reason,
        Invoice_Amount,
        Invoice_Description
      ) VALUES (
        InvoiceSeq.NEXTVAL,
        OrderSeq.CURRVAL,
        order_rec.INVOICE_REFERENCE,
        TO_DATE(v_date, 'DD-MON-YYYY'),  -- Adjust the date format if needed
        order_rec.INVOICE_STATUS,
        order_rec.INVOICE_HOLD_REASON,
        TO_NUMBER(REPLACE(TRANSLATE(NVL(order_rec.INVOICE_AMOUNT, '0'), 'OoIiSs-', '0011550'), ',', '')),
        order_rec.INVOICE_DESCRIPTION
      );

      -- Insert data into Payments table
      INSERT INTO Payments (
        Payment_ID,
        Invoice_ID,
        Payment_Amount,
        Payment_Date
      ) VALUES (
        PaymentSeq.NEXTVAL,
        InvoiceSeq.CURRVAL,
        TO_NUMBER(REPLACE(TRANSLATE(NVL(order_rec.INVOICE_AMOUNT, '0'), 'OoIiSs-', '0011550'), ',', '')),
        SYSDATE  -- Assuming the current date for payment date
      );

    END LOOP;
  END MigrateData;
END OrderMigrationPackage;
/

BEGIN
  OrderMigrationPackage.MigrateData;
END;