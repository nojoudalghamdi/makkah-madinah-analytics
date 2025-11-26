# DO NOT EDIT - This installs required packages
required_packages <- c(
  "shiny", "shinythemes", "sf", "ggplot2", "dplyr", 
  "terra", "rnaturalearth", "plotly", "leaflet", 
  "readxl", "geodata", "DT", "survey"
)

for(pkg in required_packages) {
  if(!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}