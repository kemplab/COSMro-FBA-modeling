rm(list=ls())

# libraries
library(lumi)
library(sva)
library(MASS)
library(preprocessCore)

# load cal27 data
cal27 = read.table("data/cal27.txt", header=TRUE, row.names=1, sep='\t', as.is=TRUE)
cal27 = data.matrix(cal27)
illumina = row.names(cal27)

# load furdui data
furdui = read.table("data/furdui.txt", header=TRUE, row.names=1, sep='\t', as.is=TRUE)
furdui = subset(furdui, select=c('S.1.AVG_Signal','S.2.AVG_Signal','S.3.AVG_Signal','R.1.AVG_Signal','R.2.AVG_Signal','R.3.AVG_Signal'))
furdui = furdui[rownames(furdui) %in% illumina,]
furdui = data.matrix(furdui)

# log2 transform
furdui = log2(furdui)

# combine data sets
data = merge(furdui, cal27, by=0, all=TRUE)
rownames(data) = data$Row.names
data$Row.names = NULL
samples = colnames(data)
data = data.matrix(data)

# # quantile normalization
# data = normalize.quantiles(data)
# data = as.data.frame(data, row.names = illumina)
# colnames(data) = samples

# z-score normalization
data = scale(data)

write.table(data, file = "data/combined_before_combat.txt", sep = "\t", quote = FALSE, row.names = TRUE, col.names = TRUE)

# combat
batch = c(rep('Furdui',dim(furdui)[2]),rep('CAL27',dim(cal27)[2]))
data = ComBat(data, batch=batch)

# write data to file
write.table(data, file = "data/combined.txt", sep = "\t", quote = FALSE, row.names = TRUE, col.names = TRUE)