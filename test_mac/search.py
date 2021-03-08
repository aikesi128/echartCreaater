import os
import sys
import json
import sqlite3
import time
import re



def searchNames():
    # 链接数据库
    connect = sqlite3.connect(sys.argv[1])
    cursor = connect.cursor()

    # 查询所有表名称 以及生成所有字段
    cursor.execute("select name from sqlite_master where type='table'")
    tab_name = cursor.fetchall()
    tab_name = [line[0] for line in tab_name]
#    print(tab_name)
    col_names=[]
    col_dic={}
    for line in tab_name:
        cursor.execute('pragma table_info({})'.format(line))
        col_name=cursor.fetchall()
        col_name=[x[1] for x in col_name]
        col_names.append(col_name)
        col_dic[line] = col_name
        col_name=tuple(col_name)
            
    print(json.dumps(col_dic))



if __name__ == '__main__':
    searchNames()

    
