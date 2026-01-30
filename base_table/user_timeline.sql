select 
    "$part_event"
    ,count(distinct "#distinct_id") as cnt
    ,min("#event_time") as time
from ta.v_event_15
where ${PartDate:date} 
group by 1
order by 3 asc