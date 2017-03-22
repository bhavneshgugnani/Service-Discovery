# pip install pymongo
from pymongo import MongoClient
import datetime

client = MongoClient('172.18.0.3', 27017)
mydb = client['test_database_1'] # get database
my_collection = mydb['test-database'] # get collection


print mydb.collection_names()
print my_collection.find({'user_name':cisco})

# docker run -it -p 27017:27017 -v /Users/bhavneshgugnani/Documents/mongo_test:/mongo_test --name mon5 mongo /usr/bin/mongod --dbpath /mongo_test/db
