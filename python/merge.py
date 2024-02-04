# keep 99 cities with air quality and wind direction data
import pandas as pd
from pypinyin import pinyin, lazy_pinyin, Style
quosoft = pd.read_csv('/Users/tli/Downloads/ecommerce/data/raw/long_quosoft_air_quality.csv')
city99 = pd.read_stata('/Users/tli/Downloads/ecommerce/data/raw/sample_daily16_17.dta')
gsod = pd.read_csv('/Users/tli/Downloads/ecommerce/data/processed/3.sodCityDaily.csv')

# first merge with quosoft:
# since we have only saved the long quosoft, we have to reshape it before merging 
identifiers = ['date', 'hour', 'type'] #by identifiers, reshape the df
short_df = pd.melt(quosoft, id_vars=identifiers, var_name='cityname', value_name='value')

# obtain year month date for quosoft to merge with city99
short_df['date'] = pd.to_datetime(short_df['date'], format='%Y%m%d')

short_df['year'] = short_df['date'].dt.year
short_df['month'] = short_df['date'].dt.month
short_df['day'] = short_df['date'].dt.day

short_df1617 = short_df[(short_df['year'] == 2016) | (short_df['year'] == 2017)]

## converting citynames: 
pinyincityname = []
for i in short_df1617['cityname']:
    result = pinyin(i, style=Style.TONE3)
    result_ = [j[0] for j in result]
    result2 = ''.join(result_)
    print(result2, i)
    pinyincityname.append(result2)
short_df1617['pinyinname']= pinyincityname
short_df1617['pinyinname'].head()

# save 
short_df1617.to_csv("/Users/tli/Downloads/ecommerce/data/processed/5.clean_quosoft.csv")
# first merge to filter 99 cities: 
quosoft99 = pd.merge(short_df1617, city99,on=['pinyinname','year','month','day'],how="inner")
quosoft99['pinyinname'].nunique() #91 cities left
quosoft99.to_csv('/Users/tli/Downloads/ecommerce/data/processed/5.merge_99quosoft.csv')

## now merge temperature etc data from gsod:
gsod.columns
gsod = gsod.rename(columns={"日期": "date", 'CITYNAME':'cityname'})
gsod
gsod['date'] = pd.to_datetime(gsod['date'], format='%Y-%m-%d')

gsod['year'] = gsod['date'].dt.year
gsod['month'] = gsod['date'].dt.month
gsod['day'] = gsod['date'].dt.day
gsod = gsod[(gsod['year'] == 2016) | (gsod['year'] == 2017)]

# obtain cityname: since gsod name cities differently from quosoft and city99
gsod['cityname'] = gsod['cityname'].str.replace('市', '')
gsod['cityname'] = gsod['cityname'].str.replace('地区', '')
gsod['cityname'] = gsod['cityname'].replace({
    "伊犁哈萨克自治州": "伊犁", "克孜勒苏柯尔克孜自治州": "克孜勒苏",
    "凉山彝族自治州": "凉山", "博尔塔拉蒙古自治州": "博尔塔拉",
    "大理白族自治州": "大理",  "巴音郭楞蒙古自治州": "巴音郭楞", "延边朝鲜族自治州": "延边",
    "德宏傣族景颇族自治州": "德宏", "恩施土家族苗族自治州": "恩施", "文山壮族苗族自治州": "文山",
    "昌吉回族自治州": "昌吉", "果洛藏族自治州": "果洛","楚雄彝族自治州": "楚雄",
    "海北藏族自治州": "海北", "海南藏族自治州": "海南",
    "海西蒙古族藏族自治州": "海西", "玉树藏族自治州": "玉树","甘南藏族自治州": "甘南",
    "甘孜藏族自治州": "甘孜", "红河哈尼族彝族自治州": "红河",
    "西双版纳傣族自治州": "西双版纳","迪庆藏族自治州": "迪庆",
    "阿坝藏族羌族自治州": "阿坝", "黄南藏族自治州": "黄南","黔东南苗族侗族自治州": "黔东南",
    "黔南布依族苗族自治州": "黔南", "黔西南布依族苗族自治州": "黔西南"
}, regex=True)

gsod_drop = ['平均露点.1','平均风速', '平均风速属性', '最大持续风速', '最大阵风'] # gsod_ave has taken 平均露点.1 twice, fixed code on 3.merge county_daily
gsod = gsod.drop(columns=gsod_drop)

gsod_quosoft_99= gsod.merge(quosoft99, on=['cityname','year','month','day','date'],how='inner')
gsod_quosoft_99['cityname'].nunique() #73 cities left.
set1 = set(quosoft99['cityname'].unique())
set2 = set(gsod['cityname'].unique())
set1 - set2 # cities in quosoft99 but not in gsod

### merge to include surf data
windir_201610 = pd.read_csv("/Users/tli/Downloads/ecommerce/surf_06风向风速/SURF_CLI_CHN_MUL_DAY-WIN-11002-201610.TXT", delim_whitespace=True, header=None)
windir_201611 = pd.read_csv("/Users/tli/Downloads/ecommerce/surf_06风向风速/SURF_CLI_CHN_MUL_DAY-WIN-11002-201611.TXT",delim_whitespace=True,header=None)
windir_201710 = pd.read_csv("/Users/tli/Downloads/ecommerce/surf_06风向风速/SURF_CLI_CHN_MUL_DAY-WIN-11002-201710.TXT",delim_whitespace=True,header=None)
windir_201711 = pd.read_csv("/Users/tli/Downloads/ecommerce/surf_06风向风速/SURF_CLI_CHN_MUL_DAY-WIN-11002-201711.TXT",delim_whitespace=True,header=None)
windir_201810 = pd.read_csv("/Users/tli/Downloads/ecommerce/surf_06风向风速/SURF_CLI_CHN_MUL_DAY-WIN-11002-201810.TXT",delim_whitespace=True,header=None)
windir_201811 = pd.read_csv("/Users/tli/Downloads/ecommerce/surf_06风向风速/SURF_CLI_CHN_MUL_DAY-WIN-11002-201811.TXT",delim_whitespace=True,header=None)
windir_201910 = pd.read_csv("/Users/tli/Downloads/ecommerce/surf_06风向风速/SURF_CLI_CHN_MUL_DAY-WIN-11002-201910.TXT",delim_whitespace=True,header=None)
windir_201911 = pd.read_csv("/Users/tli/Downloads/ecommerce/surf_06风向风速/SURF_CLI_CHN_MUL_DAY-WIN-11002-201911.TXT",delim_whitespace=True,header=None)

# List of DataFrames to concatenate
df = [windir_201610, windir_201611, windir_201710, windir_201711, windir_201810, windir_201811, windir_201910, windir_201911]

# Concatenate DataFrames
windir_all = pd.concat(df, ignore_index=True)
column_names = ['区站号', 'lat', 'lon', '观测场拔海高度', 'year', 'month', 'day', '平均风速', '最大风速', '最大风速的风向',
                '极大风速', '极大风速的风向', '平均风速质量控制码', '最大风速质量控制码', '最大风速的风向质量控制码',
                '极大风速质量控制码', '极大风速的风向质量控制码']
windir_all.columns = column_names
id_lists = pd.read_excel("/Users/tli/Downloads/ecommerce/surf_数据说明/站点信息.xlsx")
# merge with id for city names matching with observed site's id
winddir_plus_citynames = windir_all.merge(id_lists[['区站号','省', '地市']], on='区站号', how='left')
winddir_plus_citynames.columns

# compute the daily ave for wind data
winddir_filtered = winddir_plus_citynames.groupby(['省', '地市','year', 'month', 'day']).median().reset_index()
winddir_filtered.drop_duplicates() # keep the unique samples

winddir_filtered['地市'] = winddir_filtered['地市'].str.replace('市', '', regex=True)
winddir_filtered['地市'] = winddir_filtered['地市'].str.replace('地区', '', regex=True)
winddir_plus_citynames['地市'] = winddir_plus_citynames['地市'].replace({
    "伊犁哈萨克自治州": "伊犁", "克孜勒苏柯尔克孜自治州": "克孜勒苏",  "凉山彝族自治州": "凉山",
    "博尔塔拉蒙古自治州": "博尔塔拉", "大理白族自治州": "大理",
    "巴音郭楞蒙古自治州": "巴音郭楞",    "延边朝鲜族自治州": "延边",
    "德宏傣族景颇族自治州": "德宏",    "恩施土家族苗族自治州": "恩施",
    "文山壮族苗族自治州": "文山",    "昌吉回族自治州": "昌吉",
    "果洛藏族自治州": "果洛",    "楚雄彝族自治州": "楚雄",
    "海北藏族自治州": "海北",    "海南藏族自治州": "海南",
    "海西蒙古族藏族自治州": "海西",    "玉树藏族自治州": "玉树",
    "甘南藏族自治州": "甘南",    "甘孜藏族自治州": "甘孜",
    "红河哈尼族彝族自治州": "红河",    "西双版纳傣族自治州": "西双版纳",
    "迪庆藏族自治州": "迪庆",    "阿坝藏族羌族自治州": "阿坝",
    "黄南藏族自治州": "黄南",    "黔东南苗族侗族自治州": "黔东南",
    "黔南布依族苗族自治州": "黔南",    "黔西南布依族苗族自治州": "黔西南"
}, regex=True)

## data type coherent to merge with 99city_gsod_quosoft
winddir_filtered['year'] = winddir_filtered['year'].astype(int)
winddir_filtered['month'] = winddir_filtered['month'].astype(int)
winddir_filtered.rename(columns={'地市': 'cityname'}, inplace=True)

windcolumnsdrop = ['省','区站号']
winddir_filtered = winddir_filtered.drop(columns=windcolumnsdrop)

# merge:
surf_gsod_quosoft_99 = winddir_filtered.merge(gsod_quosoft_99, on=['cityname','year','month','day'],how='inner')
surf_gsod_quosoft_99
surf_gsod_quosoft_99.to_csv('/Users/tli/Downloads/ecommerce/data/processed/5.merge_py_73city.csv')