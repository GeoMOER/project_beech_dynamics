dir = "D:/UniData/gis2/data_small/data_small/modis/tiles/c0001-0511_r0001-0522/modis_deseasoned"
tiffs = basename(list.files(path = dir, full.names = T))
subs = strsplit(tiffs, split = "\\.")
as.numeric(substring(subs[[2]][2], first = 6, last = 8))


dates = substr(basename(list.files(path = dir, full.names = T)), 10, 16)
l = substr(dates[substr(dates, 1, 4) == 2003], 5, 7)
l = as.numeric(l)

for(i in seq(1:length(l)-1)){
  print(l[i]:(l[i+1]-1))
  
}
l[length(l)]:nlayer(rst)


step_l = c()
for( i in 2:length(subs)-1) {
  #print(i)
  first = as.numeric(substring(subs[[i]][2], first = 6, last = 8))
  sec = as.numeric(substring(subs[[i+1]][2], first = 6, last = 8))
  steps = sec-first+1
  if(steps ==  -348){
    steps = 366-348
  }
  if(steps == -347){
    steps = 365-347
  }
  steps -> step_l[i]
  
}
step_l



l
for(i in 1:length(l)){
  print(i)
  if(i != length(l)){
    print(l[i], l[i+1])
  }
  else{
    print(l[i-1],l[i])
  }
}
