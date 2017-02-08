#Nominatim library for geocoding

library("nominatim", lib.loc="/Library/Frameworks/R.framework/Versions/3.3/Resources/library")
library(dplyr)

partial_1 = read.csv('partial_1.csv')
partial_2 = read.csv('partial_2.csv')
complete = rbind(partial_1, partial_2)
complete = unique(complete)

#create new data frame that is only resteraunt name and address, much smaller

simplified = subset(complete, select=c('Res_name', 'Location'))
simplified = unique(simplified)

#make blank longitude and latitude columns

loc_vector <- c('longitude', 'latitude')
simplified[, loc_vector] <- NA

#rename rows in simplified dataset

rownames(simplified) <- seq(length=nrow(simplified))

#get longitude and latitude for each restaurant 

for(i in 1:nrow(simplified)){
  if(simplified[i, 2] != 'no phone number'){
    loc = osm_search(simplified[i,2], limit=1, key = 'rFdE0QXziBSrBuxQYWLLgiaWo45L8FjH')
    if(ncol(loc) > 1){
      simplified[i, 'longitude'] = loc[1, 'lon']
      simplified[i, 'latitude'] = loc[1, 'lat']
    }
  }
}

#use google maps for those not found by osm

for(i in 1:nrow(simplified)){
  if(simplified[i, 2] != 'no phone number'){
    if(is.na(simplified[i, 3])){
      print(simplified[i, 3])
      loc = geocode(as.character(simplified[i, 2]), output = "latlon" , source = "google")
      simplified[i, 'longitude'] = loc[1, 1]
      simplified[i, 'latitude'] = loc[1, 2]
      count = count + 1
      print(count)
      print(simplified[i, 1])
      print(simplified[i, 2])
      Sys.sleep(1)
    }
  }
}

#left join simplified back onto complete to add latitude and longitude

complete = left_join(complete, simplified, by = c('Res_name', 'Location'))
  

