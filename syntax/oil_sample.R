source("./syntax/Function.R")

# original data
d <- enverus_county_total %>% 
  filter(env_well_status == "PRODUCING") %>% 
  mutate(id = row_number()) %>% 
  dplyr::rename(state = state_province)

data <- d %>% 
  dplyr::select(id, state, longitude, latitude) %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)


# states
st <- c("TX", "NM", "CA", "CO", "OK", "WY", "ND", "PA", "WV", "LA", "UT", "OH", "MT")
res_sample <- read_csv("../seeds4/data/conus_xy.csv") %>% 
  filter(!is.na(blocklevellatitude)) %>% 
  filter(!is.na(blocklevellongitude)) %>% 
  dplyr::rename(code = landusecode,
                lat = blocklevellatitude,
                lon = blocklevellongitude) %>% 
  mutate(state = ifelse(str_detect(state, "CA"), "CA", state)) %>% 
  st_as_sf(coords = c("lon", "lat"), crs = 4326) # project %>% 
  filter(state %in% st)

# loop
results = data.frame()
for(i in 1:length(st)){
  result <- st_join(res_sample %>% 
                      filter(state == st[i]) %>% 
                      dplyr::select(clip),  
                    data %>% 
                      filter(state == st[i]) %>% 
                      st_transform(32610) %>% 
                      st_buffer(320) %>% 
                      st_transform(4326) %>% 
                      mutate(centroid = st_centroid(geometry)), join = st_within, left = F) %>% 
    distinct(clip , .keep_all = TRUE) %>%
    rowwise() %>%
    mutate(dist = st_distance(geometry, centroid)) %>%
    ungroup() %>% 
    dplyr::select(clip,id,dist) %>% 
    st_drop_geometry()
  
  results <- result %>% 
    rbind(results)
  
}

coords <- st_coordinates(res_sample)
coords_df <- as.data.frame(coords)
res_sample$X <- coords_df$X
res_sample$Y <- coords_df$Y
results %>% 
  left_join(res_sample %>% 
              st_drop_geometry() %>% 
              dplyr::select(clip,X,Y), by = "clip") %>% 
  left_join(d, by = "id") %>% 
  write.csv("./derived/oil_sample.csv")

