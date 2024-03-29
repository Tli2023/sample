# objective  obtain via api acs5 2009-2022 tract level data
# last update: mar. 11. 2024
import requests 
import pandas as pd
import geopandas as gpd 
import time
from functools import reduce

# api key
api_key =pd.read_csv("/Users/tli/Downloads/thesis_tidesbbs/code/api_key.txt")

# url
url2009 = 'https://api.census.gov/data/2009/acs/acs5'

# list of variables: 

# age 
age = [f'B01001_{i:03}E' for i in range(1, 50)] 
# race 
race = [f'B02001_{i:03}E' for i in range(1,9)]
# mobility: GEOGRAPHICAL MOBILITY IN THE PAST YEAR BY SEX FOR CURRENT RESIDENCE IN THE UNITED STATES
mobility = [f'B07003_{i:03}E' for i in range(1, 19)]
# employment: SEX BY AGE BY EMPLOYMENT STATUS FOR THE POPULATION 16 YEARS AND OVER
employment1 = [f'B23001_{i:03}E' for i in range(1, 51)]
employment2 = [f'B23001_{i:03}E' for i in range(51,101)]
employment3 = [f'B23001_{i:03}E' for i in range(101,151)]
employment4 = [f'B23001_{i:03}E' for i in range(151,174)]
# commuting time: TRAVEL TIME TO WORK
commuting_time = [f'B08303_{i:03}E' for i in range(1, 14)]
# MEANS OF TRANSPORTATION TO WORK
transport_commute = [f'B08301_{i:03}E' for i in range(1, 22)]
# HOUSEHOLD TYPE (INCLUDING LIVING ALONE) ie. Estimate!!Total!!Family households!!Married-couple family
household_type = [f'B11001_{i:03}E' for i in range(1, 10)]
# POVERTY STATUS IN THE PAST 12 MONTHS BY SEX BY AGE
poverty = [f'B17001_002E']
# HOUSING UNITS : Occupied/ vacant
housing_unit = [f'B25002_{i:03}E' for i in range(1, 4)] 
# Tenure
tenure = [f'B25003_{i:03}E' for i in range(1, 4)]
# Rooms
rooms = [f'B25017_{i:03}E' for i in range(1, 11)]
# contract rent 
contract_rent = [f'B25056_{i:03}E' for i in range(1, 25)]
# RENT ASKED
rent_asked = [f'B25061_{i:03}E' for i in range(1, 23)]
# gross rent
gross_rent = [f'B25063_{i:03}E' for i in range(1, 25)]
# GROSS RENT AS A PERCENTAGE OF HOUSEHOLD INCOME IN THE PAST 12 MONTHS
rentper = [f'B25070_{i:03}E' for i in range(1, 12)]
# aggregate income Estimate!!Aggregate income in the past 12 months (in 2009 inflation-adjusted dollars)
sum_y = [f'B19313_001E']
# Estimate!!Per capita income in the past 12 months (in 2009 inflation-adjusted dollars)
percapita_y = [f'B19301_001E']
# HOUSEHOLD INCOME IN THE PAST 12 MONTHS (IN 2009 INFLATION-ADJUSTED DOLLARS)
income = [f'B19001_{i:03}E' for i in range(1, 18)]
#  SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER
edu = [f'B15002_{i:03}E' for i in range(1, 36)]
### generate the response parameters
varlist =[
    age, race, mobility, employment1, employment2, employment3, employment4,
    commuting_time, transport_commute, household_type, poverty, housing_unit,
    tenure, rooms, contract_rent, rent_asked, gross_rent, rentper, sum_y,
    percapita_y, income, edu
]
params_dict = {}
for index, var in enumerate(varlist):
    # Create a unique key for each set of parameters using the index
    key = f"params_{index}"
    
    # Construct the 'get' parameter by joining all variable codes in the sublist
    id = ','.join(var)
    
    # Construct the parameters dictionary for the current set of variables
    params = {
        'get': id,
        'for': 'tract:*',
        'in': 'state:17&county:031',
        'key': api_key,
    }
    
    # Assign the parameters dictionary to the unique key in params_dict
    params_dict[key] = params

params_dict
df2009 = []
## now we request the parameters
for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2009, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2009.append(df)
    else:
        print(f'error for {i}')
    
    time.sleep(2)

acs2009 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2009)
acs2009.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2009.csv",index=False)
acs2009.columns

# merge lon lat of acs2009 to have chicago only
boundary2000 = gpd.read_file("/Users/tli/Downloads/thesis_tidesbbs/tract_boundaries/Boundaries - Census Tracts - 2000/geo_export_37050f7a-20a2-400b-9747-121f22287ce1.shp")
boundary2000.columns
acs2009['tract']=acs2009['tract'].astype('int64')
boundary2000['census_tra'] = boundary2000['census_tra'].astype('int64')
acs2009gdf = pd.merge(acs2009,boundary2000,left_on=['tract'],right_on=['census_tra'],how='right')
acs2009gdf.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/gdf_acs2009.csv",index=False)


# now we can do the same for the year of 2010
url2010 = 'https://api.census.gov/data/2010/acs/acs5'
df2010 = []

tic = time.time()
## now we request the parameters
for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2010, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2010.append(df)
    else:
        print(f'error pause {i}')
    
    time.sleep(2)
toc = time.time() - tic
acs2010 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2010)
acs2010.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2010.csv",index=False)


# year 2011
url2011 = 'https://api.census.gov/data/2011/acs/acs5'
df2011 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2011, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2011.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2011 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2011)
acs2011.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2011.csv",index=False)

# 2012
url2012 = 'https://api.census.gov/data/2012/acs/acs5'
df2012 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2012, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2012.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2012 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2012)
acs2012.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2012.csv",index=False)

# 2013
url2013 = 'https://api.census.gov/data/2013/acs/acs5'
df2013 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2013, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2013.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
df2013
acs2013 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2013)
acs2013.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2013.csv",index=False)

# 2014
url2014 = 'https://api.census.gov/data/2014/acs/acs5'
df2014 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2014, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2014.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2014 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2014)
acs2014['tract'].nunique()
acs2014.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2014.csv",index=False)

# 2015
url2015 = 'https://api.census.gov/data/2015/acs/acs5'
df2015 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2015, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2015.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2015 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2015)
acs2015['tract'].nunique()
acs2015.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2015.csv",index=False)

# 2016
url2016 = 'https://api.census.gov/data/2016/acs/acs5'
df2016 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2016, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2016.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2016 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2016)
acs2016['tract'].nunique()
acs2016.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2016.csv",index=False)

# 2017
url2017 = 'https://api.census.gov/data/2017/acs/acs5'
df2017 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2017, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2017.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2017 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2017)
acs2017['tract'].nunique()
acs2017.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2017.csv",index=False)

# 2018
url2018 = 'https://api.census.gov/data/2018/acs/acs5'
df2018 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2018, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2018.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2018 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2018)
acs2018['tract'].nunique()
acs2018.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2018.csv",index=False)

# 2019
url2019 = 'https://api.census.gov/data/2019/acs/acs5'
df2019 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2019, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2019.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2019 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2019)
acs2019['tract'].nunique()
acs2019.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2019.csv",index=False)

# 2020
url2020 = 'https://api.census.gov/data/2020/acs/acs5'
df2020 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2020, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2020.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2020 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2020)
acs2020['tract'].nunique()
acs2020.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2020.csv",index=False)

# 2021
url2021 = 'https://api.census.gov/data/2021/acs/acs5'
df2021 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2021, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2021.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2021 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2021)
acs2021['tract'].nunique()
acs2021.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2021.csv",index=False)

# 2022
url2022 = 'https://api.census.gov/data/2022/acs/acs5'
df2022 = []

tic = time.time()

for i in range(len(params_dict)):
    # Construct the dynamic key name
    key_name = f"params_{i}"
    # Retrieve the params for the current key
    params = params_dict[key_name]

    # Send the request
    response = requests.get(url2022, params=params)

    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        df = pd.DataFrame(data[1:], columns=data[0])
        df2022.append(df)
    else:
        print(f'pause')
    
    time.sleep(2)

toc = time.time() - tic
toc
acs2022 = reduce(lambda left, right: pd.merge(left, right, on=['state', 'county', 'tract'], how='outer'), df2022)
acs2022['tract'].nunique()
acs2022.to_csv("/Users/tli/Downloads/thesis_tidesbbs/data/raw/acs2022.csv",index=False)
# end of the document