import os
import sys
import json
import mysql.connector


MYSQL_HOST="localhost"
MYSQL_USER="root"
MYSQL_PASS="quehosting.es"
MYSQL_DB="quehosting"


def insert_into_hosting_support(db, id, support):
    """
    Inserts into hosting_support table

    :param db: mysql db cursor object
    :param id: the hosting_id
    :param support: the support_id
    """
    sql = """INSERT INTO hosting_support
            (HostingPlanId, SupportId)
            VALUES (%s, %s)"""
    val = (id, support)
    try:
        cursor = db.cursor() 
        cursor.execute(sql, val)
        db.commit()
        print(cursor.rowcount, "record inserted.")
    except:
        print("Cannot insert into database - support table")
        print(format(sys.exc_info()))


def get_hosting_data_files(dir):
    """
    Returns the list of json files from the sample-data directory
    """
    return os.listdir(dir + "/../sample-data/")


def get_json_from_file(file):
    """
    Returns the list of jsons object result from reading the file

    :params file: json file with a list of json entries
    """
    return json.load(file)


def mysql_connect():
    """
    Connects to MySQL with the global params
    """
    return mysql.connector.connect(
        host=MYSQL_HOST,
        user=MYSQL_USER,
        password=MYSQL_PASS,
        database=MYSQL_DB
    )


def insert_into_database(db, entry):
    """
    Inserts into the database the entry data

    :params db: database connection object
    :params entry: json object containing all data to be inserted
    """

    # HOSTING TABLE

    currency = None
    database_number = None  # Nullable
    database_size = None    # Nullable
    disk_size = None 
    disk_type = None 
    domain_included = None
    domain_subdomain = None # Nullable
    domains_parked = None   # Nullable
    hosting_plan = None
    hosting_type = None
    payment_month_min = None
    partition_key = None
    provider = None
    ssl_certificate = None
    support_list = []
    url = None
    web_number = None       # Nullable

    if 'Currency' in entry:
        currency = list(entry['Currency'].values())[0]
    if 'DatabaseNumber' in entry:
        database_number = list(entry['DatabaseNumber'].values())[0]
    if 'DatabaseSizeGB' in entry:
        database_size = list(entry['DatabaseSizeGB'].values())[0]
    if 'DiskSizeGB' in entry:
        disk_size_gb = list(entry['DiskSizeGB'].values())[0]
        if 'Size' in disk_size_gb:
            disk_size = list(disk_size_gb['Size'].values())[0]
        if 'Type' in disk_size_gb:
            disk_type = list(disk_size_gb['Type'].values())[0]
    if 'DomainIncluded' in entry:
        domain_included = list(entry['DomainIncluded'].values())[0]
    if 'DomainSubdomain' in entry:
        domain_subdomain = list(entry['DomainSubdomain'].values())[0]
    if 'DomainsParked' in entry:
        domains_parked = list(entry['DomainsParked'].values())[0]
    if 'HostingPlan' in entry:
        hosting_plan = list(entry['HostingPlan'].values())[0]
    if 'HostingType' in entry:
        hosting_type = list(entry['HostingType'].values())[0]
    if 'PaymentMonthMin' in entry:
        payment_month_min = list(entry['PaymentMonthMin'].values())[0]
    if 'HostingId' in entry:
        partition_key = list(entry['HostingId'].values())[0]
    if 'Provider' in entry:
        provider = list(entry['Provider'].values())[0]
    if 'Ssl' in entry:
        ssl_certificate = list(entry['Ssl'].values())[0]
    if 'SupportChat' in entry and list(entry['SupportChat'].values())[0] == "true":
        support_list.append("Chat")
    if 'SupportEmail' in entry and list(entry['SupportEmail'].values())[0] == "true":
        support_list.append("Email")
    if 'SupportPhone' in entry and list(entry['SupportPhone'].values())[0] == "true":
        support_list.append("Phone")
    if 'SupportTicket' in entry and list(entry['SupportTicket'].values())[0] == "true":
        support_list.append("Ticket")    
    if 'Url' in entry:
        url = list(entry['Url'].values())[0]
    if 'WebNumber' in entry:
        web_number = list(entry['WebNumber'].values())[0]

    support_list = ",".join(support_list)
    

    sql = """INSERT INTO hosting_plan
        (Currency,
        DatabaseNumber,
        DatabaseSize,
        DiskSize,
        DiskType,
        DomainIncluded,
        DomainSubdomain,
        DomainsParked,
        HostingPlan,
        HostingType,
        PartitionKey,
        PaymentMonthMin,
        Provider,
        SslCertificate,
        SupportList,
        Url,
        WebNumber)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    val = (currency,
        database_number,
        database_size,
        disk_size,
        disk_type,
        domain_included,
        domain_subdomain,
        domains_parked,
        hosting_plan,
        hosting_type,
        partition_key,
        payment_month_min,
        provider,
        ssl_certificate,
        support_list,
        url,
        web_number)

    try:
        cursor = db.cursor() 
        cursor.execute(sql, val)
        db.commit()
        print(cursor.rowcount, "record inserted.")
    except:
        print("Cannot insert into database")
        print(format(sys.exc_info()))


current_dir = os.path.abspath(os.getcwd())
files = get_hosting_data_files(current_dir)
try:
    mydb = mysql_connect()
except:
    print("Cannot connect to database")
for file in files:
    with open(current_dir + "/../sample-data/" + file,'r', encoding='utf-8') as f:
        print("[INFO] Working with file",format(file))
        json_files = get_json_from_file(f)
        for json_file in json_files:
            insert_into_database(mydb, json_file)
