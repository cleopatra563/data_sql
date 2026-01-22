import requests
import pandas as pd
from datetime import date, timedelta
import os
# import schedule
import time
import dataframe_image as dfi
import base64
import json
# from requests_toolbelt import MultipartEncoder
pd.options.display.float_format = '{:.0f}'.format
import pymysql
# from sqlalchemy import create_engine
import warnings
warnings.filterwarnings('ignore')
db_config = {
    'host': 'gz-cdb-d488s76r.sql.tencentcdb.com',  # 外网地址
    'port': 21643,  # 外网端口
    'user': 'root',
    'password': 'Yh353568!',
    'database': 'zhuguang_cmge',
    'charset': 'utf8mb4',
    'connect_timeout': 10
}
def get_sqldata(sql):
    """
    执行SQL查询并返回DataFrame
    :param sql: SQL查询语句
    :return: pandas DataFrame
    """
    conn = None
    try:
        # 创建连接
        conn = pymysql.connect(**db_config)
        # 使用pandas直接读取SQL查询结果
        df = pd.read_sql(sql, conn)
        print(f"成功查询到 {len(df)} 条数据")
        return df
    except Exception as e:
        # 这里处理报错，打印错误信息
        print(f"查询出错: {e}")
        return None
    finally:
        # 无论成功还是失败，最后都要关闭数据库连接，防止连接泄露
        if conn:
            conn.close()
get_sqldata("""show tables""")
get_sqldata("""select * from HK_IOS_RANK order by date desc""")