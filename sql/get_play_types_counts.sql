

/* get play types and counts of each */
select grptype.name,
       count(*) as n
from grp
join grptype on grptype.id = grp.grptype_id
group by name
order by grp.numcards, grp.value