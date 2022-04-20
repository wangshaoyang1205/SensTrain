#setting parameters
set <- 2 #which set?




#loading libraries
library(tidyverse)
library(magrittr)
library(plotly)
library(xlsx)
library(ggplot2)
library(agricolae)
library(htmlwidgets)
library(flexdashboard)


#blinding codes
sample_code <- read.xlsx("analysis-export.xlsx", sheetIndex = 2) %>% 
  dplyr::select(`Name`, `Sample.Codes.As.Entered.By.Participants`)


#input data
data <- read.xlsx("analysis-export.xlsx", sheetIndex = 3)

#tidying data
data_1 <- data %>% dplyr::select(`Participant.Name`, `Sample.Name`, ends_with("AR"), ends_with("TX"), ends_with("FL"), ends_with("AT")) %>% 
  mutate(.after = `Sample.Name`, `Sample.Code` = case_when(
    `Sample.Name` == sample_code[1,1] ~ sample_code[1,2],
    `Sample.Name` == sample_code[2,1] ~ sample_code[2,2],
    `Sample.Name` == sample_code[3,1] ~ sample_code[3,2],
    `Sample.Name` == sample_code[4,1] ~ sample_code[4,2],
    `Sample.Name` == sample_code[5,1] ~ sample_code[5,2],
    `Sample.Name` == sample_code[6,1] ~ sample_code[6,2],
    `Sample.Name` == sample_code[7,1] ~ sample_code[7,2],
    `Sample.Name` == sample_code[8,1] ~ sample_code[8,2],
    `Sample.Name` == sample_code[9,1] ~ sample_code[9,2],
    `Sample.Name` == sample_code[10,1] ~ sample_code[10,2],
    `Sample.Name` == sample_code[11,1] ~ sample_code[11,2],
    `Sample.Name` == sample_code[12,1] ~ sample_code[12,2],
    `Sample.Name` == sample_code[13,1] ~ sample_code[13,2],
    `Sample.Name` == sample_code[14,1] ~ sample_code[14,2]))

#Set logics
  if(set == 1 && !("Day" %in% colnames(data))){
    data_2 <- data_1
  } else{
    if(set == 1 && ("Day" %in% colnames(data))){
      data_2 <- cbind(data_1, data["Day"]) %>% 
        filter(`Day` == 1)}
    else{data_2 <- cbind(data_1, data["Day"]) %>%
      filter(`Day` == set) %>% 
      select(!`Day`)
    }
  } 


#plotting
attributes <- as.vector(colnames(data_2)[4:length(data_2)])

plots <- list()
for (i in attributes) {
  mean <- data_2 %>% 
    group_by(`Sample.Code`) %>% 
    summarise(`Mean` = mean(get(colnames(data_2[i]))))
  
  plots[[i]] <- ggplotly(
    ggplot(data_2, mapping = aes(x = data_2[[i]], y = 0, fill = factor(Participant.Name))) +
      geom_point(size = 3, binpositions="all") + 
      geom_vline(data = mean, mapping = aes(xintercept = Mean)) + 
      coord_cartesian(xlim = c(0, 100), ylim = c(-1,1)) +
      scale_fill_brewer(palette = "Paired")+
      labs(y = "Sample", fill = "Panellist", x = colnames(data_2[i])) +
      facet_grid(rows = vars(Sample.Code), switch = "y") +
      theme(strip.text = element_text(face = "bold", size = 12),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank()),
    tooltip = "fill"
  )
  saveWidget(plots[[i]], paste(i, ".html", sep = ""), title = colnames(data_2[i]))
}






means.table.Tukey <- function (.formula, .variable, .group, .data, .alpha) 
{
  `*tmp*` <- merge(
    rownames_to_column(
      HSD.test(
        aov(.formula, .data), .group ,alpha = .alpha)[["means"]][, 1:2],
      var = .group),
    rownames_to_column(
      HSD.test(
        aov(.formula, .data), .group, alpha = .alpha)[["groups"]]["groups"],
      var = .group))
  `*tmp*` %>% 
    as_tibble(.)
  return(`*tmp*`)
}

means.table.Tukey(`aroma.intensity.AR` ~ Sample.Code, "aroma.intensity_AR", "Sample.Code", data.frame(data_2), 0.05) # Your measurement ~ Sample code, Data file, significance

