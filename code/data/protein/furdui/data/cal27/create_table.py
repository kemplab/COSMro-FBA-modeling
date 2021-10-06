import numpy as np
import pandas as pd

data1 = pd.read_table('GSM1119108-tbl-1.txt',header=None,index_col=0)
data1.drop([2,3,4],inplace=True,axis=1)

data2 = pd.read_table('GSM1119109-tbl-1.txt',header=None,index_col=0)
data2.drop([2,3,4],inplace=True,axis=1)

data3 = pd.read_table('GSM1119110-tbl-1.txt',header=None,index_col=0)
data3.drop([2,3,4],inplace=True,axis=1)

data = pd.concat([data1,data2,data3],axis=1)

data.to_csv('cal27.txt',sep='\t')