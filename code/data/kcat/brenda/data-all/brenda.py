import cobra
import collections
import cPickle as pickle
import csv
import hashlib
import numpy as np
import openpyxl
import os
import re
from SOAPpy import WSDL
import string
import time
import urllib2

def find_between(s, first_string, second_string, ind):
	# find string between two other strings
	start = s.index(first_string, ind) + len(first_string)
	end = s.index(second_string ,start)
	return s[start:end]

# # # # # # # # # # # # # # # BRENDA API # # # # # # # # # # # # # # #

wsdl = "http://www.brenda-enzymes.org/soap/brenda.wsdl"
password = hashlib.sha256("Jel0624_").hexdigest()
client = WSDL.Proxy(wsdl)

# # # # # # # # # # # # # # # GET TURNOVER RATES FOR EVERY ENZYME # # # # # # # # # # # # # # #

# ec = []
# f = open('id.txt','rb')
# for line in f.readlines():
# 	ec.append(line.rstrip())

# turnover = {}

# for i,ec_number in enumerate(ec):
# 	print 'STEP 1 - EC NUMBER %s OF %s - %s' % (i+1,len(ec),ec_number)

# 	turnover[ec_number] = {}

# 	time.sleep(1)
# 	parameters = 'joshlewis@gatech.edu,' + password + ',ecNumber*%s#' % ec_number
# 	resultString = client.getTurnoverNumber(parameters)
	
# 	if len(resultString) > 0:
# 		for string in resultString.split('!'):
# 			keep = True

# 			value = float(find_between(string,'turnoverNumber*','#',0))
# 			substrate = str(find_between(string,'substrate*','#',0))
# 			try:
# 				commentary = str(find_between(string,'commentary*','#',0))
# 			except:
# 				commentary = ''
# 				keep = False

# 			if value == -999:
# 				keep = False

# 			if len(commentary) > 0:

# 				ph_pattern = re.compile('pH ([0-9]{1,}\.{0,1}[0-9]{0,})')
# 				search = ph_pattern.search(commentary)
# 				if search != None:
# 					ph = float(search.group(1))
# 					if (ph < 7) or (ph > 8):
# 						keep = False

# 				exclude = ['recombinant','mutant','mutation']
# 				for string in exclude:
# 					if string in commentary.lower():
# 						keep = False

# 			if keep:
# 				if substrate not in turnover[ec_number].keys():
# 					turnover[ec_number][substrate] = [value]
# 				else:
# 					turnover[ec_number][substrate].append(value)

# pickle.dump(turnover,open('temp1.p','wb'))
# turnover = pickle.load(open('temp1.p','rb'))

# # # # # # # # # # # # # # # REPLACE SUBSTRATE NAME WITH BRENDA GROUP ID # # # # # # # # # # # # # # #

# for i,ec_number in enumerate(turnover):
# 	print 'STEP 2 - EC NUMBER %s OF %s - %s' % (i+1,len(turnover),ec_number)

# 	time.sleep(1)
# 	parameters = 'joshlewis@gatech.edu,' + password + ',ecNumber*%s#' % ec_number
# 	resultString = client.getLigands(parameters)

# 	if len(resultString) > 0:
# 		for string in resultString.split('!'):
# 			if 'turnover' in string.lower():

# 				name = str(find_between(string,'ligand*','#',0))
# 				id_ = str(find_between(string,'ligandStructureId*','#',0))

# 				to_delete = []
# 				for j,substrate in enumerate(turnover[ec_number]):
# 					if name == substrate:
# 						if id_ in turnover[ec_number].keys():
# 							turnover[ec_number][id_].extend(turnover[ec_number][substrate])
# 							to_delete.append(substrate)
# 						else:
# 							turnover[ec_number][id_] = turnover[ec_number].pop(substrate)
# 				for substrate in to_delete:
# 					turnover[ec_number].pop(substrate,None)

# 	to_delete = []
# 	for j,substrate in enumerate(turnover[ec_number]):
# 		if not substrate.isdigit():
# 			to_delete.append(substrate)
# 	for substrate in to_delete:
# 		turnover[ec_number].pop(substrate,None)

# pickle.dump(turnover,open('temp2.p','wb'))
# turnover = pickle.load(open('temp2.p','rb'))

# # # # # # # # # # # # # # # REPLACE BRENDA GROUP ID WITH INCHL ID # # # # # # # # # # # # # # #

# brenda = []
# for i,ec_number in enumerate(turnover):
# 	for j,brenda_id in enumerate(turnover[ec_number]):
# 		if brenda_id not in brenda:
# 			brenda.append(brenda_id)

# inchl = []
# for i,s in enumerate(brenda):

# 	print 'STEP 3 - SUBSTRATE %s OF %s - %s' % (i+1,len(brenda),s)

# 	time.sleep(1)
# 	url = 'http://www.brenda-enzymes.org/ligand.php?brenda_group_id=%s' % s
# 	d = urllib2.urlopen(url).read()

# 	if "<a href='http://www.ncbi.nlm.nih.gov/sites/entrez?cmd=search&db=pccompound&term=" in d:
# 		inchl.append(find_between(d,"<a href='http://www.ncbi.nlm.nih.gov/sites/entrez?cmd=search&db=pccompound&term=","'",0))
# 	else:
# 		inchl.append(None)

# for i,ec_number in enumerate(turnover):
# 	to_delete = []
# 	for j,brenda_id in enumerate(brenda):

# 		if brenda_id in turnover[ec_number]:

# 			if inchl[brenda.index(brenda_id)] != None:
# 				if inchl[brenda.index(brenda_id)] in turnover[ec_number].keys():
# 					turnover[ec_number][inchl[brenda.index(brenda_id)]].extend(turnover[ec_number][brenda_id])
# 					to_delete.append(brenda_id)
# 				else:
# 					turnover[ec_number][inchl[brenda.index(brenda_id)]] = turnover[ec_number].pop(brenda_id)
# 			else:
# 				to_delete.append(brenda_id)

# 	for brenda_id in to_delete:
# 		turnover[ec_number].pop(brenda_id,None)

# pickle.dump(turnover,open('temp3.p','wb'))
turnover = pickle.load(open('temp3.p','rb'))

# # # # # # # # # # # # # # # REPLACE INCHL ID WITH OTHER DATABASE IDS # # # # # # # # # # # # # # #

inchl = []
for i,ec_number in enumerate(turnover):
	for j,inchl_id in enumerate(turnover[ec_number]):
		if inchl_id not in inchl:
			inchl.append(inchl_id)

chebi = []
kegg = []
pubchem = []
hmdb = []
for i,inchl_ in enumerate(inchl):

	print 'STEP 4 - SUBSTRATE %s OF %s - %s' % (i+1,len(inchl),inchl_)

	# chebi
	time.sleep(1)
	url = 'http://cts.fiehnlab.ucdavis.edu/service/convert/InChIKey/ChEBI/%s' % inchl_

	result = False
	while result is False:
		try:
			d = urllib2.urlopen(url).read()
			index1 = d.index('"result"')
			result = True
		except:
			pass

	value = find_between(d,'[',']',index1)

	if '"' in value:
		chebi.append([])

		value = value.split(',')
		for v in value:
			chebi[-1].append(find_between(v,'"CHEBI:','"',0))

	else:
		chebi.append(None)

	# kegg
	time.sleep(1)
	url = 'http://cts.fiehnlab.ucdavis.edu/service/convert/InChIKey/KEGG/%s' % inchl_
	
	result = False
	while result is False:
		try:
			d = urllib2.urlopen(url).read()
			index1 = d.index('"result"')
			result = True
		except:
			pass

	value = find_between(d,'[',']',index1)

	if '"' in value:
		kegg.append([])

		value = value.split(',')
		for v in value:
			kegg[-1].append(find_between(v,'"','"',0))

	else:
		kegg.append(None)

	# pubchem
	time.sleep(1)
	url = 'http://cts.fiehnlab.ucdavis.edu/service/convert/InChIKey/PubChem%%20CID/%s' % inchl_
	
	result = False
	while result is False:
		try:
			d = urllib2.urlopen(url).read()
			index1 = d.index('"result"')
			result = True
		except:
			pass

	value = find_between(d,'[',']',index1)

	if '"' in value:
		pubchem.append([])

		value = value.split(',')
		for v in value:
			pubchem[-1].append(find_between(v,'"','"',0))

	else:
		pubchem.append(None)

	# hmdb
	time.sleep(1)
	url = 'http://cts.fiehnlab.ucdavis.edu/service/convert/InChIKey/Human%%20Metabolome%%20Database/%s' % inchl_
	
	result = False
	while result is False:
		try:
			d = urllib2.urlopen(url).read()
			index1 = d.index('"result"')
			result = True
		except:
			pass

	value = find_between(d,'[',']',index1)

	if '"' in value:
		hmdb.append([])

		value = value.split(',')
		for v in value:
			hmdb[-1].append(find_between(v,'"','"',0))

	else:
		hmdb.append(None)

	if os.path.isfile('temp4.p'):
		os.remove('temp4.p')
	pickle.dump([turnover,inchl,chebi,kegg,pubchem,hmdb],open('temp4.p','wb'))

[turnover,inchl,chebi,kegg,pubchem,hmdb] = pickle.load(open('temp4.p','rb'))

# # # # # # # # # # # # # # # CREATE OUTPUT FILE # # # # # # # # # # # # # # #

with open('turnover.csv','wb') as f:
	writer = csv.writer(f)
	writer.writerow(['ec','value','chebi','kegg','pubchem','hmdb'])

	for ec_number in turnover:
		for substrate in turnover[ec_number]:
			for value in turnover[ec_number][substrate]:
				
				if chebi[inchl.index(substrate)] != None:
					id_chebi = ';'.join(chebi[inchl.index(substrate)])
				else:
					id_chebi = ''

				if kegg[inchl.index(substrate)] != None:
					id_kegg = ';'.join(kegg[inchl.index(substrate)])
				else:
					id_kegg = ''

				if pubchem[inchl.index(substrate)] != None:
					id_pubchem = ';'.join(pubchem[inchl.index(substrate)])
				else:
					id_pubchem = ''

				if hmdb[inchl.index(substrate)] != None:
					id_hmdb = ';'.join(hmdb[inchl.index(substrate)])
				else:
					id_hmdb = ''

				writer.writerow([ec_number,value*60*60,id_chebi,id_kegg,id_pubchem,id_hmdb])