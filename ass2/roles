#!/usr/bin/python3

# COMP3311 22T3 Assignment 2
# Print a list of character roles played by an actor/actress

import sys
import psycopg2
import helpers

### Globals

db = None
usage = f"Usage: {sys.argv[0]} FullName"

### Command-line args

if len(sys.argv) < 2:
   print(usage)
   exit(1)

# process the command-line args ...
person = sys.argv[1]

### Queries
queryPerson = "select people.name from people;"

selfCheckQuery = f"""
select people.name , principals.job, principals.movie
from people, principals
where principals.person = people.id
and people.name = '{person}' and principals.job = 'self';
"""

def queryID(name):
   return f"""
   select people.name, people.id
   from people
   where people.name = '{name}'
   order by id;
   """

def queryDataOnID(id):
   return  f"""
   select people.id, people.name, playsrole.role, movies.title, movies.year
   from  playsrole,  movies, principals, people
   where people.id = '{id}'
   and playsrole.inmovie = principals.id
   and principals.movie = movies.id
   and principals.person = people.id
   order by year, title, role;
   """

### Manipulating database

try:
   # your code goes here
   db = psycopg2.connect("dbname=ass2")
   
   if not helpers.checkExistence(db, person, queryPerson):
      print("No such person")

   else:
      resID = helpers.getResults(db, queryID(person))
      count = None
      noOutput = True
      isEmptyResRoles = False

      # print(resID)
      
      if (len(resID) > 1):
         count = 0

      for ids in resID:
         resRoles = helpers.getResults(db, queryDataOnID(ids[1]))
         count = helpers.doManyPeople(count, person)

         if len(resRoles) == 0:
            isEmptyResRoles = True
            print("No acting roles")
         
         else:            
            for r in resRoles:
               if r[2] == 'Self':
                  resSelfCheck = helpers.getResults(db, selfCheckQuery)
                  if (len(resSelfCheck) == 0):
                     continue
               print(f"{r[2]} in {r[3]} ({r[4]})")
               noOutput = False
      
      if noOutput == True and isEmptyResRoles == False:
         print("No acting roles")


except Exception as err:
   print("DB error: ", err)
finally:
   if db:
      db.close()

