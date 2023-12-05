#### TASK 1 ####
library(sf)
library(haven)
library(tidyverse)

### Extracting distance from sf_distance() ####
# loading settlement data: 
settlement <- read_dta("~/Downloads/excercise/market_masa_all_reg.dta")
names(settlement)
# converting dataframe into spatial dataframe, CRS 4362 represents a standard
# GPS coordinates, note that this also creates the centroids. 
settlement_sf <- st_as_sf(settlement, coords = c("lon", "lat"), crs = 4326) 

# loading road data:
road <- st_read("~/Downloads/excercise/roads_CHN_KZN_250_trackback.geojson")
new_roads <- road %>% 
  filter(np0919 == 1)

# calculating the distance to the roads:

nearest_road <- st_nearest_feature(settlement_sf, new_roads)

# trying to find the nears road thus we take the minimum distance
nearest_distance <- st_distance(x = settlement_sf, y = new_roads)
min_distance <- apply(nearest_distance, 1, min)

# as a matter of reference: 
# https://gis.stackexchange.com/questions/310489/calculating-euclidian-distance-in-r-between-lines-and-points

# adding the new variable back to the dta file: 
settlement <- settlement %>%
  mutate(nearest_feature_dis = nearest_distance, 
         qgis_dis = qgis_near_dis, min_dis_qgis = min_dis_qgis)

# ensuring the change has been made correctly 
names(settlement)
write_dta(settlement, "~/Downloads/excercise/market_masa_all_reg2.dta")

####comparing the result from R with QGis ####

# comparing the distance calculated from QGis by Toolbox
qgis_settlement <- read.csv("~/Downloads/excercise/nearest_line.csv")

# extract the coordinates for the nearest line, keeping the crs code the same
qgis_sf <- st_as_sf(qgis_settlement, coords = c("nearest_x", "nearest_y"), crs = 4326)

# extracting the distance: recalling that settlement sf is the coordinate of
# centroids, qgis_sf is the nearest railroads
qgis_near_dis <- st_distance(x = settlement_sf, y = qgis_sf)
min_dis_qgis <- apply(qgis_near_dis, 1, min)

# first converting both distance in same units
min_dis_qgis_num <- as.numeric(min_dis_qgis)
min_distance_num <- as.numeric(min_distance)

# checking is there a difference between R and QGIS's result by t-test:
test_result <- t.test(min_dis_qgis_num, min_distance_num, paired = TRUE)
test_result2 <- t.test(min_dis_qgis_num, min_distance_num,)
print(test_result)
print(test_result2)

# t >> p for both tests
# both rejected H0

# merging
file <- merge(settlement, qgis_settlement[, c("OBJECTID", "year","lon", "lat", "distance")]
              , by = c("OBJECTID", "year", "lon", "lat"), all.x = TRUE)
write_dta(file, "~/Downloads/excercise/market_masa_all_reg2.dta")
