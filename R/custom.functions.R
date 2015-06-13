# Customized functions to use for data munging in R
# Author: Tim Essam
# Date: 2015/06


# Look for a variable based on name
# d - data frame on which to run grep
# p - search term
lkf <- function(d,p) names(d)[grep(p,names(d))]


#Graphical specifications for Uganda LSMS/RIGA analysis
g.spec1 <- theme(legend.position = "top", legend.title=element_blank(), 
                 panel.border = element_blank(), legend.key = element_blank(), 
                 legend.text = element_text(size = 14), #Customize legend
                 plot.title = element_text(hjust = 0, size = 17, face = "bold"), # Adjust plot title
                 panel.background = element_rect(fill = "white"), # Make background white 
                 panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #remove grid    
                 axis.text.y = element_text(hjust = -0.5, size = 14, colour = dgrayL), #soften axis text
                 axis.text.x = element_text(hjust = .5, size = 14, colour = dgrayL),
                 axis.ticks.y = element_blank(), # remove y-axis ticks
                 axis.title.y = element_text(colour = dgrayL),
                 #axis.ticks.x=element_blank(), # remove x-axis ticks
                 #plot.margin = unit(c(1,1,1,1), "cm"),
                 panel.margin = unit(0, "lines"),
                 plot.title = element_text(lineheight = 1 ), # 
                 panel.grid.major = element_blank(), # remove facet formatting
                 panel.grid.minor = element_blank(),
                 strip.background = element_blank(),
                 strip.text.x = element_text(size = 13, colour = dgrayL, face = "bold"), # format facet panel text
                 panel.border = element_rect(colour = "black"),
                 panel.margin = unit(2, "lines")) # Move plot title up