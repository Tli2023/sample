# objective: joining 214 cities with the new polygons to keep the certain cities:
import pandas as pd
import geopandas as gpd

## appending: 
dfs = []
# a simple code to loop the year: 
for year in [2016, 2017, 2018, 2019, 2020, 2021]:
    # Construct the file path for each year
    filepath = f"/Users/tli/Downloads/{year}GSOD.csv"
    dfs.append(pd.read_csv(filepath))

gsod = pd.concat(dfs, ignore_index=True)

gsod['ctry_filter'] = gsod['气象站名称'].str.split(',').str[1].str.strip()
gsod['ctry_filter'].head()
gsod = gsod[gsod['ctry_filter']=='CH']

gsod.to_csv("/Users/tli/Downloads/ecommerce/gsod.csv")

# now merge gsod with the local level info:
gsod = pd.read_csv("/Users/tli/Downloads/ecommerce/gsod.csv")
glocal = gpd.read_file("/Users/tli/Downloads/ecommerce/区县级/区县界_region.shp", encoding="GBK")
g939 = gpd.read_file("/Users/tli/Downloads/ecommerce/urban939/Urban939.shp")

gsod_g = gpd.GeoDataFrame(gsod, crs="EPSG:4326", geometry=gpd.points_from_xy(gsod.经度, gsod.纬度))

gsod_city = gpd.sjoin(gsod_g,g939, how='inner')
gsod_city.to_csv("/Users/tli/Downloads/gsod_city.csv", index=False)

gsod_local = gpd.sjoin(gsod_g,glocal,how="inner")
gsod_local.nunique()
gsod_local.head()

# now obtain the 214 unique cities: 
## first, obtain 214 cities and their lat and lon: ##
chid = pd.read_excel("/Users/tli/Downloads/1000241.xlsx")
unique_200 = pd.read_csv("/Users/tli/Downloads/site_unique_cn.csv")

# first get the unique lon lat from chid by merging with cities and id:
list(chid.columns)
list(unique_200)

# renaming for merge:
chid = chid.rename(columns={"区站号":"id", "站名":"cityname", "纬度":"LAT", "经度":"LON"})

# isd stored station id with 6 digits:
chid['id'] = chid['id'] * 10
chid['id'].head()
unique_200 = unique_200.drop(columns=["LON", "LAT"])
ch_unique = unique_200.merge(chid, on=["id", "cityname"],how="inner")
len(ch_unique)

gch = gpd.GeoDataFrame(ch_unique, crs='4326', geometry=gpd.points_from_xy(ch_unique.LAT, ch_unique.LON))
gch_local = gpd.sjoin(gch, glocal, how='inner')

gch_local = gch_local.drop(columns = ['index_right'])
gch_local.nunique()

gsod_city = gsod_city.drop(columns = ['index_right'])

gsod_local = gsod_local.drop(columns = ['index_right'])

# merge:
# method 1: both merged with local shp:
gsod_214 = gpd.sjoin(gsod_local, gch_local, how='inner')
gsod_214.head()

#method 2: merge gch_local with gsod: from points to surface: we only keep the filered city 
sodCity = gsod_g.sjoin(glocal, how="inner")
sodCity.nunique()
sodCity.columns

# san check: 
gsod_city = gpd.sjoin(gsod_g,g939,how = "inner")
gsod_city['CITYNAME'].unique()
gsod_city['CITYNAME'].nunique() #188 cities 

# other methods to join: 
# join attribute by location in Qgis => within join > 


# now merge gsod with the local level info:
gsod_g = gpd.GeoDataFrame(gsod, crs="EPSG:4326", geometry=gpd.points_from_xy(gsod.经度, gsod.纬度))
# gsod_g.crs

###########################################

#here we have merged gsod with the provintial level data: 
sodCity = gsod_g.sjoin(glocal, how="inner")

sodCity.columns
sodCity.head()
type(sodCity)
# for ave. in groupby to check: 
sodCity[['平均气温', '平均露点', '平均气温属性', '平均露点', '平均露点属性', '平均海平面压强', '平均海平面压强属性',
          '平均观测站压强', '平均观测站压强属性', '平均能见度', '平均能见度属性', '平均风速', '平均风速属性',
          '最大持续风速', '最大阵风', '最高气温', '最高气温属性', '最低气温', '最低气温属性', '降水量',
          '降水量属性', '积雪深度']].dtypes
sodCity['降水量属性'].head()
sodCity['最低气温属性'].head()
sodCity['最高气温属性'].head()

sodCityDaily = sodCity.groupby(["CITYNAME", "日期"])[['平均气温','平均露点','平均气温属性', '平均露点', 
                                                    '平均露点属性', '平均海平面压强', '平均海平面压强属性', 
                                                    '平均观测站压强','平均观测站压强属性', '平均能见度', '平均能见度属性', 
                                                    '平均风速', '平均风速属性', '最大持续风速', '最大阵风','最高气温',
                                                    '最低气温', '降水量', '积雪深度',]].mean()
sodCityDaily.head()
# export
sodCityDaily.to_csv("/Users/tli/Downloads/ecommerce/sodCityDaily.csv")