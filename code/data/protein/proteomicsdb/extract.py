import csv
import glob
import numpy as np
import pandas as pd
import scipy.stats.mstats

# # # # # GET PPM SAMPLE DATA # # # # #

for file in glob.glob('data/*.csv'):

	# sample name
	sample_name = file[5:-4]

	# sample data
	d = pd.read_csv(file)
	data_samples = {}

	# get data for each protein in each sample
	for i in range(d.shape[0]):
		if '-' in d['UNIQUE_IDENTIFIER'][i]:
			protein = d['UNIQUE_IDENTIFIER'][i].split('-')[0]
		else:
			protein = d['UNIQUE_IDENTIFIER'][i]

		if d['SAMPLE_NAME'][i] in data_samples:
			if protein in data_samples[d['SAMPLE_NAME'][i]]:
				data_samples[d['SAMPLE_NAME'][i]][protein] += 10**d['NORMALIZED_EXPRESSION'][i]
			else:
				data_samples[d['SAMPLE_NAME'][i]][protein] = 10**d['NORMALIZED_EXPRESSION'][i]
		else:
			data_samples[d['SAMPLE_NAME'][i]] = {}
			data_samples[d['SAMPLE_NAME'][i]][protein] = 10**d['NORMALIZED_EXPRESSION'][i]

	# convert to ppm based on sample total
	for sample in data_samples:
		total = 0
		for protein in data_samples[sample]:
			total += data_samples[sample][protein]

		for protein in data_samples[sample]:
			data_samples[sample][protein] = data_samples[sample][protein] / total * 1000000

	# take geometric mean of sample values
	data_uniprot = {}
	for sample in data_samples:
		for protein in data_samples[sample]:

			if protein in data_uniprot:
				data_uniprot[protein].append(data_samples[sample][protein])
			else:
				data_uniprot[protein] = [data_samples[sample][protein]]
	for protein in data_uniprot:
		data_uniprot[protein] = scipy.stats.mstats.gmean(data_uniprot[protein])

# # # # # CONVERT UNIPROT TO NCBI # # # # #

	d_ids = pd.read_table('ids.txt')
	genes = d_ids['Gene ID'].tolist()

	data_ncbi = []
	for gene in genes:
		found = 0

		uniprots = d_ids['UniProt Accession'][d_ids['Gene ID'].tolist().index(gene)].split('; ')
		for uniprot in uniprots:
			if uniprot in data_uniprot:
				found += 1

				if found > 1:
					print 'Multiple uniprots for sample %s - gene %s' % (sample,gene)
				else:
					data_ncbi.append(data_uniprot[uniprot])

		if found == 0:
			data_ncbi.append(np.nan)

# # # # # WRITE TO FILE # # # # #

	with open('samples/%s.csv' % (sample_name.lower().replace(', ','-').replace(',','-').replace(' ','-').replace('.','')),'w') as f_o:
		writer = csv.writer(f_o)
		writer.writerow(['GENE','PPM'])

		# each gene value
		for i in range(len(genes)):
			writer.writerow([genes[i],data_ncbi[i]])