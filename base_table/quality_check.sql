-- 数据质量检查
    -- 1,重复行（数据膨胀）、缺失行（数据缺失）

-- 运行和调试
-- step 1
select *
from register

-- step 2
select role_id,reg_date,count(*)
from register
group by role_id,reg_date
having count(*)>1

-- step 3
select *
from register
where role_id in ('7603ae366460a0bb')

-- 表唯一性检查
select 
    role_id,log_date,count(*)
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
from active t1 -- 左表
left join ad t2 -- 右表
    on t1.role_id=t2.role_id
group by 1,2
having count(*) >1

-- 实际查询
select 
    role_id
    ,log_time
    ,count(*)
from active
group by 1,2
having count(*) >1

-- 实际查询
select 
    t1.reg_date 
    ,count(distinct t1.role_id) as user_cnt  
from your_table t1
left join your_table t2
    on t1.role_id=t2.role_id
group by t1.reg_date