/* play a group of cards */
update grpavail
set available = 0
where grp_id in 
  (select grp_id
   from grpcard gc
   where gc.card_id in ('3D', '3C', '3H'));

/* now see what was disabled */
/*
select 
  grp.value,
  grp.numcards,
  grptype.name,
  grp.id,
  group_concat(grpcard.card_id) as cards
from grpavail a 
join grp on a.grp_id=grp.id
join grptype on grptype.id = grp.grptype_id
join grpcard on grp.id = grpcard.grp_id
where a.available = 0
group by grp.id
*/