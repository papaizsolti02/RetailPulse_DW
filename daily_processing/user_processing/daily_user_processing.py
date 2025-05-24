import os
import json
import pyodbc
import requests

def daily_user_processing():
	"""
		This function is responsible for processing user data on a daily basis.
		It retrieves user data from an external API, processes it, and stores the results in a database.
	"""

	users = requests.get(
    	"https://randomuser.me/api/?results=5000"
  	).json().get('results')

	records = [(json.dumps(user), 'https://randomuser.me/api/') for user in users]

	#server = "=="
	#db = "=="

	conn = pyodbc.connect(
		'DRIVER={ODBC Driver 17 for SQL Server};'
		f'SERVER={server};'
		f'DATABASE={db};'
		'Trusted_Connection=yes;'
  	)

	cursor = conn.cursor()
	cursor.fast_executemany = True

	sp_call = "{CALL [raw].[IngestRawUsers] (?, ?)}"

	cursor.executemany(sp_call, records)
	conn.commit()

	cursor.close()
	conn.close()

daily_user_processing()