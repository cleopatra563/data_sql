-- {"card_info":"{\"1\":{\"level_counts\":{\"1\":1,\"2\":2,\"3\":1},\"out_level\":1,\"powers\":[2,1,4,8],\"role_id\":11101},\"2\":{\"level_counts\":{\"1\":1,\"2\":1},\"out_level\":1,\"powers\":[2,3],\"role_id\":11201},\"3\":{\"level_counts\":{\"1\":1,\"2\":1,\"3\":1},\"out_level\":1,\"powers\":[1,5,12],\"role_id\":11301},\"4\":{\"level_counts\":{\"1\":2,\"3\":1},\"out_level\":1,\"powers\":[9,1,1],\"role_id\":11401}}","round_info":
-- "{\"battle_duration\":26574,\"break_stone_mana\":0,\"devil_level\":4,\"hp\":2,\"is_double_speed\":false,\"remaining_mana\":0,\"round_mana\":10}"}

-- json格式处理
select 
    json_extract(card_one_info,'$.level_counts') as level_counts
    ,json_extract(card_one_info,'$.level_counts.1') as "1"
    ,json_extract(card_one_info,'$.level_counts.2') as "2"
    ,json_extract(card_one_info,'$.level_counts.3') as "3"
    ,json_extract(card_one_info,'$.level_counts.4') as "4"
from (
    select 
        log_info
        ,log_info.card_info as card_info
        ,json_extract(log_info.card_info, '$.1') as card_one_info
        ,json_extract(log_info.card_info,'$.2') as card_two_info
        ,json_extract(log_info.card_info,'$.3') as card_three_info
        ,json_extract(log_info.card_info,'$.4') as card_four_info
    
    from tmp  
    where "$part_event" in ('main_stage_into','main_stage_start','main_stage_end')
    order by "#server_time" desc
    ) a     

select 
    log_info
    ,log_info.card_info as card_info
    ,json_extract(log_info.card_info, '$.1') as card_one_info
    ,json_extract(log_info.card_info,'$.2') as card_two_info
    ,json_extract(log_info.card_info,'$.3') as card_three_info
    ,json_extract(log_info.card_info,'$.4') as card_four_info
    ,json_extract(log_info.round_info,'$.battle_duration') as battle_duration

from tmp  
where "$part_event" in ('main_stage_into','main_stage_start','main_stage_end')
order by "#server_time" desc