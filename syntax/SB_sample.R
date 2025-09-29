library(tidyverse)
load("./data/tri_county_enverus.RData") # tricounty

dat <- tricounty %>% 
  filter(ENVWellStatus %in% c("PRODUCING","INACTIVE COMPLETED","INACTIVE INJECTOR","INACTIVE PRODUCER")) %>% 
  mutate(id = row_number()) %>% 
  dplyr::select(id, Longitude, Latitude) %>% 
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>% 
  st_transform(32610) %>% 
  st_buffer(320) %>% 
  st_transform(4326) %>% 
  mutate(centroid = st_centroid(geometry))
  

# residential buidings
res_CA <- read_csv("../seeds4/data/conus_xy.csv") %>% 
  filter(!is.na(blocklevellatitude)) %>% 
  filter(!is.na(blocklevellongitude)) %>% 
  dplyr::rename(code = landusecode,
                lat = blocklevellatitude,
                lon = blocklevellongitude) %>% 
  mutate(state = ifelse(str_detect(state, "CA"), "CA", state)) %>% 
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%  # project
  filter(state == "CA")


# identify residential housing (less than 300 sq meter)
bu <- res_CA %>% 
  dplyr::select(clip)

# Spatial join: assign polygon attributes to points that fall within
bu_joined <- st_join(bu, dat, join = st_within, left = F) %>% 
  distinct(clip , .keep_all = TRUE)

# Compute distance from each point to the centroid of its matched polygon
result <- bu_joined %>%
  rowwise() %>%
  mutate(dist = st_distance(geometry, centroid)) %>%
  ungroup() %>% 
  dplyr::select(clip,id,dist) %>% 
  st_drop_geometry()


coords <- st_coordinates(res_CA)
coords_df <- as.data.frame(coords)
res_CA$X <- coords_df$X
res_CA$Y <- coords_df$Y

SB <- result %>% 
  left_join(res_CA %>% 
              st_drop_geometry() %>% 
              dplyr::select(clip,X,Y), by = "clip") %>% 
  left_join(data1, by = "id")

write.csv(SB, "./derived/oil_sample_SB.csv")

