-- 数据质量检查
    -- 1,重复行（数据膨胀）、缺失行（数据缺失）

-- 左/右表唯一性检查
select role_id,log_date,count(*)
from active_ad
group by 1,2
having count(*)>1

-- 左表原本行
select count(*)
from active

-- left join后行数
select count(*)
from active t1
left join ad t2
    on t1.role_id=t2.role_id

-- 定位具体膨胀位置
select
    t1.role_id
    ,t1.log_date
    ,count(*) as join_count
from active t1
left join ad t2
    on t1.role_id=t2.role_id
group by 1,2
having count(*) >1