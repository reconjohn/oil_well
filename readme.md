# Residential Sampling Methodology

This document outlines the two-part sampling methodology used to create distinct datasets of residential properties for analysis. The process generates a large-scale national sample based on proximity to high-priority energy infrastructure and a separate, high-resolution regional sample focused on specific well types in California's Central Coast.

---

## 1. U.S. National Sample

This phase creates a broad sample of residential units across the United States located near potential energy development sites.

### Data Sources
* **Energy Site Locations**: The `top_decile_enverus.RData` file, which contains a pre-compiled dataset of high-priority well locations provided by Enverus.
* **Residential Points**: A national CSV file containing geolocated residential units with `X` and `Y` coordinates.
* **Census Data**: U.S. Census Tract shapefiles for data enrichment.

### Sampling Process & Criteria
1.  **Define Anchor Points**: The locations from the `top_decile_enverus.RData` dataset are used as the central points for the sampling process.
2.  **Expand Radius**: A circular buffer with a radius of **320 meters** is generated around each of these anchor points.
3.  **Select Residences**: Every residential unit from the national dataset that falls within any of these 320m buffer zones is selected for inclusion in the sample.

### Data Enrichment
* The `X` and `Y` coordinates of the selected residential units are used to perform a spatial join with U.S. Census Tract data, appending tract-level information to each residence.
* The precise distance (in meters) from each residential unit to its nearest Enverus well location is calculated and added as an attribute to the final dataset.

### Final Output
* A dataset containing approximately **172,000** residential units.
* Each record includes the unit's location, its associated Census Tract, and its distance to the nearest well.

---

## 2. Santa Barbara Regional Sample (Tri-County Area)

This phase creates a separate, more focused sample for Santa Barbara, San Luis Obispo, and Ventura counties, based on a specific list of local wells and their operational status.

### Data Sources
* **Regional Wells**: A dedicated data file containing well locations specifically for Santa Barbara, SLO, and Ventura counties.
* **Residential Points**: Geocoded residential units for the same tri-county region.

### Sampling Process & Criteria
1.  **Filter Wells by Status**: The regional well dataset is filtered to create a sample pool that exclusively includes wells with one of the following four statuses:
    * `INACTIVE COMPLETED`
    * `INACTIVE INJECTOR`
    * `INACTIVE PRODUCER`
    * `PRODUCING`
2.  **Select Residences**: A proximity-based selection is performed to identify all residential units located near the filtered set of wells.

### Final Output
* A focused dataset containing **2,632** residential units located within the Santa-Barbara-centered tri-county region.