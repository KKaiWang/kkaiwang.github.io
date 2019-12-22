# -*- coding: utf-8 -*-
"""
Created on Thu Jan  4 11:14:46 2018

@author: caoa
"""

import requests
import pandas as pd

LobbyViewName = 'Timberland Co (The)'
results = 1055561

#%%
# Search by company
params = {"query": {"lobbyview_name": LobbyViewName},
          "limit":300,
          }
# filter by year and amount to iterate through all records
params = {"query": {"year": {"equals": "2016"},
                    "amount": {"equals":"10000",}
                    },
          "limit":10,
          }          
headers = {'Content-Type':'application/json'}

'''
HTTPError: 504 Server Error: Gateway Time-out for url:
https://beta.lobbyview.org/public/api/reports
'''

#%%
url = r'https://beta.lobbyview.org/public/api/reports'
R = requests.post(url, headers=headers, json=params)
R.raise_for_status()
reports = R.json()
print(len(reports['result']))

#%%
lobbying = []
for i, result in enumerate(reports['result'], start=1):
    bvdid = result['client']['bvdid']
    legalname = result['client_name']
    yr = result['year']
    amount = result['amount']
    issues = result['issue_codes']
    lobbying.append((bvdid, legalname, yr, amount, issues))

lobbyists = pd.DataFrame(lobbying, columns=['bvdid', 'legalname', 'yr', 'amount', 'issues'])

#%%
params = {'legal_name':LobbyViewName}
url = r'https://beta.lobbyview.org/api/viz'
R = requests.get(url, params=params)
response = R.json()
    
#%%
data = []
for i, result in enumerate(response['lobby_type']):
    source = result['key']
    for value in result['values']:
        data.append((bvdid, LobbyViewName, source, value['label'],value['y'], )) 
        
df = pd.DataFrame(data, columns=['bvdid','name','source','issue','amount'])

#%% Gathering Inhouse vs Outsource Data
url = r'https://beta.lobbyview.org/public/api/self_filed'
LobbyViewName = 'Abbott Laboratories'
params = {"bvdid": 'US360698440'}
R = requests.post(url, headers=headers, json=params)
R.raise_for_status()
results = R.json()['results']

datalist = []
for key, data in results.items():
    for i, report in enumerate(data, start=1):
        legalname = report['client']['legal_name']
        bvdid = report['client']['bvdid']
        naics = report['client']['naics']
        registrant = report['registrant']
        yr = report['year']
        if report['issue_codes']:
            num_issues = len(report['issue_codes'])
            for issue in report['issue_codes']:
                if report['amount']:
                    amount = report['amount']/num_issues
                else:
                    amount = None
                datalist.append((i, key, legalname, bvdid, naics, registrant, yr, amount, issue))                
        else:
            datalist.append((i, key, legalname, bvdid, naics, registrant, yr, amount, None))                            

df = pd.DataFrame(datalist, columns=['report','type','legalname','bvdid','naics','registrant','year','amount','issues'])

