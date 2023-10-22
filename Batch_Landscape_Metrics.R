# ---- 0: Load Packages ----

  if (!requireNamespace("landscapemetrics", quietly = TRUE)) install.packages("landscapemetrics")
  if (!requireNamespace("raster", quietly = TRUE)) install.packages("raster")
  if (!requireNamespace("tidyverse", quietly = TRUE)) install.packages("tidyverse")
  
  library(landscapemetrics)
  library(raster)
  library(tidyverse)

# ---- 1: Load Landscapes & Verify Integrity ----

  # Point to your landscape directory
  ls_folder = file.choose()
  
  # Get list of files in the directory
  landscapes = list.files(path = ls_folder,
    pattern = "\\.tif$", full.names = TRUE)
  
  # Define function to check landscapes
  verify_landscape = function(file) {
    # Read in the raster file
    landscape = raster(file)
    
    # Run check_landscape
    result = check_landscape(landscape)
  }
  
  # Loop through files and check landscape
  lapply(landscapes, verify_landscape)
  
# ---- 2: Define Metrics & Cover Types of Interest ----
  
  # Choose your metrics of interest
  View(list_lsm())
  
  # List your metrics - this example highlights habitat fragmentation
  metrics = c('lsm_c_ca',         # Total Class Area
              'lsm_c_te',         # Total Edge
              'lsm_c_tca',        # Total Core Area
              'lsm_c_np',         # Number of Patches
              'lsm_c_clumpy',     # Clumpiness Index
              'lsm_c_cohesion',   # Patch Cohesion Index
              'lsm_c_contig_mn',  # Contiguity Index (Mean)
              'lsm_c_padj',       # Percent of Like Adjacencies
              'lsm_c_ed',         # Edge Density
              'lsm_c_ai',         # Aggregation Index
              'lsm_c_area_mn')    # Mean Patch Size 
  
  # Enter your cover type(s) of interest here
  CT = 7:14  
  
# ---- 3: Run Landscape Metrics on Folder ----
  
  # Initialize a list to store results
  lsm_results <- list()
  
  # Function to calculate landscape metrics and store results
  batch_lsm <- function(file) {
    # Read in the raster file
    landscape <- raster(file)
    
    # Run calculate_lsm
    result <- calculate_lsm(landscape, what = metrics)
    
    # Store the result with the file name as the list's name
    lsm_results[[basename(file)]] <- result
    
    # Print a message indicating completion for the current file
    cat("Metrics calculated for:", basename(file), "\n")
  }
  
  # Loop through files, calculate landscape metrics, and store results
  lapply(landscapes, batch_lsm)
  
# ---- 4: Write Metrics to CSV ----
  
  # Define a directory to save the results
  results_dir <- file.path(ls_folder, "Landscape_Metrics")
  
  # Create the directory if it does not exist
  if (!dir.exists(results_dir)) {
    dir.create(results_dir)
  }
  
  # Function to write results to CSV
  write_results <- function(metrics, name) {
    # Define the file path for the CSV file
    file_path <- file.path(results_dir, paste0(name, "_metrics.csv"))
    
    # Write to CSV
    write.csv(metrics, file_path)
    
    cat("Metrics for", name, "written to", file_path, "\n")
  }
  
  # Loop through results and write to CSV
  lapply(names(lsm_results), function(name) {
    write_results(lsm_results[[name]], gsub(".tif$", "", name))
  })
  
