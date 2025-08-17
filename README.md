# Rajasthan Healthcare Accessibility Analysis

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Python-3.9%2B-blue.svg)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13%2B-blue.svg)](https://www.postgresql.org/)

A comprehensive geospatial and demographic analysis of healthcare accessibility in Rajasthan, India. This project identifies critical gaps in healthcare infrastructure and provides data-driven recommendations to guide public policy and investment.

---

## 📌 Table of Contents
- [Project Overview](#-project-overview)
- [Problem Statement](#-problem-statement)
- [Key Features](#-key-features)
- [Methodology](#-methodology)
- [Key Insights & Visualizations](#-key-insights--visualizations)
- [Actionable Recommendations](#-actionable-recommendations)
- [Data Sources & Limitations](#-data-sources--limitations)
- [Extending Project Pan-India](#-extending-project-pan-india)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [How to Contribute](#-how-to-contribute)
- [Contact](#-contact)
- [License](#-license)

---

## 🌍 Project Overview

This project provides a multi-faceted analysis of the healthcare landscape in Rajasthan. By integrating and analyzing various datasets—including government health statistics, population data, and administrative boundaries—we created a detailed picture of healthcare accessibility across the state. The final output includes not just raw data, but a strategic report with actionable insights aimed at improving healthcare equity for millions of people.

---

## 🎯 Problem Statement

While state-level health metrics provide a useful overview, they often mask significant disparities at the local level. Remote and less-populated districts may face severe "healthcare deserts," where access to even basic medical facilities, especially emergency services, is critically limited. This project aims to answer the following questions:

- Which districts are most underserved in terms of healthcare facilities per capita?
- Where are the geographic "healthcare deserts" with low facility density and long travel distances?
- How does the availability of critical emergency services vary across the state?
- What data-driven strategies can be implemented to address these disparities effectively?

---

## ✨ Key Features

- **Multi-Layer Data Integration**: Combines demographic, geographic, and healthcare facility data for a holistic view.
- **Geospatial Analysis**: Utilizes hospital density and proximity analysis to identify geographically isolated areas.
- **Per-Capita Disparity Analysis**: Ranks districts based on hospital-to-population ratios to highlight underserved communities.
- **Emergency Services Audit**: Focused evaluation of the availability of critical 24/7 emergency facilities.
- **Interactive Visualizations**: Includes charts, maps, and dashboards to explore the data dynamically.
- Scalable framework for pan-India analysis.

---

## 🛠️ Methodology

The project's methodology is divided into two main components:

#### SQL & PostgreSQL/PostGIS
- **Data Cleaning**: Removal of duplicates and standardization of district names.
- **Spatial Queries**:
  - Calculating nearest hospital distances for district centroids.
  - Computing hospital density per district and per square kilometer.
  - Determining population-to-hospital ratios for accessibility analysis.
  - Analyzing proximity of hospitals to National and State Highways.
- **Categorization**: Classifying districts into access tiers: **Poor**, **Average**, and **Good**.

#### Python Analysis
- **Data Processing**: Using **Pandas** and **NumPy** for advanced tabular analysis and statistical calculations.
- **Visualizations**: Generating charts, heatmaps, and ratio plots with **Matplotlib**, **Seaborn**, and **Plotly**.
- **Mapping**: Creating interactive maps with **Geopandas** and **Folium** to visualize hospital locations, density, and emergency service coverage.

---

## 📊 Key Insights & Visualizations

- **Severe Hospital Distribution Imbalance**: **Jaipur** has over 900 hospitals, while districts like **Pratapgarh** and **Jaisalmer** have fewer than 30.
- **Critical Per-Capita Access Gaps**: **Chittaurgarh** is the most underserved district, with over **154,000 people per hospital**.
- **Identified "Healthcare Deserts"**: Vast geographic areas in **Jaisalmer** and **Bikaner** have a hospital density of less than **0.001 hospitals/km²**.
- **Alarming Emergency Services Shortage**: Multiple districts report having **zero 24/7 emergency facilities**, representing a significant public health risk.

**Visual Outputs Include**:
- Bar charts of per-capita hospital distribution.
- A choropleth map illustrating hospital density.
- An interactive map pinpointing facilities with and without emergency services.

---

## 🚀 Actionable Recommendations

1. **Dual Investment Strategy**:
    - **Population-based**: Build new hospitals in districts with poor access ratios (e.g., Chittaurgarh, Dhaulpur).
    - **Geography-based**: Establish a network of smaller clinics in low-density "healthcare deserts" (e.g., Jaisalmer, Bikaner).
2. **Emergency Services Enhancement**:
    - Launch a state-wide initiative to upgrade at least one hospital per district with full 24/7 emergency and trauma care capabilities.
3. **Geospatial Planning Dashboard**:
    - Develop an interactive dashboard for policymakers to visualize gaps and strategically optimize the locations for new healthcare facilities.
4. **Rural Healthcare Incentives**:
    - Create programs to encourage doctors, clinics, and medical staff to establish a presence in underserved and remote areas.

---

## 🌐 Extending Project Pan-India

This project was designed for scalability. To extend the analysis to other states or the entire country:
- **Replace Datasets**: Swap Rajasthan-specific data with corresponding national or state-level datasets.
- **Reusable Scripts**: The SQL queries and Python visualization scripts are modular and can be adapted to handle larger geographic extents with minimal changes.
- **Future Work**: This framework serves as a robust baseline for a nationwide healthcare accessibility analysis.

---

## 🛠️ Technology Stack

- **Database**: PostgreSQL with PostGIS Extension
- **Data Analysis**: Python, Pandas, NumPy, Geopandas, Shapely
- **Data Visualization**: Matplotlib, Seaborn, Plotly, Folium
- **GIS Software**: QGIS
- **Development Environment**: Jupyter Notebook, Google Colab

---

## 📁 Project Structure
raj_health_access_project/
│
├── 📂 python_script/         # Python/Colab notebooks for analysis
├── 📂 sql_queries/           # PostgreSQL/PostGIS scripts for data processing
├── 📂 table_outputs/         # CSV/text outputs from SQL queries
├── 📂 visual_output/         # Charts, graphs, maps from Python/QGIS
├── 📂 data/                  # Shapefiles, population data, hospital datasets
├── 📂 qgis_project/          # QGIS project files for cartography
├── 📄 README.md              # Project overview and instructions
└── 📄 conclusions_and_recommendations.md # Detailed final report

---

## 🚀 Getting Started

1.  **Clone the repository**: git clone https://github.com/LohitSharma333/Rajasthan_Hospital_Spatial_Analysis.git
2.  **Set up Database**: Install PostgreSQL and enable the PostGIS extension.
3.  **Import Data**: Use `psql` or a GUI tool like DBeaver to import the datasets from the `datafile/` directory into your database.
4.  **Run SQL Scripts**: Execute the scripts in the `sql_queries/` folder to clean, process, and analyze the data.
5.  **Run Python Notebooks**: Open the notebooks in `python_script/` to generate visualizations from the SQL outputs.
6.  **Explore Maps**: Open the `qgis_project/` file in QGIS to explore the detailed geospatial maps.

---

## 🤝 How to Contribute

Contributions are welcome! Please fork the repository, create a new feature branch, and open a pull request for review. Suggestions for new analysis, datasets, or visualizations are highly encouraged.

---

## 📄 Data Sources & Limitations

- **Hospital Data**: Sourced from OpenStreetMap and public government datasets.
- **Population Data**: Sourced from the Census of India.
- **Administrative Boundaries**: Sourced from official government shapefiles.

> **Disclaimer**: The analysis is based on the available datasets. It is possible that some private hospitals, clinics, or recently established facilities are not included. The numbers reflect the data used and should be considered a strong, representative sample rather than a complete real-world census.

---

## 📞 Contact

- **Lohit Sharma**
- **Email**: [lohitsharma333jpr@gmail.com](mailto:lohitsharma333jpr@gmail.com)
- **LinkedIn**: [linkedin.com/in/lohits](https://www.linkedin.com/in/lohits)

---

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
