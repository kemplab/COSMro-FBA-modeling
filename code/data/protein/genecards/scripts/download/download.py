import glob
import os
import pandas as pd
import time

# # # # # DOWNLOAD WEBPAGES # # # # # # # # # # # # # # # # # # # # # # # # # 

# webpage to start with
start = 'SERPINA3'

# file will all genes to download
d = pd.read_table('ids.txt')

# where in file to start
start_index = d['Gene Symbol'].tolist().index(start)

os.chdir('html')
for i in range(d.shape[0]):
	if i >= start_index:
		
		# download webpage
		os.system('./save_page_as -b google-chrome --load-wait-time 20 --save-wait-time 5 http://www.genecards.org/cgi-bin/carddisp.pl?gene=%s#expression' % d['Gene Symbol'][i])
		time.sleep(5)

# # # # # TEST TO ENSURE ALL WEBPAGES HAVE BEEN DOWNLOADED # # # # # # # # # # # # # # # # # # # # # # # # # 

# list of genes to be downloaded
original = [x for x in d['Gene Symbol'].tolist() if x!='-']

# list of genes already downloaded
new = []
for file in glob.glob('*.html'):
	new.append(file.split(' ')[0])

# top: in original but not new
# bottom: in new but not original
for x in original:
	if x not in new:
		print x
print '--------------'
for x in new:
	if x not in original:
		print x