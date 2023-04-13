# COMP3311 22T3 Assignment 2 ... Python helper functions
# add here any functions to share between Python scripts 
# you must submit this even if you add nothing

import re
import psycopg2

# check whether a string looks like a year value
# return the integer value of the year if so

def getResults(db, query):
   cur = db.cursor()
   cur.execute(query)
   res = cur.fetchall()
   cur.close()
   return res

def getPeopleCount(db, value):
   query = f"select people.name from people where people.name = '{value}';"
   res = getResults(db, query)
   return len(res)


def getYear(year):
   digits = re.compile("^\d{4}$")
   if not digits.match(year):
      return None
   else:
      return int(year)

def checkExistence(db, value, query):
   res = getResults(db, query)
   check = False
   for r in res:
      if r[0] == value:
         check = True
         break
   return check



# def genreHelper(db, year):
#    queryData = f"""
#    select moviegenres.genre, count(*) as mycount
#    from movies, moviegenres
#    where movies.id = moviegenres.movie
#    and movies.year = '{year}'
#    group by moviegenres.genre, movies.year
#    order by mycount desc
#    FETCH FIRST 10 ROWS WITH TIES;
#    """

def isManyActors(res, currId):
   isMany = False
   for r in res:
      if currId != r[4]:
         isMany = True
         break
   
   return isMany

def doManyPeople(count, person):
   if (count is not None):
      count += 1
      print(f"{person} #{count}")
   return count

def fixString(string):
   # for i in range(len(string)):
   #    if string[i] == " ' ":
   #       print(string)
   newString = string.replace("\'", "\'\'")
   return newString
