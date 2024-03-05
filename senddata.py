import firebase_admin
from firebase_admin import credentials, firestore
import time
import datetime
import socket



def firebase_conn():
	try:
		cred = credentials.Certificate(r"C:\Users\Server\Documents\OpenRPA\firestoredb.json")  # Replace with your own service account key file
		firebase_admin.initialize_app(cred)

		return True

	except Exception as e:

		print("Error initializing Firebase Admin SDK:" )

		return False


def add_or_update_data():
	current_date = datetime.datetime.now()
	date = current_date.now().strftime("%Y-%m-%d")
	time_stamp = current_date.now().strftime("%H:%M:%S")
	computer_name = socket.gethostname()
	get_dcname = computer_name.split("-")
	dcname_initials = get_dcname[1]
	store_code = get_dcname[2]
	collection_name = "rpa_installation_data"

	data = {
	     'Date' : date,
	     'Time_stamp' : time_stamp,
	     'Store_Code' : store_code,
	     'DC' : dcname_initials,
	     'Status' : 'INSTALLED'
	}

	if firebase_conn():
		db = firestore.client()

		query = db.collection(collection_name).where('Store_Code', '==', store_code).limit(1).stream()
		

		# If document exists, update it; otherwise, create a new document
		if len(list(query)) > 0:
			query  = db.collection('rpa_installation_data').where('Store_Code', '==', store_code).limit(1).stream()
			for doc in query:
				doc.reference.update(data)

			print("Data updated.")
		else:
			db.collection('rpa_installation_data').add(data)
			print("new table added.")


add_or_update_data()

