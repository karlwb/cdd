/* find groupid for a list of cards */
select 
    grp.id, 
    grp.value, 
    grptype.name 
from grp
join grpcard g0 on g0.grp_id = grp.id and g0.card_id like '3d'
join grpcard g1 on g1.grp_id = grp.id and g1.card_id like '3c' /* one join per card */
join grpcard g2 on g2.grp_id = grp.id and g2.card_id like '3s'
join grptype on grptype.id = grp.grptype_id
where grp.numcards = 3 /* size of group */