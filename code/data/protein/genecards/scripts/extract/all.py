from bs4 import BeautifulSoup
import glob
import numpy as np
import os
import pandas as pd
import pickle
import urllib

# # # # # EXTRACT DATA # # # # # # # # # # # # # # # # # # # # # # # # # 

os.chdir('html')

# tissues matching protein and rna
tissues_protein = ['Monocyte','B-lymphocyte','CD4 T cells','CD8 T cells','NK cells','Lymph node','Tonsil','Bone marrow stromal cell','Brain','Cerebral cortex','Spinal cord','Retina','Heart','Oral epithelium','Esophagus','Stomach','Colon','Liver','Kidney','Spleen','Lung','Adipocyte','Salivary gland','Thyroid','Adrenal','Breast','Pancreas','Islet of Langerhans','Prostate','Urinary bladder','Skin','Placenta','Uterus','Ovary','Testis']
tissues_rna = ['Monocytes','B Cells','T Cells (CD4+)','T Cells (CD8+)','NK Cells','Lymph Node','Tonsil','Bone Marrow','Brain','Cortex','Spinal Cord','Retina','Heart','Tongue','Esophagus','Stomach','Colon','Liver','Kidney','Spleen','Lung','Adipocyte','Salivary Gland','Thyroid','Adrenal Gland','Breast','Pancreas','Pancreatic Islet','Prostate','Bladder','Skin','Placenta','Uterus','Ovary','Testis']
tissues_rna_source = [2,2,2,2,2,1,2,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1]

# cells
cells_protein = ['T-cell leukemia, Jurkat','Myeloid leukemia, K562','Lymphoblastic leukemia, CCRF-CEM','Brain cancer, U251','Brain cancer, GAMG','Bone cancer, U2OS','Kidney, HEK293','Liver cancer, HuH-7','Liver cancer, HepG2','NSC lung cancer, NCI-H460','Lung cancer, A549','Kidney cancer, RXF393','Colon cancer, RKO','Colon cancer, Colo205','Melanoma, M14','Breast cancer, LCC2','Breast cancer, MCF7','Pancreas cancer','Ovarian cancer, SKOV3','Prostate cancer, LnCap','Prostate cancer, PC3','Cervical cancer, HeLa S3','Cervical cancer, HeLa']

# all proteins
proteins = []
for file in glob.glob('*.html'):
	proteins.append(file.split(' ')[0])

# initialize data
d_tissues_protein = pd.DataFrame(index=proteins, columns=tissues_protein)
d_tissues_rna = pd.DataFrame(index=proteins, columns=tissues_rna)
d_cells_protein = pd.DataFrame(index=proteins, columns=cells_protein)

for file in glob.glob('*.html'):
	protein = file.split(' ')[0]
	print protein
	
	# get html
	soup = BeautifulSoup(urllib.urlopen(file).read(),'lxml')
	
	# protein expression - tissues
	m1 = soup.find('map', attrs={'name':'tissues_map_prot_%s' % protein})
	if m1 != None:
		for m2 in m1.children:
			if (m2['title'] != '92 tissues & compartments') and ('No Data' not in m2['title']):
				value = float(m2['title'].split(', ')[0])
				tissue = m2['title'].split(', ')[1]

				if (value != 0) and (tissue in tissues_protein):
					d_tissues_protein[tissue][protein] = value

	# rna expression - tissues
	m1 = soup.find('map', attrs={'name':'tissues_map_%s' % protein})
	if m1 != None:
		reached_end = False
		for m2 in m1.children:
			if m2['title'] == 'Fragments Per Kilobase of exon per Million fragments mapped':
				reached_end = True

			if (not reached_end) and (m2['title'] not in ['%s at BioGPS' % protein,'76 tissues & compartments']) and ('No Data' not in m2['title']):
				value = float(m2['title'].split(', ')[0])
				tissue = m2['title'].split(', ')[1]

				if (value != 0) and (tissue in tissues_rna):
					if tissues_rna_source[tissues_rna.index(tissue)] == 1:
						d_tissues_rna[tissue][protein] = value

	m1 = soup.find('map', attrs={'name':'tissues_map_%s_BioGPS' % protein})
	if m1 != None:
		for m2 in m1.children:
			if (m2['title'] != '76 tissues & compartments') and ('No Data' not in m2['title']):
				value = float(m2['title'].split(', ')[0])
				tissue = m2['title'].split(', ')[1]

				if (value != 0) and (tissue in tissues_rna):
					if tissues_rna_source[tissues_rna.index(tissue)] == 2:
						d_tissues_rna[tissue][protein] = value

	# protein expression - cells
	m1 = soup.find('map', attrs={'name':'tissues_map_prot_%s_GCs' % protein})
	if m1 != None:
		for m2 in m1.children:
			if (m2['title'] != '92 tissues & compartments') and ('No Data' not in m2['title']):
				value = float(m2['title'].split(', ')[0])
				if len(m2['title'].split(', ')) == 4:
					cell = m2['title'].split(', ')[1] + ', ' + m2['title'].split(', ')[2]
				else:
					cell = m2['title'].split(', ')[1]

				if (value != 0) and (cell in cells_protein):
					d_cells_protein[cell][protein] = value
os.chdir('..')

pickle.dump([d_tissues_protein,d_tissues_rna,d_cells_protein],open('data_all.p','wb'))
[d_tissues_protein,d_tissues_rna,d_cells_protein] = pickle.load(open('data_all.p','rb'))

# # # # # RNA-PROTEIN REGRESSION # # # # # # # # # # # # # # # # # # # # # # # # # 

rs = []
for index_protein,protein in enumerate(proteins):
	if sum(~np.isnan(list(d_tissues_protein.loc[protein]))) >= 3:
		nan1 = [i for i,x in enumerate(list(d_tissues_protein.loc[protein])) if ~np.isnan(x)]
		if sum(~np.isnan(list(d_tissues_rna.ix[index_protein,nan1]))) >= 3:
			nan2 = [i for i,x in enumerate(list(d_tissues_rna.ix[index_protein,nan1])) if ~np.isnan(x)]
			nan1 = [nan1[i] for i in nan2]

			data_protein = list(d_tissues_protein.ix[index_protein,nan1])
			data_rna = list(d_tissues_rna.ix[index_protein,nan1])
			r = np.corrcoef(np.vstack((data_protein,data_rna)))[1,0]

			if ~np.isnan(r):
				rs.append(r)

			if protein in ['G6PD','PGD','IDH1','IDH2','DHFR','DHFRL1','MTHFD1','MTHFD2']:
				print protein, r


plt.hist(rs, 20)
plt.title('Protein vs Gene Expression')
plt.xlabel('Correlation Coefficient')
plt.ylabel('Count')
plt.savefig('histogram.png')