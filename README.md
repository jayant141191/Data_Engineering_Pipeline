# Data_Engineering_Pipeline Codes

Below are the instructions describing which directory contains answers to which coding challenge and also any additional required documentation. 

# Coding Challenge

## Question 1 
Write an SQL statement to find the total number of user sessions each page has each day.

* The answer to this question is stored in **Total_Users_Sessions/total_user_sessions_per_day.sql**

## Question 2
Create an SQL query will show a list of products frequently purchased with the top 10
bestsellers

* The answer to this question is stored in **Market_Basket_Analysis/market_basket_analysis.sql**

### Formuale's Used for Market Basket Analysis
**Note -** Here 
* **ProductA** are the bestselling products (top 10)
* **ProductB** are the products frequently purchased with bestselling products

**Support**
```
Support(A) = P(A) = no of transactions where ProductA was bought / total no of transactions 
Support(B) = P(B) = no of transactions where ProductB was bought / total no of transactions 
```
**Confidence**
```
Confidence(B -> A) = Support of B and A / Support of A
```
**Lift Ratio**
```
Lift Ratio = Confidence / Support of B 
```

## Question 3 

1) Write an SQL script to create a data table to store the visitor assignment data

* The answer to this question is stored in **Visitor_Assignment_ETL_process/create_visitor_assignment_table.sql**

2) Write a python script to extract all the visitor assignment log messages from the log file and
store it in the data table you created

* The answer to this question is stored in **Visitor_Assignment_ETL_process/visitor_assign_log_parser.py**
**Note -** **visitor_assign_log_parser.py** script parses the log then extracts relevant information and inserts data into data table created

3) Write the SQL queries that will help answer the questions A and B as below:
* A) What are the total number users assigned to the “Test” and “Control” groups in each
experiment?
* B) Which day had the highest number of user group assignments per experiment?

* The answer to this question is stored in **Visitor_Assignment_ETL_process/analysis_queries.sql**
**Note -** **analysis_queries.sql** contain queries for both questions A and B as above 
