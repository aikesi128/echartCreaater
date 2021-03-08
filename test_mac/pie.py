import os
import sys
import json
import sqlite3
import time
import re



#def searchNames():
#    # 链接数据库
#    connect = sqlite3.connect(sys.argv[1])
#    cursor = connect.cursor()

#    # 查询所有表名称
#    cursor.execute("select name from sqlite_master where type='table'")
#    tab_name = cursor.fetchall()
#    tab_name = [line[0] for line in tab_name]
##    print(tab_name)
#    col_names=[]
#    col_dic={}
#    for line in tab_name:
#        cursor.execute('pragma table_info({})'.format(line))
#        col_name=cursor.fetchall()
#        col_name=[x[1] for x in col_name]
#        col_names.append(col_name)
#        col_dic[line] = col_name
#        col_name=tuple(col_name)
#
#    print(json.dumps(col_dic))



def calculatePie():
    # 链接数据库
    connect = sqlite3.connect(sys.argv[1])
    cursor = connect.cursor()
    sql = "select %s from %s" % (sys.argv[3],sys.argv[2])
#    print(sql)
    cursor.execute(sql)
    datas = {}
    for x in cursor:
        cellValue = str(x[0])
        if '?' in cellValue:
            cellValue = cellValue.split('?')[0]
        if 'http' in cellValue:
            cellValue = cellValue.replace('https://api.ergeapp.com/api/','')
            cellValue = re.sub(r'\d+','-',cellValue,300)
        if cellValue not in datas:
            value = {'name':cellValue,'value':1}
            datas[cellValue] = value
        else:
            value = datas[cellValue]
            value["value"]+=1


    option_model = {
        'title': {
            'text': ' ',
            'left': 'center'
        },
        'tooltip': {
            'trigger': 'item',
            'formatter': '{a} <br/>{b} : {c} ({d}%)'
        },
        'legend': {
        },
        'series': [
            {
                'name': sys.argv[3],
                'type': 'pie',
                'radius': '40%',
                'center': ['50%', '55%'],
                'data': list(datas.values()),
                'legend':{'type':'scroll','orient':'vertical','top':'-8px'},
                'emphasis': {
                    'itemStyle': {
                        'shadowBlur': 10,
                        'shadowOffsetX': 0,
                        'shadowColor': 'rgba(0, 0, 0, 0.5)'
                    }
                }
            }
        ]
    }
    
    # 写数据到本地
    pie_str = json.dumps(option_model)
    despath = sys.argv[4]
    f = open(despath,'w')
    f.write(pie_str)
    f.close()
    print(despath)
#    print('success')

if __name__ == '__main__':
    calculatePie()

    
