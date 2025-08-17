-- ##############################################################
-- Rajasthan Healthcare Spatial Analysis - Final SQL Script
-- Project: Healthcare Accessibility and Facility Analysis in Rajasthan
-- Description:
-- Comprehensive spatial and demographic analysis of healthcare infrastructure in Rajasthan,
-- including data cleaning, facility counts, population ratios, spatial proximity to roads,
-- boundary-based analyses, accessibility measures, and service availability.
-- ##############################################################


-- ##############################################################
-- 0. Setup: Spatial Indexes and Geometry Transformations
-- ##############################################################

-- Create spatial indexes for performance on geometry columns
CREATE INDEX IF NOT EXISTS idx_hospital_geom ON raj_totalhospital USING GIST (wkb_geometry);
CREATE INDEX IF NOT EXISTS idx_road_geom ON raj_roads USING GIST (wkb_geometry);
CREATE INDEX IF NOT EXISTS idx_boundary_geom ON raj_boundary USING GIST (wkb_geometry);

-- Analyze tables to update statistics for query planner
ANALYZE raj_totalhospital;
ANALYZE raj_roads;
ANALYZE raj_boundary;

-- Transform geometries to projected coordinate system EPSG:32643 for distance calculations
ALTER TABLE raj_totalhospital
  ALTER COLUMN wkb_geometry TYPE geometry(POINT, 32643)
  USING ST_Transform(wkb_geometry, 32643);

ALTER TABLE raj_roads
  ALTER COLUMN wkb_geometry TYPE geometry(MULTILINESTRING, 32643)
  USING ST_Transform(wkb_geometry, 32643);

ALTER TABLE raj_boundary
  ALTER COLUMN wkb_geometry TYPE geometry(MULTIPOLYGON, 32643)
  USING ST_Transform(wkb_geometry, 32643);


-- ##############################################################
-- 1. Data Cleaning & Preparation
-- ##############################################################

-- 1.1 Remove exact duplicate hospital records (same name and district)
DELETE FROM raj_totalhospital a
USING raj_totalhospital b
WHERE a.ctid < b.ctid
  AND a.name = b.name
  AND a."addr:district" = b."addr:district";

-- 1.2 Standardize district names to Title Case for consistency
UPDATE raj_totalhospital
SET "addr:district" = INITCAP(TRIM("addr:district"));

-- 1.3 Set empty district names to NULL for cleaner data
UPDATE raj_totalhospital
SET "addr:district" = NULL
WHERE "addr:district" = '';

-- 1.4 Remove hospitals located outside Rajasthan boundary
DELETE FROM raj_totalhospital h
WHERE NOT EXISTS (
    SELECT 1
    FROM raj_boundary b
    WHERE ST_Within(h.wkb_geometry, b.wkb_geometry)
);


-- ##############################################################
-- 2. Basic Counts and Rankings
-- ##############################################################

-- 2.1 Total number of healthcare facilities in Rajasthan
SELECT COUNT(*) AS total_hospitals FROM raj_totalhospital;

-- 2.2 Facility type counts statewide
SELECT
  amenity AS facility_type,
  COUNT(*) AS facility_count
FROM raj_totalhospital
GROUP BY amenity
ORDER BY facility_count DESC;

-- 2.3 District-wise hospital/facility counts
SELECT b.name_2 AS district, COUNT(h.*) AS hospital_count
FROM raj_totalhospital h
JOIN raj_boundary b
  ON ST_Within(h.wkb_geometry, b.wkb_geometry)
GROUP BY b.name_2
ORDER BY hospital_count DESC;

-- 2.4 Top 5 districts with highest number of hospitals
SELECT 
    b.name_2 AS district,
    COUNT(h.*) AS hospital_count
FROM raj_totalhospital h
JOIN raj_boundary b
    ON ST_Within(h.wkb_geometry, b.wkb_geometry)
GROUP BY b.name_2
ORDER BY hospital_count DESC
LIMIT 5;

-- 2.5 Bottom 5 districts with lowest number of hospitals
SELECT 
    b.name_2 AS district,
    COUNT(h.*) AS hospital_count
FROM raj_totalhospital h
JOIN raj_boundary b
    ON ST_Within(h.wkb_geometry, b.wkb_geometry)
GROUP BY b.name_2
ORDER BY hospital_count ASC
LIMIT 5;


-- ##############################################################
-- 3. Population vs Healthcare Facilities
-- ##############################################################

-- 3.1 District-wise Hospitals & Population Ratio
SELECT 
    b.name_2 AS district,
    p.tot_p AS total_population,
    COUNT(h.*) AS hospital_count,
    ROUND((COUNT(h.*)::decimal / NULLIF(p.tot_p,0)) * 100000, 2) AS hospitals_per_lakh,
    ROUND(p.tot_p / NULLIF(COUNT(h.*),0), 2) AS people_per_hospital
FROM raj_population p
JOIN raj_boundary b
  ON p.distname = b.name_2
LEFT JOIN raj_totalhospital h
  ON ST_Within(h.wkb_geometry, b.wkb_geometry)
GROUP BY b.name_2, p.tot_p
ORDER BY hospitals_per_lakh DESC;

-- 3.2 Districts with population > 1 million but less than 10 hospitals
SELECT p.distname, p.tot_p, COUNT(h.*) AS hospital_count
FROM raj_population p
LEFT JOIN raj_totalhospital h
  ON p.distname = h."addr:district"
GROUP BY p.distname, p.tot_p
HAVING p.tot_p > 1000000 AND COUNT(h.*) < 10
ORDER BY hospital_count ASC;

-- 3.3 State-wide hospitals vs population ratio (per 100,000 population)
WITH pop AS (
  SELECT SUM(tot_p) AS total_population
  FROM raj_population
), hosp AS (
  SELECT COUNT(DISTINCT h.ogc_fid) AS total_hospitals
  FROM raj_totalhospital h
  JOIN raj_boundary b
    ON ST_Within(h.wkb_geometry, b.wkb_geometry)
)
SELECT 
  pop.total_population,
  hosp.total_hospitals,
  ROUND(hosp.total_hospitals::numeric / NULLIF(pop.total_population,0) * 100000, 2) AS hospitals_per_lakh
FROM pop CROSS JOIN hosp;


-- ##############################################################
-- 4. Spatial Accessibility relative to Roads
-- ##############################################################

-- 4.1 Hospitals within 10 km of National Highways (NH)
WITH cleaned_hospitals AS (
    SELECT DISTINCT ON (name, "addr:district")
           name,
           "addr:district",
           wkb_geometry
    FROM raj_totalhospital
    WHERE name IS NOT NULL
      AND "addr:district" IS NOT NULL
)
SELECT 
    h.name AS hospital_name,
    h."addr:district" AS district,
    r.roadname AS nearest_NH,
    ROUND(ST_Distance(h.wkb_geometry, r.wkb_geometry)::numeric, 2) AS distance_meters
FROM cleaned_hospitals h
JOIN LATERAL (
    SELECT r.roadname, r.wkb_geometry
    FROM raj_roads r
    WHERE r.roadcatego = 'NH'
      AND ST_DWithin(h.wkb_geometry, r.wkb_geometry, 5000)  -- 5 km
    ORDER BY ST_Distance(h.wkb_geometry, r.wkb_geometry)
    LIMIT 1
) r ON true
ORDER BY h."addr:district", h.name;

-- 4.2 Hospitals within 10 km of State Highways (SH)
WITH cleaned_hospitals AS (
    SELECT DISTINCT ON (name, "addr:district")
           name,
           "addr:district",
           wkb_geometry
    FROM raj_totalhospital
    WHERE name IS NOT NULL
      AND "addr:district" IS NOT NULL
)
SELECT 
    h.name AS hospital_name,
    h."addr:district" AS district,
    r.roadname AS nearest_SH,
    ROUND(ST_Distance(h.wkb_geometry, r.wkb_geometry)::numeric, 2) AS distance_meters
FROM cleaned_hospitals h
JOIN LATERAL (
    SELECT r.roadname, r.wkb_geometry
    FROM raj_roads r
    WHERE r.roadcatego = 'SH'
      AND ST_DWithin(h.wkb_geometry, r.wkb_geometry, 5000)  -- 5 km
    ORDER BY ST_Distance(h.wkb_geometry, r.wkb_geometry)
    LIMIT 1
) r ON true
ORDER BY h."addr:district", h.name;

-- 4.3 Count of hospitals near NH vs SH
WITH cleaned_hospitals AS (
    SELECT DISTINCT ON (name, "addr:district")
           name,
           "addr:district",
           wkb_geometry
    FROM raj_totalhospital
    WHERE name IS NOT NULL
      AND "addr:district" IS NOT NULL
)
SELECT r.roadcatego,
       COUNT(DISTINCT h.name) AS hospital_count
FROM cleaned_hospitals h
JOIN raj_roads r
  ON h.wkb_geometry && ST_Expand(r.wkb_geometry, 5000)
 AND ST_DWithin(h.wkb_geometry, r.wkb_geometry, 5000)
WHERE r.roadcatego IN ('NH','SH')
GROUP BY r.roadcatego
ORDER BY hospital_count DESC;

-- ##############################################################
-- 5. District Boundary Based Analysis
-- ##############################################################

-- 5.1 Hospitals within each district boundary
SELECT b.name_2 AS district, COUNT(h.*) AS hospital_count
FROM raj_boundary b
LEFT JOIN raj_totalhospital h
  ON ST_Within(h.wkb_geometry, b.wkb_geometry)
GROUP BY b.name_2
ORDER BY hospital_count DESC;

-- 5.2 Nearest hospital to each district centroid
SELECT 
    b.name_2 AS district, 
    h.name AS nearest_hospital,
    ROUND(
        (ST_Distance(
            ST_Centroid(b.wkb_geometry), 
            h.wkb_geometry
        ) / 1000)::numeric, 2
    ) AS distance_km
FROM raj_boundary b
JOIN LATERAL (
    SELECT h.name, h.wkb_geometry
    FROM raj_totalhospital h
    ORDER BY ST_Distance(ST_Centroid(b.wkb_geometry), h.wkb_geometry)
    LIMIT 1
) h ON true;

-- 5.3 Average distance of hospitals to National Highways and State Highways
WITH nearest AS (
  SELECT 
      h.name AS hospital,
      MIN(CASE WHEN r.roadcatego = 'NH' THEN ST_Distance(h.wkb_geometry, r.wkb_geometry) END) AS dist_to_NH,
      MIN(CASE WHEN r.roadcatego = 'SH' THEN ST_Distance(h.wkb_geometry, r.wkb_geometry) END) AS dist_to_SH
  FROM raj_totalhospital h
  JOIN raj_roads r
    ON ST_DWithin(h.wkb_geometry, r.wkb_geometry, 5000)
  GROUP BY h.name
)
SELECT 
    ROUND(AVG(dist_to_NH)::numeric / 1000, 2) AS avg_distance_to_NH_km,
    ROUND(AVG(dist_to_SH)::numeric / 1000, 2) AS avg_distance_to_SH_km
FROM nearest;
  
-- ##############################################################
-- 6. Rankings & Critical Insights
-- ##############################################################

-- 6.1 Districts ranked by hospital count
SELECT b.name_2 AS district,
       COUNT(h.*) AS hospital_count,
       RANK() OVER (ORDER BY COUNT(h.*) DESC) AS rank_by_hospitals
FROM raj_boundary b
LEFT JOIN raj_totalhospital h
  ON ST_Within(h.wkb_geometry, b.wkb_geometry)
GROUP BY b.name_2
ORDER BY rank_by_hospitals;

-- 6.2 Districts ranked by hospitals per 100,000 population
SELECT p.distname,
       ROUND((COUNT(h.*)::decimal / NULLIF(p.tot_p,0)) * 100000, 2) AS hospitals_per_lakh,
       RANK() OVER (ORDER BY (COUNT(h.*)::decimal / NULLIF(p.tot_p,0)) * 100000 DESC) AS rank_by_ratio
FROM raj_population p
LEFT JOIN raj_totalhospital h
  ON p.distname = h."addr:district"
GROUP BY p.distname, p.tot_p;

-- 6.3 Top 10 districts with highest population per hospital (most underserved)
SELECT p.distname, p.tot_p, COUNT(h.*) AS hospital_count,
       ROUND(p.tot_p / NULLIF(COUNT(h.*),0), 2) AS people_per_hospital
FROM raj_population p
LEFT JOIN raj_totalhospital h
  ON p.distname = h."addr:district"
GROUP BY p.distname, p.tot_p
ORDER BY people_per_hospital DESC NULLS LAST
LIMIT 10;


-- ##############################################################
-- 7. Advanced/Presentation Queries
-- ##############################################################

-- 7.1 Extract hospital coordinates (longitude, latitude) for heatmap visualization
SELECT name, "addr:district",
       ST_X(ST_Transform(wkb_geometry, 4326)) AS longitude,
       ST_Y(ST_Transform(wkb_geometry, 4326)) AS latitude
FROM raj_totalhospital;

-- 7.2 Hospital density per square kilometer by district (choropleth preparation)
SELECT 
    b.name_2 AS district,
    COUNT(h.*) AS hospital_count,
    ST_Area(b.wkb_geometry) / 1000000 AS district_area_sqkm,
    ROUND(
        (COUNT(h.*) / (ST_Area(b.wkb_geometry) / 1000000))::numeric,
        2
    ) AS hospitals_per_sqkm
FROM raj_boundary b
LEFT JOIN raj_totalhospital h
    ON ST_Within(h.wkb_geometry, b.wkb_geometry)
GROUP BY b.name_2, b.wkb_geometry
ORDER BY hospitals_per_sqkm DESC;

-- ##############################################################
-- 8. Service Availability & Facility Types
-- ##############################################################

-- 8.1 Facility type breakdown per district
SELECT
  "amenity",
  "addr:district",
  COUNT(*) AS facility_count
FROM raj_totalhospital
GROUP BY "amenity", "addr:district"
ORDER BY "addr:district", facility_count DESC;

-- 8.2 Facilities with emergency services by district
SELECT
  "addr:district",
  COUNT(*) FILTER (WHERE emergency ILIKE 'yes') AS emergency_facilities,
  COUNT(*) AS total_facilities,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE emergency ILIKE 'yes') / NULLIF(COUNT(*), 0),
    2
  ) AS percent_emergency
FROM raj_totalhospital
WHERE "addr:district" IS NOT NULL
GROUP BY "addr:district"
ORDER BY percent_emergency DESC;



-- ##############################################################
-- 9. People-to-Hospital Ratios Categorized by Access Level
-- ##############################################################

WITH district_ratio AS (
    SELECT 
        p.distname, 
        p.tot_p, 
        COUNT(h.*) AS hospital_count,
        ROUND(p.tot_p / NULLIF(COUNT(h.*), 0), 2) AS people_per_hospital
    FROM raj_population p
    LEFT JOIN raj_totalhospital h
      ON p.distname = h."addr:district"
    GROUP BY p.distname, p.tot_p
),
state_avg AS (
    SELECT AVG(people_per_hospital) AS avg_ratio
    FROM district_ratio
)
SELECT 
    d.distname,
    d.tot_p,
    d.hospital_count,
    d.people_per_hospital,
    CASE
        WHEN d.people_per_hospital <= s.avg_ratio * 0.8 THEN 'Good'
        WHEN d.people_per_hospital <= s.avg_ratio * 1.2 THEN 'Average'
        ELSE 'Poor'
    END AS access_level
FROM district_ratio d
CROSS JOIN state_avg s
ORDER BY d.people_per_hospital DESC;
