# Objective: merging 3 data set quosoft x surf x gsod
# last update feb 23 2024

## First obtain 2016-2021 quosoft data, then reshape wide df. 
from datetime import datetime, timedelta
import pandas as pd
import requests
import os

# menu: first obtain a list of dates in txt format, for downloading at quotsoft
# reshape quotsoft df=> merge with baiduindex for the 200 cities we wanted
# output name baiducity_airquality

# Initialize an empty list to store the generated URLs
date_list = []

# Loop obtain all dates in month 10-11 for year 2016-21
for year in range(2016, 2021 + 1): #range +1 as for loop is [begin,end)
    start_date = datetime(year, 1, 1)  # October 1st of the current year
    end_date = datetime(year, 12, 31)   # November 30th of the current year

# Generate dates and replace [日期] in the URL
now = start_date
while now <= end_date:
    formatted_date = now.strftime('%Y%m%d')
    url = f'https://quotsoft.net/air/data/china_cities_{formatted_date}.csv'
    date_list.append(url)
    now += timedelta(days=1)

# Specify the full path for the output file
# touch '/Users/tli/Downloads/ecommerce/data/raw/quosoft/quosoft_dates_1621_jandec.txt'
txt_for_datelist = '/Users/tli/Downloads/ecommerce/data/raw/quosoft/quosoft_dates_1621_jandec.txt'

# Export the list of URLs into the text file
with open(txt_for_datelist, 'w') as file: 
    # Opens the file in write mode ('w'). If the file doesn't exist, it will be created. If it already exists, its content will be overwritten.
    for url in date_list:
        file.write(url + '\n') #Writes each URL followed by a newline character to the file.

# now download all csv for each individual date：
# Read URLs from the file
with open('/Users/tli/Downloads/ecommerce/data/raw/quosoft/quosoft_dates_1621_jandec.txt', "r") as file:
    urls = file.read().splitlines()

for url in urls:
    response = requests.get(url)
    if response.status_code == 200:
        # Construct the full path to save the file in the 'quosoft' folder
        filename = os.path.join('/Users/tli/Downloads/ecommerce/data/raw/quosoft/', url.split("/")[-1])
        with open(filename, 'wb') as file:
            file.write(response.content)
    else:
        print(f"Failed to download {url}")

print(f"all done.")

## appending csv files:
csv_path= '/Users/tli/Downloads/ecommerce/data/raw/quosoft/'
quosoft_df = []

for filename in os.listdir(csv_path): #This code uses os.listdir() to retrieve a list of filenames in the csv_directory 
    if filename.endswith('.csv'): #, it checks if the current filename ends with ".csv". This condition ensures that only CSV files are processed.
        file_path = os.path.join(csv_path, filename)
        # Read each CSV file into a DataFrame and append it to the list
        quosoft_each_year = pd.read_csv(file_path)
        quosoft_df.append(quosoft_each_year)

df = pd.concat(quosoft_df, ignore_index=True)
df.to_csv('/Users/tli/Downloads/ecommerce/data/raw/2.quosoft_long_1621_jandec.csv', index=False)

## now we reshape the file: 
# Define the columns to keep as is (identifiers)
identifiers = ['date', 'hour', 'type'] #by identifiers, reshape the df
short_df = pd.melt(df, id_vars=identifiers, var_name='cityname', value_name='value')

short_df.head() # san check 

# i want to have type on the x as wide variables
pivoted_df = short_df.pivot(index=['date', 'hour', 'cityname'], columns='type', values='value')

# i obtain the daily ave. 
daily_ave_df = pivoted_df.groupby(['date', 'cityname']).mean().reset_index()
set(daily_ave_df['cityname'].unique())

# preserving 99 cities: 
city99 = pd.read_stata('/Users/tli/Downloads/ecommerce/data/raw/dailyCongestion2016PinyinCN.dta')

# caveat: we have replace 伊犁哈萨克州 from quosoft to be 伊犁
daily_ave_df['cityname'].replace('伊犁哈萨克州', '伊犁', inplace=True)

# now we merge
quosoft99 = daily_ave_df[daily_ave_df['cityname'].isin(city99['city'])]
quosoft99['cityname'].nunique()

# exporting the data
quosoft99.to_csv('/Users/tli/Downloads/ecommerce/data/processed/5.final_quosoft99.csv', index=False)

## Merging with gsod:
gsod = pd.read_csv('/Users/tli/Downloads/ecommerce/data/processed/3.sodCityDaily.csv')

# renaming to merge with quosoft
gsod.columns
gsod = gsod.rename(columns={"日期": "date", 'CITYNAME':'cityname'})

# aligning the date formating with quosoft
gsod['date'] = gsod['date'].str.replace('-', '')
gsod['cityname'] = gsod['cityname'].str.replace('市', '')
set(gsod['cityname'].unique())
gsod['cityname'].replace('伊犁哈萨克自治州', '伊犁', inplace=True)

# type align:
gsod['date'] = gsod['date'].astype('int64')

# merge
gsod_quosoft_99 = pd.merge(quosoft99, gsod, on=['cityname', 'date'],how='left')
# city not in gsod
# set(quosoft99['cityname'].unique()) - set(gsod['cityname'].unique())

# export 
gsod_quosoft_99.to_csv('/Users/tli/Downloads/ecommerce/data/processed/5.final_gsod_quosoft99.csv', index=False)

### merge with surf data: 
file_name = '/Users/tli/Downloads/ecommerce/surf_06风向风速/SURF_CLI_CHN_MUL_DAY-WIN-11002-{}{:02d}.TXT'

# loading data
wind_list = []
for year in range(2016,2020):
    for month in range(1,13):
        file_path = file_name.format(year,month)
        wind_list.append(pd.read_csv(file_path,delim_whitespace=True, header=None))
wind_list
surf = pd.concat(wind_list, ignore_index=True )

# assigning colnames
column_names = ['区站号', 'lat', 'lon', '观测场拔海高度', 'year', 'month', 'day', '平均风速', '最大风速', '最大风速的风向',
                '极大风速', '极大风速的风向', '平均风速质量控制码', '最大风速质量控制码', '最大风速的风向质量控制码',
                '极大风速质量控制码', '极大风速的风向质量控制码']
surf.columns = column_names

id_lists = pd.read_excel("/Users/tli/Downloads/ecommerce/surf_数据说明/站点信息.xlsx")
# merge with id for city names matching with observed site's id
surf_city = surf.merge(id_lists[['区站号','省', '地市']], on='区站号', how='left')
surf_city.columns

# obtain daily median obs at city level
surf_median = surf_city.groupby(['省', '地市','year', 'month', 'day']).median().reset_index()
surf_median['地市'] = surf_median['地市'].str.replace('市', '', regex=True)
set(surf_median['地市'].unique())
surf_median['地市'].replace('伊犁哈萨克自治州', '伊犁', inplace=True)

# all cities in 99city is included in surf. 
set(gsod_quosoft_99['cityname'].unique()) - set(surf_median['地市'].unique())

# formating date
surf_median['date'] = pd.to_datetime(surf_median[['year', 'month', 'day']], format='%Y%m%d',errors='ignore')
surf_median = surf_median[surf_median['date'] <= 20191231]

# merge
surf_gsod_quosoft_99 = pd.merge(gsod_quosoft_99, surf_median, left_on=['cityname', 'date'], right_on= ['地市','date'],how='left')
surf_gsod_quosoft_99.to_csv('/Users/tli/Downloads/ecommerce/data/processed/5.final_surf_gsod_quosoft99.csv', index=False)

# end
