-- 根据报表内容，构建同样的表格
select 'BR' as country,
       561.39 as cost,
       565451 as show_times,
       0.99 as CPM,
       6593 as click,
       1.17% as ctr,
       43.35% as cvr,
       2858 as install,
       0.20 as cpi  
union 
(select "IN",707,1620638,0.44,5815,0.98%,15.90%,515,0.28)
union
(select "US",1246.23,2333802,0.54,10472,0.98%,22.40%,892,0.14)
union
(select "MX",144.49,232244,0.64,1220,0.98%,13.80%,103,0.14)
union 
(select "总计",1958.11,4742345,0.59,23320,0.98%,17.27%,3858,0.18)

select  "IN" as country,
       cost,
       show_times,
       CPM,
       click,
       ctr,
       cvr,
       install,
       cpi
last_value(cost)over(order by country) as last_cost