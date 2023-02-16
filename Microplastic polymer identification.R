#Load the library
library(OpenSpecy)
library(tidyverse)

get_lib()
spec_lib <- load_lib()

#Specify the path of your folder and read .txt files into a list

raman_list <- list.files("C:/Users/madhu/OneDrive/Documents/Peaks",pattern = "txt",
                         full.names = T, recursive = TRUE)

#Extract names of your .txt files

raman_list_names <- list.files("C:/Users/madhu/OneDrive/Documents/Peaks",pattern = "txt",
                               full.names = F, recursive = TRUE)
#read .txt files into R
mppeaks = lapply(raman_list, read.table)

#rename the files
names(mppeaks)<-raman_list_names

#Change the column and row names in each .txt files

colnames <- c("wavenumber","intensity")

mppeaks<-lapply(mppeaks, setNames, colnames)

#Correcting background noise  and smoothing

raman_adj <- lapply(mppeaks, adj_intens)
raman_proc <- lapply(raman_adj,smooth_intens)
raman_proc<-lapply(raman_proc,subtr_bg)

#function to cross refer peaks (.txt files)

mp_spec<-function(x){
  match_spec(x,library = spec_lib, which = "raman")
}

#Perform matching
match_list<-lapply(raman_proc, mp_spec)

#Top 6 suspected polymers
match_list_head<-lapply(match_list,head) 

####Visualization of Peaks

#Function to plot .txt files

plotdata_cor <- function(x){
  ggplot(data = x, aes(x=wavenumber, y=intensity, color="blue"))+
    geom_line(color="red",size=0.4)+ xlim(1000, 3500)+
    theme_classic()+
    xlab(expression(paste("Raman shift (", cm^-1,")")))+
    ylab("Intensity")+ theme(axis.title.x = element_text(size = 12),
                             axis.title.y = element_text(size = 12))
  
}


#Plot the .txt files
ggpeaks_cor<-lapply(mppeaks, plotdata_cor)


#Save the plots
lapply(names(ggpeaks_cor), 
       function(x)ggsave(filename=paste(x,".png",sep=""), 
                         plot=ggpeaks_cor[[x]],dpi=350,
                         width = 20, height = 15, units = "cm"))


