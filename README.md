                                                                             SQL SALES ANALYSIS
Objective: This project aims to use sql code to draw insights from a sales database focusing on quarterly performance, popular products in store, payment methods, and delivery efficiency. The code also uses intereactive sql functions to get insights on selected products.
The provided SQL script aims to analyze sales data for each quarter of the year 2023, extract insights such as quarterly sales, percentage differences, popular products, customer behavior, and more.

Structure:
Declaration of Variables: Sets up variables for the start and end dates of each quarter in 2023.

Quarterly Sales Tables: Four temporary tables are created to store quarterly sales data for each product.

Sales_By_Quarter Table Creation: Creates a table named Sales_By_Quarter to store aggregated quarterly sales data for all products.

Insertion of Quarterly Sales Data: Inserts quarterly sales data into the Sales_By_Quarter table.

Analysis:

Total Quarter Sales and Percentage Difference: Calculates total quarter sales and percentage differences between consecutive quarters.
Most Purchased/Popular Products: Identifies the top 5 most purchased products.
Function Creation: Creates a function to retrieve sales data for a particular product.
Most Used Payment Method: Determines the most used payment method.
Delivery and Order Fulfillment Analysis: Analyzes delivery periods and identifies delayed deliveries.
Customer Analysis: Identifies the customer with the most purchases, calculates days till the next order, and identifies repurchased customers within 30 days after their first purchase.

Usage Instructions:
Set Variable Declarations: Ensure that the variables for the start and end dates of each quarter in 2023 are correctly set according to your dataset.

Execute the Script: Execute the SQL script in your preferred SQL environment against your database containing the necessary tables (e.g., orders, products, customers, payment_methods, order_delivery).

Review Results: After execution, review the results to gain insights into quarterly sales, popular products, customer behavior, payment methods, and order fulfillment.

Customization: Customize the script as per your specific requirements, such as modifying date ranges, adjusting calculations, or incorporating additional analyses based on your business needs.

Note:
Ensure that the necessary tables (orders, products, customers, payment_methods, order_delivery) are present in your database and contain relevant data for the analysis.
Validate the SQL script against your database schema and adjust table names, column names, and data types as needed to match your environment.
Regularly update date ranges or adjust analyses to reflect the most recent data and business trends.
