import csv
import json

name = []
ids = []

with open('data/reactions.txt','r') as f:
	for line in f.readlines():
		data = json.loads(line)
		for i in range(len(data['results'])):
			name.append(str(data['results'][i]['abbreviation']))
			ids.append(int(data['results'][i]['rxn_id']))

standard = [-999999]*len(name)
uncertainty = [0]*len(name)

with open('data/reacdeltags.txt','r') as f:
	for line in f.readlines():
		data = json.loads(line)
		for i in range(len(data['results'])):
			rxn_id = int(data['results'][i]['rxn'].split('/')[-2])
			standard[ids.index(rxn_id)] = float(data['results'][i]['standardEnergy'])
			uncertainty[ids.index(rxn_id)] = float(data['results'][i]['uncertainty'])

with open('vmh_no_irreversible.csv','w') as f:
	writer = csv.writer(f)
	for i in range(len(name)):
		writer.writerow([name[i],standard[i],uncertainty[i]])