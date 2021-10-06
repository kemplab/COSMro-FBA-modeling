from bs4 import BeautifulSoup
import csv
import glob
import math
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import pickle
from scipy import stats
import statsmodels
import statsmodels.api as sm
import statsmodels.formula.api as smf
import statsmodels.stats.api as sms
import urllib

# # # # # EXTRACT DATA # # # # # # # # # # # # # # # # # # # # # # # # # 

# os.chdir('html')

# tissues = ['Monocyte','Neutrophil','B-lymphocyte','T-lymphocyte','CD4 T cells','CD8 T cells','NK cells','Periph. blood mononuclear cells','Lymph node','Tonsil','Bone marrow stromal cell','Bone marrow mesench. stem cell','Brain','Frontal cortex','Cerebral cortex','Spinal cord','Retina','Heart','Bone','Colon muscle','Oral epithelium','Nasopharynx','Nasal respiratory epithelium','Esophagus','Stomach','Cardia','Colon','Rectum','Liver','Kidney','Spleen','Lung','Adipocyte','Salivary gland','Thyroid','Adrenal','Breast','Pancreas','Islet of Langerhans','Gallbladder','Prostate','Urinary bladder','Skin','Hair follicle','Placenta','Uterus','Cervix','Ovary','Testis','Seminal Vesicle']
# cells = ['T-cell leukemia, Jurkat','Myeloid leukemia, K562','Lymphoblastic leukemia, CCRF-CEM','Brain cancer, U251','Brain cancer, GAMG','Bone cancer, U2OS','Kidney, HEK293','Liver cancer, HuH-7','Liver cancer, HepG2','NSC lung cancer, NCI-H460','Lung cancer, A549','Kidney cancer, RXF393','Colon cancer, RKO','Colon cancer, Colo205','Melanoma, M14','Breast cancer, LCC2','Breast cancer, MCF7','Pancreas cancer','Ovarian cancer, SKOV3','Prostate cancer, LnCap','Prostate cancer, PC3','Cervical cancer, HeLa S3','Cervical cancer, HeLa']

# proteins = []
# for file in glob.glob('*.html'):
# 	proteins.append(file.split(' ')[0])

# d_tissues = pd.DataFrame(index=proteins, columns=tissues)
# d_cells = pd.DataFrame(index=proteins, columns=cells)

# for file in glob.glob('*.html'):
# 	protein = file.split(' ')[0]
# 	print protein
	
# 	soup = BeautifulSoup(urllib.urlopen(file).read(),'lxml')
	
# 	# tissues
# 	m1 = soup.find('map', attrs={'name':'tissues_map_prot_%s' % protein})
# 	if m1 != None:
# 		for m2 in m1.children:
# 			if (m2['title'] != '92 tissues & compartments') and ('No Data' not in m2['title']):
# 				value = float(m2['title'].split(', ')[0])
# 				tissue = m2['title'].split(', ')[1]

# 				if (value != 0) and (tissue in tissues):
# 					d_tissues[tissue][protein] = value

# 	# cells
# 	m1 = soup.find('map', attrs={'name':'tissues_map_prot_%s_GCs' % protein})
# 	if m1 != None:
# 		for m2 in m1.children:
# 			if (m2['title'] != '92 tissues & compartments') and ('No Data' not in m2['title']):
# 				value = float(m2['title'].split(', ')[0])
# 				if len(m2['title'].split(', ')) == 4:
# 					cell = m2['title'].split(', ')[1] + ', ' + m2['title'].split(', ')[2]
# 				else:
# 					cell = m2['title'].split(', ')[1]

# 				if (value != 0) and (cell in cells):
# 					d_cells[cell][protein] = value

# os.chdir('..')

# # # # # CLEAN DATA # # # # # # # # # # # # # # # # # # # # # # # # # 

# # remove tissues without any expression data
# to_delete = []
# for tissue in tissues:
# 	if sum(np.isnan(d_tissues[tissue].tolist())) == len(d_tissues[tissue].tolist()):
# 		to_delete.append(tissue)
# for tissue in reversed(to_delete):
# 	d_tissues.drop(tissue,axis=1,inplace=True)
# 	del tissues[tissues.index(tissue)]

# # remove cells without any expression data
# to_delete = []
# for cell in cells:
# 	if sum(np.isnan(d_cells[cell].tolist())) == len(d_cells[cell].tolist()):
# 		to_delete.append(cell)
# for cell in reversed(to_delete):
# 	d_cells.drop(cell,axis=1,inplace=True)
# 	del cells[cells.index(cell)]

# # convert ppm to mmol/gDW
# # 100 Dalton/amino acid
# # 300 amino acids/protein
# # 1.66054e-24 grams/Dalton
# # 50% of gDW is protein
# proteins_per_gDW = 1./(100*300*(1.66054e-24))/2

# # ppm: divide by 1,000,000
# # molecules to moles: divide by N_a
# # moles to mmoles: multiple by 1000
# conversion_factor = proteins_per_gDW/1000000/(6.0221409e23)*1000

# d_tissues = d_tissues.multiply(conversion_factor)
# d_cells = d_cells.multiply(conversion_factor)

# pickle.dump([d_tissues,d_cells],open('data_protein.p','wb'))

[d_tissues,d_cells] = pickle.load(open('data_protein.p','rb'))

tissues = list(d_tissues.columns.values)
cells = list(d_cells.columns.values)
proteins = list(d_tissues.index)

# # # # # EXPORT DATA # # # # # # # # # # # # # # # # # # # # # # # # # 

d = pd.read_table('ids.txt')

# with open('protein_tissues.csv','w') as f_o:
# 	writer = csv.writer(f_o)

# 	writer.writerow(['gene']+tissues)
# 	for protein in proteins:
# 		gene_id = d['Gene ID'][d['Gene Symbol'].tolist().index(protein)]
# 		writer.writerow([gene_id]+list(d_tissues.loc[protein]))

# with open('protein_cells.csv','w') as f_o:
# 	writer = csv.writer(f_o)

# 	writer.writerow(['gene']+cells)
# 	for protein in proteins:
# 		gene_id = d['Gene ID'][d['Gene Symbol'].tolist().index(protein)]
# 		writer.writerow([gene_id]+list(d_cells.loc[protein]))

# # # # # CROSS-TISSUE CORRELATION - TISSUES # # # # # # # # # # # # # # # # # # # # # # # # # 

# print 'Coverage without correlation: ', float(d_tissues.shape[0] * d_tissues.shape[1] - sum(list(d_tissues.isnull().sum())))/(d_tissues.shape[0] * d_tissues.shape[1])

# r_tissues = pd.DataFrame(index=tissues, columns=tissues)
# for i in range(len(tissues)):
# 	for j in range(len(tissues)):
# 		print 'A',i,j
# 		data1 = [math.log(x) for k,x in enumerate(d_tissues[tissues[i]].tolist()) if (~np.isnan(d_tissues[tissues[i]].tolist()[k]) and ~np.isnan(d_tissues[tissues[j]].tolist()[k]))]
# 		data2 = [math.log(x) for k,x in enumerate(d_tissues[tissues[j]].tolist()) if (~np.isnan(d_tissues[tissues[i]].tolist()[k]) and ~np.isnan(d_tissues[tissues[j]].tolist()[k]))]
		
# 		# correlation coefficient
# 		r_tissues[tissues[j]][tissues[i]] = np.corrcoef(np.vstack((data1,data2)))[1,0]

# pickle.dump(r_tissues,open('correlation_tissues.p','wb'))
# r_tisses = pickle.load(open('correlation_tissues.p','rb'))
# r_tissues.to_csv(open('correlation_tissues.csv','wb'))

# # use other tissue data to fill in gaps
# for i in range(len(tissues)):
# 	corr = r_tissues[tissues[i]].tolist()
# 	corr_index = sorted(range(len(corr)), key=lambda k: -corr[k])
	
# 	for j in range(len(tissues)):
# 		print 'B',i,j
# 		if (corr_index[j] != i) and (corr[corr_index[j]] > 0):

# 			data1 = [math.log(x) for k,x in enumerate(d_tissues[tissues[i]].tolist()) if (~np.isnan(d_tissues[tissues[i]].tolist()[k]) and ~np.isnan(d_tissues[tissues[corr_index[j]]].tolist()[k]))]
# 			data2 = [math.log(x) for k,x in enumerate(d_tissues[tissues[corr_index[j]]].tolist()) if (~np.isnan(d_tissues[tissues[i]].tolist()[k]) and ~np.isnan(d_tissues[tissues[corr_index[j]]].tolist()[k]))]

# 			slope, intercept, r_value, p_value, std_err = stats.linregress(data1,data2)

# 			data2_ = [math.log(x) for k,x in enumerate(d_tissues[tissues[corr_index[j]]].tolist()) if (np.isnan(d_tissues[tissues[i]].tolist()[k]) and ~np.isnan(d_tissues[tissues[corr_index[j]]].tolist()[k]))]
# 			data2_index = [k for k,x in enumerate(d_tissues[tissues[corr_index[j]]].tolist()) if (np.isnan(d_tissues[tissues[i]].tolist()[k]) and ~np.isnan(d_tissues[tissues[corr_index[j]]].tolist()[k]))]

# 			for k in range(len(data2_)):
# 				d_tissues[tissues[i]][proteins[data2_index[k]]] = math.exp(slope*data2_[k]+intercept)

# # export data
# with open('protein_tissues_correlation.csv','w') as f_o:
# 	writer = csv.writer(f_o)

# 	writer.writerow(['gene']+tissues)
# 	for protein in proteins:
# 		gene_id = d['Gene ID'][d['Gene Symbol'].tolist().index(protein)]
# 		writer.writerow([gene_id]+list(d_tissues.loc[protein]))

# print 'Coverage with correlation: ', float(d_tissues.shape[0] * d_tissues.shape[1] - sum(list(d_tissues.isnull().sum())))/(d_tissues.shape[0] * d_tissues.shape[1])

# # # # # CROSS-TISSUE CORRELATION - CELLS # # # # # # # # # # # # # # # # # # # # # # # # # 

# print 'Coverage without correlation: ', float(d_cells.shape[0] * d_cells.shape[1] - sum(list(d_cells.isnull().sum())))/(d_cells.shape[0] * d_cells.shape[1])

# r_cells = pd.DataFrame(index=cells, columns=cells)
# for i in range(len(cells)):
# 	for j in range(len(cells)):
# 		print 'C',i,j
# 		data1 = [x for k,x in enumerate(d_cells[cells[i]].tolist()) if (~np.isnan(d_cells[cells[i]].tolist()[k]) and ~np.isnan(d_cells[cells[j]].tolist()[k]))]
# 		data2 = [x for k,x in enumerate(d_cells[cells[j]].tolist()) if (~np.isnan(d_cells[cells[i]].tolist()[k]) and ~np.isnan(d_cells[cells[j]].tolist()[k]))]
		
# 		# cook's distance
# 		(c,p) = sm.OLS(data2,data1).fit().get_influence().cooks_distance

# 		# remove data with too large cook's distance
# 		if ~np.isnan(max(c)):
# 			to_delete = []
# 			for k in range(len(c)):
# 				if c[k] > np.mean(c)+5*np.std(c):
# 					to_delete.append(k)
# 			for k in reversed(to_delete):
# 				del data1[k]
# 				del data2[k]

# 		# correlation coefficient
# 		r_cells[cells[j]][cells[i]] = np.corrcoef(np.vstack((data1,data2)))[1,0]

# pickle.dump(r_cells,open('correlation_cells.p','wb'))
# r_cells = pickle.load(open('correlation_cells.p','rb'))
# r_cells.to_csv(open('correlation_cells.csv','wb'))

# # use other cell data to fill in gaps
# for i in range(len(cells)):
# 	corr = r_cells[cells[i]].tolist()
# 	corr_index = sorted(range(len(corr)), key=lambda k: -corr[k])
	
# 	for j in range(len(cells)):
# 		print 'D',i,j
# 		if (corr_index[j] != i) and (corr[corr_index[j]] > 0):

# 			data1 = [x for k,x in enumerate(d_cells[cells[i]].tolist()) if (~np.isnan(d_cells[cells[i]].tolist()[k]) and ~np.isnan(d_cells[cells[corr_index[j]]].tolist()[k]))]
# 			data2 = [x for k,x in enumerate(d_cells[cells[corr_index[j]]].tolist()) if (~np.isnan(d_cells[cells[i]].tolist()[k]) and ~np.isnan(d_cells[cells[corr_index[j]]].tolist()[k]))]

# 			slope, intercept, r_value, p_value, std_err = stats.linregress(data1,data2)

# 			data2_ = [x for k,x in enumerate(d_cells[cells[corr_index[j]]].tolist()) if (np.isnan(d_cells[cells[i]].tolist()[k]) and ~np.isnan(d_cells[cells[corr_index[j]]].tolist()[k]))]
# 			data2_index = [k for k,x in enumerate(d_cells[cells[corr_index[j]]].tolist()) if (np.isnan(d_cells[cells[i]].tolist()[k]) and ~np.isnan(d_cells[cells[corr_index[j]]].tolist()[k]))]

# 			for k in range(len(data2_)):
# 				d_cells[cells[i]][proteins[data2_index[k]]] = slope*data2_[k]+intercept

# # export data
# with open('protein_cells_correlation.csv','w') as f_o:
# 	writer = csv.writer(f_o)

# 	writer.writerow(['gene']+cells)
# 	for protein in proteins:
# 		gene_id = d['Gene ID'][d['Gene Symbol'].tolist().index(protein)]
# 		writer.writerow([gene_id]+list(d_cells.loc[protein]))

# # pickle.dump([d_tissues,d_cells,r_tissues,r_cells],open('data_protein_correlation.p','wb'))
# # [d_tissues_correlation,d_cells_correlation,r_tissues,r_cells] = pickle.load(open('data_protein_correlation.p','rb'))

# print 'Coverage with correlation: ', float(d_cells.shape[0] * d_cells.shape[1] - sum(list(d_cells.isnull().sum())))/(d_cells.shape[0] * d_cells.shape[1])