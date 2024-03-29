# objective: this file is a toy sample of my python coding skills, each code are taken from a respective project
# date created: mar. 29
# author: tong LI
# email: tong.li1@sciencespo.fr

import requests 
import pandas as pd
import geopandas as gpd 
import time
from functools import reduce

# a sample code merging api data to crowsswalks:
# obtaining median value for house as an index:

import requests 
import pandas as pd
import time
api_key =pd.read_csv("/Users/tli/Downloads/thesis/code/api_key.txt")

med_val =[f"B25077_001E"]

dfs = pd.DataFrame()

for year in range(2010, 2023):  
    # Construct the URL for the current year
    url = f'https://api.census.gov/data/{year}/acs/acs5'
    
    # Parameters for the API request
    params = {
        'get': med_val,
        'for': 'tract:*',
        'in': 'state:17&county:031',
        'key': api_key,
    }
    
    # Make the API request
    response = requests.get(url, params=params)
    
    # Check if the request was successful
    if response.status_code == 200:
        # Convert the response to JSON
        data = response.json()
        
        # Create a DataFrame from the response
        df = pd.DataFrame(data[1:], columns=data[0])
        
        # Add a column for the year
        df['year'] = year
        
        # Append the DataFrame for the current year to the dfs
        dfs = pd.concat([dfs, df], ignore_index=True)
    else:
        print(f"Failed to fetch data for {year}. Status code: {response.status_code}")

dfs['year'].unique()

# loading crosswalk: 
tl2010 = pd.read_csv("/Users/tli/Downloads/thesis/tract_boundaries/CensusTractsTIGER2010.csv")

#2020-2022 cw:
urlcrosswalk = "https://www2.census.gov/geo/docs/maps-data/data/rel2020/tract/tab20_tract20_tract10_st17.txt"
tl20 = pd.read_csv(urlcrosswalk,delimiter='|')

# merge with chicago 2010 tract:
tlcw20= pd.merge(tl2010,tl20, left_on=['GEOID10'],
                      right_on=['GEOID_TRACT_10',], how='inner')

# keep the data concise
tlcw20.drop(columns=['OID_TRACT_10', 'GEOID_TRACT_10',
       'NAMELSAD_TRACT_10', 'AREALAND_TRACT_10', 'AREAWATER_TRACT_10',
       'MTFCC_TRACT_10', 'FUNCSTAT_TRACT_10', 'AREALAND_PART',
       'AREAWATER_PART'],inplace=True)

# we need to formulate the tractid to merge with acs tract in 6digits
tlcw20['GEOID_TRACT_20'] = tlcw20['GEOID_TRACT_20'].astype(str)
tlcw20['tract'] = tlcw20['GEOID_TRACT_20'].str[-6:]

# save storage:
tlcw20['tract'] =tlcw20['tract'].astype(int)

# now merge 2020-2022 df
medl_val_20 = dfs.merge(tlcw20[['tract','TRACTCE10']], on='tract').query('year >= 2020')
medl_val_20 = medl_val_20.rename(columns={'tract': 'tract20'})


## now we could filter the only chicagoian data for 2010:
med_val_10 = dfs.merge(tl2010['TRACTCE10'], right_on=['TRACTCE10'], left_on=['tract']).query('2010 <= year <= 2019')

# the now we have 3 df each merge with the chicagoian cw:
# med_val_00 med_val_10  medl_val_20 
dfs.columns
med_val_10.columns
medl_val_20.columns

# we append
med_val_cw = pd.concat([med_val_10, medl_val_20], ignore_index=True)
med_val_cw['tract'].fillna(med_val_cw['TRACTCE10'], inplace=True)
med_val_cw.groupby('year')['tract'].nunique()

med_val_cw.to_csv("/Users/tli/Downloads/thesis/data/processed/med_val_cw.csv",index=False)

# some geopandas merge:
# loop to load file" 
dfs = []

# Loop directly through the years of interest
for year in [2016, 2017, 2018, 2019, 2020, 2021]:
    # Construct the file path for each year
    filepath = f"/Users/tli/Downloads/{year}GSOD.csv"
    dfs.append(pd.read_csv(filepath))

# Concatenate all the DataFrames in the list into one DataFrame
gsod = pd.concat(dfs, ignore_index=True)

gsod['id'].head()

# as the id is a string, we want to filter with the relevant pattern:
gsod['ctry_filter'] = gsod['id'].str.split(',').str[1].str.strip()

gsod = gsod[gsod['ctry_filter']=='CH']

# now merge gsod with the local level info:
g939 = gpd.read_file("/Users/tli/Downloads/ecommerce/urban939/Urban939.shp")

gsod_g = gpd.GeoDataFrame(gsod, crs="EPSG:4326", geometry=gpd.points_from_xy(gsod.lon, gsod.lat))

gsod_city = gpd.sjoin(gsod_g,g939, how='inner')
gsod_city.to_csv("/Users/tli/Downloads/gsod_city.csv", index=False)

# this is the end of the document