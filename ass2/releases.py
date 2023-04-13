#!/usr/bin/python3

# COMP3311 22T3 Assignment 2
# Print a list of countries where a named movie was released

import sys
import psycopg2
import helpers

### Globals

db = None
usage = f"Usage: {sys.argv[0]} 'MovieName' Year"

### Command-line args

if len(sys.argv) < 3:
   print(usage)
   exit(1)

# process the command-line args ...
title = sys.argv[1]
year = sys.argv[2]

### Queries
queryData = "select movies.title, movies.year, countries.name from movies, releasedin, countries where releasedin.movie = movies.id and releasedin.country = countries.code order by name;"

queryMovie = "select movies.title from movies;"

queryReleases = "select movies.title from movies, releasedin where releasedin.movie = movies.id;"

### Manipulating database

try:
   # your code goes here
   db = psycopg2.connect("dbname=ass2")

   if helpers.getYear(year) is None:
      exit("Invalid year")
   
   elif not helpers.checkExistence(db, title, queryMovie):
      exit("No such movie")
   
   elif not helpers.checkExistence(db, title, queryReleases):
      exit("No releases")

   else:
      res = helpers.getResults(db, queryData)
      for r in res:
         if r[0] == title and str(r[1]) == str(year):
            print(f"{r[2]}")

except Exception as err:
   print("DB error: ", err)
finally:
   if db:
      db.close()

