# Parent Script for First Farm Biodiversity Reports
# Authors: Daniel B. Turner, Jocelyn E. Behm, & Matthew R. Helmus
# Description - This script will complete the following tasks in sections:
#     1. Load data from farm biodiversity surveys
#         a. Data needed (two .csv files):  farmReport1_abunRich.csv
#                                           farmReport1_famPie.csv
#     2. Create objects or lists of some plots to be used in the reports
#     3. Run a "for loop" that will cycle through the datasets to create individualized biodiversity reports

# SECTION 1: Load data from farm biodiversity surveys.           --------------------------------------------------

# a. Load relevant R packages
library(RColorBrewer)
library(plyr)
library(rmarkdown)
library(knitr)
library(ggplot2)


# b. Load data files (these data are provided on GitHub as .csv files).

# set working directory to downloaded folder


farm_abunRich <- read.csv("data/farmReport1_abunRich.csv")
print(farm_abunRich) # Check to see if the dataframe is complete.
farm_abunRich$farmName <- factor(farm_abunRich$farmName, levels = farm_abunRich$farmName) # Make names a factor for ordering of columns in subsequent plots.

fam <- read.csv("data/farmReport1_famPie.csv")
print(fam) # Check to see if the dataframe is complete.

# SECTION 2: Create objects or lists of some plots to be used in the reports.           --------------------------------------------------

pie <- ggplot(data = fam, mapping = aes(x = "", y = prop, fill = family)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start = 0) +
  scale_fill_brewer(palette = "Set3") +
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid  = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(size=18),
        panel.background = element_blank(),
        legend.text = element_text(size=14),
        legend.title = element_text(size = 16),
        strip.text.x = element_text(size = 12.5)) +
  labs(fill = "Family of insect or spider") # These lines make an object with a pie chart of the predator families.


famPies <- plyr::dlply(fam, .(farmName), function(x) pie %+% x) # dlply here applies the object created above across all "farm names" and returns a list of all plots.

famPies[1] # Plot the first plot in the "famPies" list of pie charts.

nfarms <- nrow(farm_abunRich) # Create an object with the number of farms in the first data frame that will be used to index the for loop and name each .html output file.

# SECTION 3: Run a "for loop" that will cycle through the datasets to create individualized biodiversity reports.           --------------------------------------------------
i = 1

for (i in 1:(nfarms-3)) { # We subtract by three because we don't want to create .html docs for the category means.
  urbanCat <- farm_abunRich$urbanCat[i] # This object will be fed to the .Rmd file to display each farm's urbanization category.

  abun_bar_plot <- ggplot(farm_abunRich[c(i, (nfarms-2):nfarms),], aes(x = farmName, y = meanAbun)) +
    geom_bar(stat = "identity", aes(fill = farmName)) +
    labs(y = "Average number of beneficial predators\nfound in each trap",
         fill = "Your farm and other categories of farms") +
    theme_classic() +
    theme(axis.ticks.x = element_blank(),
          axis.text.x = element_blank(),
          axis.title.x = element_blank()) +
    scale_fill_brewer(palette = "Set2") # Create an object with the farm's predator abundance that will be called in the .rmd file.

  rich_bar_plot <- ggplot(farm_abunRich[c(i, (nfarms-2):nfarms),], aes(x = farmName, y = meanRich)) +
    geom_bar(stat = "identity", aes(fill = farmName)) +
    labs(y = "Average number of beneficial predator\ntypes found in each trap",
         fill = "Your farm and other categories of farms") +
    theme_classic() +
    theme(axis.ticks.x = element_blank(),
          axis.text.x = element_blank(),
          axis.title.x = element_blank()) +
    scale_fill_brewer(palette = "Set2") # Create an object with the farm's predator richness that will be called in .rmd file.

  real_pie_plot <- famPies[[i]] # Create an object with the farm's pie chart that will be called in .rmd file.

  render("analysis/farmerReports1_rmd.Rmd", output_file = paste0('userReports_caseStudy2/farmerReport1_example_', farm_abunRich$farmName[i], ".html"), "html_document") # This line actually executes each farm's .html report by calling the "child" .rmd file.
  # NOTE: The .rmd should be located in the same workspace directory as this R script.
  # ANOTHER NOTE: The .html files will be located in the same workspace directory as this R script.
}
