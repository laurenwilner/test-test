#----------------------------------------
# SETUP
library(tidyverse)
library(ggplot2)
#----------------------------------------
# DATA
data_dir <- "~/Desktop/Desktop/epidemiology_PhD/data/raw/"

#----------------------------------------
# DATA CLEAN

# noaa
details <- read.csv(paste0(data_dir,
    "noaa_storms/StormEvents_details-ftp_v1.0_d2023_c20240117.csv")) %>%
    rename_with(tolower) %>%
    filter(event_type == "Flood")
locs <- read.csv(paste0(data_dir,
    "noaa_storms/StormEvents_locations-ftp_v1.0_d2023_c20240117.csv")) %>%
    rename_with(tolower)
fatalities <- read.csv(paste0(data_dir,
    "noaa_storms/StormEvents_fatalities-ftp_v1.0_d2023_c20240117.csv")) %>%
    rename_with(tolower)

# The Great Vermont Flood of 10-11 July 2023
great_vt_flood <- details %>%
    filter(month_name == "July" &
    state == "VERMONT" &
    begin_day %in% c(10,11))
great_vt_ids <- unique(great_vt_flood$event_id)

fatalities_great_vt <- fatalities %>%
    filter(event_id %in% great_vt_ids) # no fatalities

# fema
assistance <- read_csv(paste0(data_dir,
    'fema/IndividualAssistanceHousingRegistrantsLargeDisasters.csv'))
    # floods are not in the assistance dataset unless associated with another disaster
disasters <- read_csv(paste0(data_dir,
    'fema/DisasterDeclarationsSummaries.csv'))
ihp <- read_csv(paste0(data_dir,
    'fema/IndividualsAndHouseholdsProgramValidRegistrations.csv')) %>%
    filter(incidentType == "Flood")
denials <- read_csv(paste0(data_dir,
    'fema/DeclarationDenials.csv'))
nfip <- read_csv(paste0(data_dir,
    'fema/FimaNfipClaims.csv'))
    # ficoNumber is the identifier for the flood
    # it is not the same as the disasterNumber

# The Great Vermont Flood of 10-11 July 2023
# ID: DR-4720-VT
great_vt_metadata <- disasters %>%
    filter(femaDeclarationString == "DR-4720-VT")
great_vt_ihp <- ihp %>%
    filter(disasterNumber == 4720)

#' EXPOSURE DATA
#'
#' NOAA dataset:
#' event ID, start and end, location (including lat long and fips),
#' event type, fatalities, injuries, flood cause (eg heavy rain)
#' damage, event narrative and description
#'
#' Disasters dataset:
#' disaster number, state, county, incident date, declaration date,
#' incident type,  ih/ia/pa/hm program declaration (0/1)
#'
#' IHP dataset:
#' disaster number, declaration date, county (not fips, need to look into this),
#' state, city, zip, applicant age, household composition, household income,
#' primary or secondary residence, rent/own, residence type,
#' homeowner insurance (0/1), flood insurance (0/1),
#' eligibility for various assistance types and amounts given,
#' other needs such as food and shelter, water level and high water loc in
#' house, types of damage to the home (eg roof, foundation, etc),
#'
#' NFIP dataset:
#' county, census tract, census block group, lat/long, state,
#' asOfDate, dateOfLoss, building characteristics, elevation of floors,
#' occupancy type, date of building construction, amounts paid on various
#' claims, total insurance coverage for building and contents,
#' rented/owned, whether it was in a flood zone, reasons for nonpayment,
#' type of flood event, fico number (flood identifier)
#'
#' SHELDUS: Pulls flood data from National Centers for Environmental Information
#' county, start and end date, event name, GLIDE ID, injuries, fatalities
#' NCEI contains highly detailed information about every storm/flood.
#'
#' Gaps/things to try to figure out:
#' Linking FICO number to disaster number
#' What NFIP dataset does/does not include vis a vis insurance (ex. does
#' it include private insurance?)
#' Can we access the NCEI raw data?
#'
#' OUTCOME DATA
#'
