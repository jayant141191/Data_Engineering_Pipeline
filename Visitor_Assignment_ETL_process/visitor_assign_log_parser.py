import re
import ast
import requests
import sys
import psycopg2

try:
    import db_config
except ImportError:
    print("Failed to load db_config.py")
    sys.exit(1)


def get_log_file_from_url(url):
    """
    Method to download log file from url and save on local machine
    :param url: Specify url from where to download log file
    :return: filename and path
    """

    print("Downloading log file from {0} please wait...".format(url))

    # Send HTTP request to server and save the response in response object called response
    response = requests.get(url, stream=True)

    filename = "lighthouse-logs.log"
    # if response was Ok i.e status code = 200 then download the log file in chunks to avoid memory contention
    if response.status_code == 200:
        with open(filename, "wb") as file:
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    file.write(chunk)

        print("Downloaded successfully. File is stored at location {0}".format(filename))

        return filename
    else:
        print("Something wrong with the URL. Provide correct URL")


def parse_log(file):
    """
    Method to parse log file and extract relevant information
    :param file: Specify log file to parse
    :return: visitor info as list of dictionaries
    """

    print("Parsing log file {0} to extract relevant visitor assignment information".format(file))

    # Regex used to match relevant visitor assignment log lines
    line_regex = re.compile(r'.*"Request Number is.*$')

    # Open and read log file and extract visitor assignment info using regex match
    with open(file, "r") as f:
        match_list = [(ast.literal_eval(line)["msg"], ast.literal_eval(line)["time"]) for line in f if line_regex.search(line)]

    print("Parsing ended")

    return match_list


def insert_visitor_assign_info(data):
    """
    Method to insert visitor assignment information into postgres database
    :param data: Visitor assignment data as list of tuples of message and time
    :return:
    """

    # Read DB config from db_config.py file
    host = db_config.postgres["host"]
    user = db_config.postgres["user"]
    dbname = db_config.postgres["database"]
    port = db_config.postgres["port"]

    conn = None

    # SQL statement for inserting data
    sql = """INSERT INTO public.visitor_info(message, date_timestamp) VALUES (%s, %s)"""

    try:
        print("Connecting and inserting data into DB table visitor_info")
        # Connect to PostgresSQL DB
        conn = psycopg2.connect("host={0} user={1} dbname={2} port={3}".format(host, user, dbname, port))
        # Create a new  cursor
        cur = conn.cursor()
        # Execute the insert sql statement and insert all rows at once
        cur.executemany(sql, data)
        # Commit changes to the DB
        conn.commit()
        # Close communication with DB
        cur.close()
        print("Insert successful")
    except (Exception, psycopg2.DatabaseError) as error:
        print("Error occurred. Please see error message below")
        print(error)
    finally:
        if conn is not None:
            # Close connection with DB
            conn.close()


def main():

    # Location where log file is stored
    url = "https://s3-ap-southeast-1.amazonaws.com/ms-data-coding-challenge/lighthouse-logs.log"

    # Get the log file
    file = get_log_file_from_url(url)

    # Parse the log file to extract relevant information
    visitor_assign_info = parse_log(file)

    # Insert data into DB if any information available
    if len(visitor_assign_info) > 0:
        insert_visitor_assign_info(visitor_assign_info)


if __name__ == "__main__":
    main()



