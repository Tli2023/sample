# Question 1
# setting up
import pandas as pd # to convert the point file format
import geopandas as gpd # importing the packages and giving it a acronym
from shapely.geometry import Point, LineString #point class for centroids, Linesting for roads

# converting Dta into CSV: 
dta_path = "~/Downloads/excercise/market_masa_all_reg.dta" 
dta_points = pd.read_stata(dta_path)
dta_points.to_csv("~/Downloads/excercise/market_masa_all_reg.csv" )

# loading files for points and lines:
points_path = "/Users/tli/Downloads/excercise/market_masa_all_reg.csv"
points_df = pd.read_csv(points_path)
points = gpd.GeoDataFrame(points_df, 
                          crs= 4326, 
                          geometry=gpd.points_from_xy(points_df.lon, points_df.lat))
#geomentry information are stored under column geometry
#viewing the coordinates for centroids
points['geometry'].head()
print(type(points))
points['centroid'] = points.centroid


#roads 
roads_path = "~/Downloads/excercise/roads_CHN_KZN_250_trackback.geojson"
roads = gpd.read_file(roads_path, crs = 4326, driver = "geojson")

# checking CRS
roads.crs
points.crs

# Filtering
new_roads = roads[roads['np0919'] == 1]

print(new_roads.head(5))

# ensuring the crs is the same 
points = points.to_crs(new_roads.crs)

# calculating the distance for centroids to nearest road
#points['Distance']=points.distance(new_roads)

#calculating distance by creating a function: 
def calculate_distance(row, dest_geom, src_col='geometry', target_col='distance'):
    """
    Calculates the distance between Point geometries.

    Parameters
    ----------
    dest_geom : shapely.Point
       A single Shapely Point geometry to which the distances will be calculated to.
    src_col : str
       A name of the column that has the Shapely Point objects from where the distances will be calculated from.
    target_col : str
       A name of the target column where the result will be stored.

    Returns
    -------

    Distance in kilometers that will be stored in 'target_col'.
    """

    # Calculate the distances
    dist = row[src_col].distance(dest_geom)

    # Convert into kilometers
    dist_km = dist / 1000

    # Assign the distance to the original data
    row[target_col] = dist_km
    return row

# Retrieve the geometry from the centroids GeoDataFrame
points_geom = points.loc[0, 'geometry']
print(points_geom)


# Calculate the distances using our custom function called 'calculate_distance'
new_roads = new_roads.apply(calculate_distance, dest_geom=points_geom, src_col='geometry', target_col='dist_to_road', axis=1)
print(new_roads.head(10))