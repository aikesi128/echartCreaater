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


# buildTask.arguments = [path, self.destinationPath!, self.xAxisFieldName!, self.yAxisFieldName!,filepath]
def calculateLine():
    # 链接数据库
    connect = sqlite3.connect(sys.argv[1])
    cursor = connect.cursor()
    
    # 计算axis数据
    tableName1 = sys.argv[2].split('&')[0]
    fieldName1 = sys.argv[2].split('&')[-1]
    
    tableName2 = sys.argv[3].split('&')[0]
    fieldName2 = sys.argv[3].split('&')[-1]
    
    sql = "select %s from %s" % (fieldName1,tableName1)
    cursor.execute(sql)
    dataList = []
    for x in cursor:
        cellValue = str(x[0])
        if cellValue not in dataList:
            dataList.append(cellValue)
            
    # 计算数据值
    sql = "select %s from %s" % (fieldName2,tableName2)
    cursor.execute(sql)
    valueList = []
    for x in cursor:
        valueList.append(cellValue)
    
    dataList = sorted(dataList)
    options = {}
    options['yAxis'] = {'type':'value'}
    options['textStyle'] = {'color':'#ccc'}
    options['xAxis'] = {'data':dateList}
    options['title'] = {'text':' ',
                'textStyle':{'color':"#FFF",'width':'100%','height':'40px',},
                'textAlign':'center',
                'left':'50%',
                'top':'10px'
               }
    options['series'] = [{'type':'line','name':fieldName1,'data':valueList,'smooth':True}]
    options['dataZoom'] = [{'type':'inside'}]
    options['legend'] = {'textStyle':{'color':'#aaa'},'type':'scroll','orient':'',
    'top': '-5px' ,'height':'40px',
    'data': sorted(maxTypeValues.keys())}
    options['tooltip'] = {'trigger': 'axis'}
   
    # 写数据到本地
    pie_str = json.dumps(option_model)
    despath = sys.argv[4]
    f = open(despath,'w')
    f.write(pie_str)
    f.close()
    print(despath)
#    print('success')

if __name__ == '__main__':
    calculateLine()

    
