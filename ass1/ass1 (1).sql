-- COMP3311 22T3 Assignment 1
--
-- Fill in the gaps ("...") below with your code
-- You can add any auxiliary views/function that you like
-- The code in this file *MUST* load into an empty database in one pass
-- It will be tested as follows:
-- createdb test; psql test -f ass1.dump; psql test -f ass1.sql
-- Make sure it can load without error under these conditions

-- Q1: new breweries in Sydney in 2020

create or replace view Q1(brewery,suburb)
as
select breweries.name, locations.town
from breweries, locations
where breweries.founded = 2020 and locations.metro = 'Sydney' and breweries.located_in = locations.id 
;

-- Q2: beers whose name is same as their style

create or replace view Q2(beer,brewery)
as
select beers.name, breweries.name 
from beers, breweries, styles, brewed_by
where beers.name = styles.name and beers.style = styles.id
and ( brewed_by.beer = beers.id and brewed_by.brewery = breweries.id )
;

-- -- Q3: original Californian craft brewery

create or replace view Q3(brewery,founded)
as
select breweries.name, breweries.founded
from breweries
where breweries.founded = (select MIN(breweries.founded) 
                            from breweries, locations
                            where 
                            locations.region = 'California' and locations.id = breweries.located_in)
;


-- Q4: all IPA variations, and how many times each occurs


create or replace view Q4(style, count)
as 
select styles.name, count(beers) filter (where beers.style = styles.id)
from styles , beers
where styles.name LIKE '%' || 'IPA' || '%'
group by styles.name
;

-- Q5: all Californian breweries, showing precise location

create or replace view Q5(brewery,location)
as
select breweries.name, locations.town 
from breweries, locations
WHERE locations.region = 'California' and locations.id = breweries.located_in 
and locations.town is not null
UNION
select breweries.name, locations.metro 
from breweries, locations
WHERE locations.region = 'California' and locations.id = breweries.located_in
and locations.town is null
; 


-- Q6: strongest barrel-aged beer

create or replace view q6Helper(beerName, breweryName, strengthLevel)
as
select beers.name, breweries.name, beers.abv
from beers, breweries, brewed_by 
where brewed_by.beer = beers.id and brewed_by.brewery = breweries.id 
and (LOWER(beers.notes) LIKE '%' || LOWER('age') || '%') and (LOWER(beers.notes) LIKE '%' || LOWER('barrel') || '%')
order by beers.abv DESC
;

create or replace view Q6(beer,brewery,abv)
as
select beers.name, breweries.name, beers.abv 
from beers, breweries, brewed_by
where brewed_by.beer = beers.id and brewed_by.brewery = breweries.id 
and beers.abv = (select MAX(beers.abv) 
                    from beers
                    where 
                    (LOWER(beers.notes) LIKE '%' || LOWER('age') || '%') 
                    and (LOWER(beers.notes) LIKE '%' || LOWER('barrel') || '%') )
;

-- Q7: most popular hop

create or replace view getVarCount(variety, varCount)
as
select ingredients.name, count(*) 
from contains, ingredients
where contains.ingredient = ingredients.id
and ingredients.itype = 'hop'
group by ingredients.name
order by ingredients.name;


create or replace view Q7(hop)
as
select ingredients.name
from ingredients
where ingredients.name = ( select variety from getVarCount where varCount = (select MAX(VarCount) from getVarCount) )
; 

-- Q8: breweries that don't make IPA or Lager or Stout (any variation thereof)

create or replace view q8Helper(badBrewery, beer, style)
as
select breweries.name, beers.name, styles.name
from breweries, beers, styles, brewed_by
where brewed_by.beer = beers.id and brewed_by.brewery = breweries.id 
and beers.style = styles.id 
and (styles.name LIKE '%' || 'IPA' || '%' or styles.name LIKE '%' || 'Lager' || '%' or styles.name LIKE '%' || 'Stout' || '%')
order by breweries.name
;

-- (select * from q8);
create or replace view q8(brewery)
as
select breweries.name
from breweries
where NOT EXISTS (select badBrewery from q8Helper where breweries.name = badBrewery)
order by breweries.name
;


-- Q9: most commonly used grain in Hazy IPAs

create or replace view getGrainCount(grain, g_name, gCount)
as 
select ingredients.itype, ingredients.name, count(*)
from contains, ingredients, beers, styles
where contains.ingredient = ingredients.id
and contains.beer = beers.id and beers.style = styles.id and styles.name LIKE '%' || 'Hazy IPA' || '%'
and ingredients.itype = 'grain'
group by ingredients.itype, ingredients.name
order by ingredients.name;


create or replace view Q9(grain)
as
select ingredients.name
from ingredients 
where ingredients.name = ( select g_name from getGrainCount where gCount = (select MAX(gCount) from getGrainCount) )
;


-- Q10: ingredients not used in any beer

create or replace view contain(beer, ingredientUsed)
as 
select beers.name, ingredients.name 
from beers, contains, ingredients
where contains.ingredient = ingredients.id 
and contains.beer = beers.id 
;

create or replace view q10(unused)
as
select ingredients.name 
from ingredients
where NOT EXISTS (select ingredientUsed from contain where ingredients.name = ingredientUsed)
;


-- Q11: min/max abv for a given country

create or replace view q11Helper(countryName, minABV, maxABV)
as 
select country, min(beers.abv), max(beers.abv)
from beers, locations, brewed_by, breweries
where (brewed_by.beer = beers.id and brewed_by.brewery = breweries.id)
and breweries.located_in = locations.id 
group by country
order by locations.country
;

drop type if exists ABVrange cascade;
create type ABVrange as (minABV float, maxABV float);

create or replace function
	Q11(_country text) returns ABVrange
as $$
declare 
    r   RECORD;
    out ABVrange := (0, 0);
begin 
    for r in 
        select *
        from q11Helper
        -- where countryName = _country 
    loop
        if (r.countryName = _country) then
            out := ((r.minABV::numeric(4,1)), (r.maxABV::numeric(4,1)));
        end if;
        -- out := ((r.minABV), (r.maxABV));
    end loop;
    
    return out;
end;
$$
language plpgsql;

-- Q12: details of beers

create or replace view q12Helper(beerName, brewerName)
as 
select beers.name, breweries.name
from beers, breweries, ingredients, brewed_by
where brewed_by.beer = beers.id and brewed_by.brewery = breweries.id
group by beers.name,  breweries.name
order by beers.name 
;

drop type if exists BeerData cascade;
create type BeerData as (beer text, brewer text, info text);

create or replace function
	Q12(partial_name text) returns setof BeerData
as $$
declare 
    r       RECORD;
    _info   text := 'some info';
    _itype  text := '';
    _ingList text := '';
    b_data  BeerData := ('', '', '');

begin 
for r in         
        select *
        from q12Helper
        where LOWER(beerName)  LIKE '%' || LOWER(partial_name) || '%'
    loop
        b_data := (r.beername, r.brewerName, _info);
        return next b_data;
    end loop;

    return;
end;
$$
language plpgsql;

