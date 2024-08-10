import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore



NameOfCollection1 = input("Name of collection 1: ")
NameOfCollection2 = input("Name of collection 2: ")

NameOfMergedCollection = input("Name of merged collection: ")


# Use a service account
cred = credentials.Certificate('/Users/blakegabriel/Development/Netflix_Tinder/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

# Access the Firestore database
db = firestore.client()

# Collection references for the two source collections
collection_ref1 = db.collection(NameOfCollection1)
collection_ref2 = db.collection(NameOfCollection2)

# Create a new collection to merge into
merged_collection_ref = db.collection(NameOfMergedCollection)

# Create a set to keep track of existing titles
existing_titles = set()

# Get documents from collection1
for doc in collection_ref1.stream():
    # Check if title already exists in merged collection
    if doc.to_dict().get('Title') in existing_titles:
        continue  # Skip if title already exists
    else:
        existing_titles.add(doc.to_dict().get('Title'))

    # Add document to merged collection
    merged_collection_ref.document(doc.id).set(doc.to_dict())

# Get documents from collection2
for doc in collection_ref2.stream():
    # Check if title already exists in merged collection
    if doc.to_dict().get('Title') in existing_titles:
        continue  # Skip if title already exists
    else:
        existing_titles.add(doc.to_dict().get('Title'))

    # Add document to merged collection
    merged_collection_ref.document(doc.id).set(doc.to_dict())

print("Collections \"" + NameOfCollection1 + "\" and \"" + NameOfCollection2 + "\" merged into \"" + NameOfMergedCollection + "\"")