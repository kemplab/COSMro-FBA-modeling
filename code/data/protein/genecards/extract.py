from bs4 import BeautifulSoup
import csv
import glob
import numpy as np
import pandas as pd
import urllib

# # # # # EXTRACT DATA # # # # # 

# tissues and cells
tissues = ['Monocyte','Neutrophil','B-lymphocyte','T-lymphocyte','CD4 T cells','CD8 T cells','NK cells','Periph. blood mononuclear cells','Lymph node','Tonsil','Bone marrow stromal cell','Bone marrow mesench. stem cell','Brain','Frontal cortex','Cerebral cortex','Spinal cord','Retina','Heart','Bone','Colon muscle','Oral epithelium','Nasopharynx','Nasal respiratory epithelium','Esophagus','Stomach','Cardia','Colon','Rectum','Liver','Kidney','Spleen','Lung','Adipocyte','Salivary gland','Thyroid','Adrenal','Breast','Pancreas','Islet of Langerhans','Gallbladder','Prostate','Urinary bladder','Skin','Hair follicle','Placenta','Uterus','Cervix','Ovary','Testis']
cells = ['T-cell leukemia, Jurkat','Myeloid leukemia, K562','Lymphoblastic leukemia, CCRF-CEM','Brain cancer, U251','Brain cancer, GAMG','Bone cancer, U2OS','Kidney, HEK293','Liver cancer, HuH-7','Liver cancer, HepG2','NSC lung cancer, NCI-H460','Lung cancer, A549','Kidney cancer, RXF393','Colon cancer, RKO','Colon cancer, Colo205','Melanoma, M14','Breast cancer, LCC2','Breast cancer, MCF7','Ovarian cancer, SKOV3','Prostate cancer, LnCap','Prostate cancer, PC3','Cervical cancer, HeLa S3','Cervical cancer, HeLa']

# genes
d_ids = pd.read_table('ids.txt')
genes = d_ids['Gene ID'].tolist()

# initialize data frame
data = pd.DataFrame(index=genes, columns=tissues+cells)

# extract data
for file in glob.glob('html/*.html'):
	protein = file.split(' ')[0].split('/')[1]
	print protein
	
	soup = BeautifulSoup(urllib.urlopen(file).read(),'lxml')
	
	# tissues
	m1 = soup.find('map', attrs={'name':'tissues_map_prot_%s' % protein})
	if m1 != None:
		for m2 in m1.children:
			if (m2['title'] != '92 tissues & compartments') and ('No Data' not in m2['title']) and ('fetal' not in m2['title'].lower()):
				value = float(m2['title'].split(', ')[0])
				tissue = m2['title'].split(', ')[1]

				if (value != 0) and (tissue in tissues):
					data[tissue][d_ids['Gene ID'][d_ids['Gene Symbol'].tolist().index(protein)]] = value

	# cells
	m1 = soup.find('map', attrs={'name':'tissues_map_prot_%s_GCs' % protein})
	if m1 != None:
		for m2 in m1.children:
			if (m2['title'] != '92 tissues & compartments') and ('No Data' not in m2['title']):
				value = float(m2['title'].split(', ')[0])
				if len(m2['title'].split(', ')) == 4:
					cell = m2['title'].split(', ')[1] + ', ' + m2['title'].split(', ')[2]
				else:
					cell = m2['title'].split(', ')[1]

				if (value != 0) and (cell in cells):
					data[cell][d_ids['Gene ID'][d_ids['Gene Symbol'].tolist().index(protein)]] = value

# # # # # # EXPORT DATA # # # # #

# each sample
for sample in tissues+cells:

	# get data
	values = data[sample].values.tolist()

	# create file
	with open('samples/%s.csv' % (sample.lower().replace(', ','-').replace(',','-').replace(' ','-').replace('.','')),'w') as f_o:
		writer = csv.writer(f_o)
		writer.writerow(['GENE','PPM'])

		# each gene value
		for i in range(len(genes)):
			writer.writerow([genes[i],values[i]])