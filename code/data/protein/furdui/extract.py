import csv
import numpy as np
import pandas as pd
import scipy.stats.mstats

# load data
data = pd.read_table('data/combined.txt', index_col=0)

# get fold change
scc_illumina = {}
rscc_illumina = {}

for illumina in list(data.index):
	scc = np.mean([data['S.1.AVG_Signal'][illumina],data['S.2.AVG_Signal'][illumina],data['S.3.AVG_Signal'][illumina]])
	rscc = np.mean([data['R.1.AVG_Signal'][illumina],data['R.2.AVG_Signal'][illumina],data['R.3.AVG_Signal'][illumina]])
	cal27 = np.mean([data['cal27_1'][illumina],data['cal27_2'][illumina],data['cal27_3'][illumina]])

	scc_illumina[illumina] = 2**(scc-cal27)
	rscc_illumina[illumina] = 2**(rscc-cal27)

# convert from illumina to ncbi
d_ids = pd.read_table('ids.txt')
genes = d_ids['Gene ID'].tolist()

scc = []
rscc = []
for gene in genes:
	scc.append([])
	rscc.append([])

	illuminas = d_ids['Illumina ID'][d_ids['Gene ID'].tolist().index(gene)].split('; ')
	for illumina in illuminas:
		if illumina[:5] == 'ILMN_':
			illumina = illumina[:-9]

			if illumina in scc_illumina:
				scc[-1].append(scc_illumina[illumina])
				rscc[-1].append(rscc_illumina[illumina])

	if len(scc[-1]) > 0:
		scc[-1] = np.mean(scc[-1])
		rscc[-1] = np.mean(rscc[-1])
	else:
		scc[-1] = np.nan
		rscc[-1] = np.nan

# calculate expression values
d_cal27 = pd.read_csv('../proteomicsdb/samples/cal-27.csv')

with open('samples/scc-61.csv','w') as f_o:
	writer = csv.writer(f_o)
	writer.writerow(['GENE','PPM'])

	for i in range(len(genes)):
		writer.writerow([genes[i],d_cal27['PPM'][i]*scc[i]])

with open('samples/rscc-61.csv','w') as f_o:
	writer = csv.writer(f_o)
	writer.writerow(['GENE','PPM'])

	for i in range(len(genes)):
		writer.writerow([genes[i],d_cal27['PPM'][i]*rscc[i]])