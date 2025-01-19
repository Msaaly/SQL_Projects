Data Cleaning SQL Script:

This SQL script was created for cleaning the Nashville Housing Data.


SQL Queries:

- Standardize Date Format
- Populate Missing Property Address Data
- Split Address into Individual Columns
- Split Owner Address into Individual Columns
- Change 'Y' and 'N' to 'Yes' and 'No' in "Sold as Vacant" Field
- Remove Duplicates
- Delete Unused Columns


Dataset:

The script assumes you have a dataset named `NashvilleHousing` in your database. You should use the spreadsheet in this repository. 
If you had issue with importing the dataset from the excel file, you can use the python script to import the dataset as a table in MySQL.

