-- 再加	lobby_enter
-- 1,写大盘数据
-- 2,写LTV
-- 3,写LTV拆成子商品贡献度
-- 4,对比安装时间和注册时间的差异
-- 5,留存拆回流和连续登录
-- 6,黑产用户分析：单账号多设备/ip充值 单账号多设备登录

with recharge as (SELECT "#account_id"role_id
                ,"#event_time"log_time
                ,"$part_date"log_date
                ,"#zone_offset"
                ,"#country"
                ,"#uuid" # 设备id
                ,sub_game_name as item_name # 购买商品
                ,cast(game_id as int) as money
                ,'CNY' as money_type
                FROM v_event_4 
                WHERE "$part_event"='game_end'
                AND "$part_date">='2025-12-29' 
                AND "$part_date"<='2026-01-07' 
                )
