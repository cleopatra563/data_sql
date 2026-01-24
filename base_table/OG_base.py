import requests
import json
import pandas as pd
import numpy as np
import datetime
import time
import warnings 
import matplotlib.pyplot as plt  
# import dataframe_image as dfi
import base64
import hashlib
from pandas.plotting import  table
# from  apscheduler.schedulers.blocking  import  BlockingScheduler
# from apscheduler.schedulers.background import BackgroundScheduler
# from requests_toolbelt import MultipartEncoder
warnings.filterwarnings('ignore')
plt.rcParams['font.sans-serif'] = ['Arial Unicode MS']
plt.rc('font', family='Microsoft YaHei Mono', size=20)
pd.set_option('display.unicode.ambiguous_as_wide', True)
pd.set_option('display.unicode.east_asian_width', True)
pd.set_option('display.width', 260) 
def get_sql():
    sql = ''' 
           SELECT "#user_id","#account_id","#distinct_id","$part_event","#event_time","$part_date","#data_source","day1_last_sub_game_name","day1_sub_game_reason_cnt","day1_sub_game_reason_win_cnt","day1_sub_game_uptime","is_keep7","is_keep6","is_keep5","ad_game_name","is_keep4","is_keep3","is_keep2","day1_is_sign","day1_is_ad_rewarded","day1_sub_game_name","role_id","reg_time","reg_app_version","day1_sub_game_reason_fail_cnt","install_local_time","install_time","day1_unblock_gamenum","day1_sub_game_win_uptime","day1_total_fail_reason_cnt","device_id","lt_cnt","reg_pack","day1_total_game_uptime","day1_sub_game_cnt","reg_country","ad_game_sub_name","reg_local_time","day1_total_win_reason_cnt","reg_date","ad_id","day1_sub_game_fail_uptime","reg_local_date","day1_game_reason_cnt","test_label" FROM v_event_4 WHERE "$part_event"='og_gbt3_game_event' AND "$part_date"<='2026-01-14'
            ''' 
    return sql
def get_data():
    # DMG:5cv2wnXJ4bWrfhRsUMYyGcbaQETZBNqv0mVGpbIKYXAf01IsLDKbUj0MXZ5Y0pIu
    # OG:8z54SmsXpem11675yprE1HV7V7QAZckUSSPDTzN0m9uIJAibb4FX0SZ130cB1NTK
    # url = rf'''http://121.43.174.24:8992/querySql?token={token}'''
    token='8z54SmsXpem11675yprE1HV7V7QAZckUSSPDTzN0m9uIJAibb4FX0SZ130cB1NTK'
    url = rf'''https://ta-openapi.difeh.com:8992/querySql?token={token}'''
    format='csv_header'
    timeoutSeconds=30000      # 5min请求不到视作超时
    header = {"ContentType": "application/x-www-form-urlencoded"}
    data = {"sql": get_sql(),
            "format": format,
            "timeoutSecond": timeoutSeconds
            }
    response = requests.post(url, data=data)
    with open(r'sql.txt', 'w+', encoding='utf-8') as f:
        f.write(response.content.decode('utf-8'))
        f.close()
    data = pd.read_csv(r'sql.txt', sep=',', encoding='utf-8').fillna(0)
    return data
df = get_data()
df