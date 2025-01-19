import pandas as pd
from sqlalchemy import create_engine

# MySQL connection details
username = 'USERNAME'  # Replace with your MySQL username
password = 'PASSWORD'  # Replace with your MySQL password
host = '127.0.0.1'  # MySQL host (localhost)
port = '3306'  # MySQL port
database_name = 'NashvileHousing'  # Replace with your target database name

# Create a connection to the MySQL database using pymysql
engine = create_engine(f'mysql+pymysql://{username}:{password}@{host}:{port}/{database_name}')

# Load CSV file into a DataFrame
file_path = '/Users/maryamsaaly/Downloads/Nashville Housing Data for Data Cleaning.csv'  # Replace with your CSV file path
df = pd.read_csv(file_path)

# Clean up the column names (remove any leading/trailing spaces)
df.columns = df.columns.str.strip()

# Preview the data
print(df.head())

# Import the DataFrame into MySQL (replace 'your_table_name' with your table's name)
try:
    df.to_sql('nashville_housing', con=engine, index=False, if_exists='replace')  # Change 'replace' if needed
    print("Data imported successfully!")
except Exception as e:
    print(f"Error during data import: {e}")