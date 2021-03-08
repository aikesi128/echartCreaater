//
//  ViewController.swift
//  test_mac
//
//  Created by zhujunwu on 2021/3/3.
//

import Cocoa
import SnapKit
 

class ViewController: NSViewController {

    var source: String? // 源地址
    var location: String? // 下载地址
    var promptLabel: NSTextField?
    var messageLabel: NSTextField?
    var progress: NSProgressIndicator?
    var openButton:  NSButton?
    
    var destinationPath: String?
    var tableNames: [String]?
    var fields: [String: [String]]?
    
    var pieButton:  NSButton?
    var lineButton:  NSButton?
    var isLineChart: Bool?
    
    var selectedTableName: String = ""
    var selectedFieldName: String = ""
    var fileDirectory: String = ""
    var xAxisFieldName: String? // 横轴使用字段
    var yAxisFieldName: String? // y轴使用字段

    override func viewDidLoad() {
        super.viewDidLoad()
        setup_createCharts()  
    }
    
    // 初始化图标相关控件
    func setup_createCharts()  {
        
        // button_打开数据库  是不是需要一个重置按钮呢
        let openButton = NSButton.init(title: "打开数据库..", target: self, action: #selector(openDatabaseClick))
        openButton.setButtonType(.momentaryPushIn)
        openButton.bezelStyle = .roundRect
        self.view.addSubview(openButton)
        openButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(40)
            make.top.equalTo(view).offset(40)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        // 提示文本框
        promptLabel = NSTextField.init(string: "")
        promptLabel?.wantsLayer = true
        promptLabel?.placeholderString = "请选择需要操作的数据库!"
        promptLabel?.isEditable = false
        promptLabel?.isBordered = false
        promptLabel?.font = NSFont.init(name: "Helvetica", size: 13)
        promptLabel?.backgroundColor = .clear
        promptLabel?.textColor = NSColor.red
        self.view.addSubview(promptLabel!)
        promptLabel?.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(30)
            make.bottom.equalTo(self.view).offset((-30))
            make.height.equalTo(27)
            make.width.equalTo(300)
        }
        
        
        lineButton = NSButton.init(title: "折线图", target: self, action: #selector(lineButtonClick))
        lineButton?.setButtonType(.momentaryChange)
        lineButton?.bezelStyle = .roundRect
        lineButton?.isHidden = true
        self.view.addSubview(lineButton!)
        lineButton!.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(40)
            make.top.equalTo(openButton.snp.bottom).offset(10)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        pieButton = NSButton.init(title: "饼图", target: self, action: #selector(pieButtonClick))
        pieButton?.setButtonType(.momentaryLight)
        pieButton?.bezelStyle = .roundRect
        pieButton?.isHidden = true
        self.view.addSubview(pieButton!)
        pieButton?.snp.makeConstraints { (make) in
            make.left.equalTo(lineButton!.snp.right).offset(10)
            make.top.equalTo(lineButton!)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        // let fileDirectory
        fileDirectory = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first?.appending("/parse_result"))!
        if !FileManager.default.fileExists(atPath: fileDirectory) {
            try! FileManager.default.createDirectory(atPath: fileDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
    }
     
    
    // MARK: button click
    // 打开数据库
    @objc func openDatabaseClick(){
        let pan = NSOpenPanel.init()
        pan.message = "选择数据库文件"
        pan.allowedFileTypes = ["db","sqlite"]
        pan.directoryURL = URL.init(string: "")
        pan.begin { (response) in
            if response == .OK{
                // 目标地址为pan.url, 处理后交给python去读写
                self.destinationPath = pan.url?.absoluteString.replacingOccurrences(of: "file://", with: "")
                self.promptLabel?.stringValue = "打开数据库成功, 请选择图标类型"
                self.pieButton?.isHidden = false
                self.lineButton?.isHidden = false
                
                // 查出所有的表名称和字段名称
                 self.runPython(arguments: "searchName")
                
            }else {
                self.promptLabel?.stringValue = "打开数据库失败"
            }
        }
    }
    
    
    // 点击折线图
    @objc func lineButtonClick()  {
//        self.isLineChart = true
//        lineButton?.isHidden = true
//        pieButton?.isHidden = true
//        self.promptLabel?.stringValue = "1. 请选择数据表中的相关字段作为x轴的数据"
//        self.showTableNames()
          self.promptLabel?.stringValue = "暂不支持生成折线图"
    }
    
    
    // 点击饼图
    @objc func pieButtonClick()  {
        self.isLineChart = false
        lineButton?.isHidden = true
        pieButton?.isHidden = true
        self.promptLabel?.stringValue = "请选择数据表"
        showTableNames()
    }
    
    // 点击表名
    @objc func tableNameButtonClick(button: NSButton){
        if self.isLineChart! {
            self.hideTableNames()
            self.selectedTableName = button.title
            self.showFields(tableName: selectedTableName)
            if self.xAxisFieldName == nil {
                // 第一次选择时间轴数据
            }else {
                // 第二次选择y轴数据
            }
        }else {
            // 饼图
            self.selectedTableName = button.title
            self.hideTableNames()
            self.promptLabel?.stringValue = "请继续选择字段"
            // 准备展示字段名
            self.showFields(tableName: selectedTableName)
        }
        
    }
    
    // 点击字段名称
    @objc func fieldNameButtonClick(button: NSButton){
        // 准备开始处理数据
        if isLineChart!{
            // 处理折线图
            if self.xAxisFieldName == nil {
                // 第一次选择时间轴数据
                self.xAxisFieldName = self.selectedTableName + "&" + button.title
                print(xAxisFieldName!)
                self.promptLabel?.stringValue = "2. 请继续选择相关字段作为y轴数据"
                self.hideFields()
                self.showTableNames()
            }else {
                // 第二次选择y轴数据
                self.yAxisFieldName = self.selectedTableName + "&" + button.title
                print(yAxisFieldName!)
                self.hideFields()
                
                // 准备生成数据
                self.promptLabel?.stringValue = "数据处理中........"
                self.runPython(arguments: "line")
            }
            
        }else {
            self.selectedFieldName = button.title
            self.hideFields()
            self.promptLabel?.stringValue = "数据处理中........"
            // 用户选择的是饼图, 准备传数据给python进行处理
            self.runPython(arguments:"pie", self.selectedTableName, self.selectedFieldName)
        }
        
    }
    
    // 展示所有的数据表名称
    func showTableNames() {
        let tabs = self.fields?.keys.sorted(by: <)
        let width = 120, height = 30
        for x in  0 ..< tabs!.count{
            let button = NSButton.init(title: tabs![x], target: self, action: #selector(tableNameButtonClick))
            button.setButtonType(.momentaryPushIn)
            button.tag = 100+x
            button.bezelStyle = .roundRect
            self.view.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.left.equalTo(self.view).offset(40 + (x % 4) * (width + 10))
                make.top.equalTo(lineButton!.snp.top).offset( (x/4) * (height + 5))
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
            print(x)
        }
    }
    
    
    // 隐藏所有的数据表名称
    func hideTableNames() {
        for x in self.view.subviews{
            if (x.tag >= 100 && x.tag < 200) {
                x.removeFromSuperview()
            }
        }
    }
    
    
    // 展示字段
    func showFields(tableName: String)  {
        let tabs = self.fields?[tableName]
        let width = 120, height = 30
        for x in  0 ..< tabs!.count{
            let button = NSButton.init(title: tabs![x], target: self, action: #selector(fieldNameButtonClick))
            button.setButtonType(.momentaryPushIn)
            button.tag = 300+x
            button.bezelStyle = .roundRect
            self.view.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.left.equalTo(self.view).offset(40 + (x % 4) * (width + 10))
                make.top.equalTo(lineButton!.snp.top).offset( (x/4) * (height + 5))
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
            print(x)
        }
    }
    
    // 隐藏字段
    func hideFields()  {
        for x in self.view.subviews{
            if (x.tag >= 300) {
                x.removeFromSuperview()
            }
        }
    }
    
    /// 执行python 命令
    /// - Parameter arguments: 第一个参数为python 执行类别
    /// 返回执行结果
    func runPython (arguments: String...) {
        
        let buildTask = Process()
        let outPip = Pipe()
        let errorPipe = Pipe()
        
        // 设置python解释器路径
        buildTask.launchPath = "/usr/local/bin/python3"
        buildTask.standardInput = Pipe()
        buildTask.standardOutput = outPip
        buildTask.standardError = errorPipe
        var path = ""
        if arguments.first == "searchName" {
            // 查询表名称
            path = Bundle.main.path(forResource: "search.py", ofType: nil)!
            buildTask.arguments = [path, self.destinationPath!]
        }else if arguments.first == "pie"{
            // 准备生成饼图
            path = Bundle.main.path(forResource: "pie.py", ofType: nil)!
            // 需要传递一个本地文件的参数
            let filepath = fileDirectory.appendingFormat("/%@_%@.json", self.selectedTableName,self.selectedFieldName)
            buildTask.arguments = [path, self.destinationPath!, arguments[1],arguments[2],filepath]
            print(filepath)
        }else if arguments.first == "line"{
            // 准备生成折线图
            path = Bundle.main.path(forResource: "line.py", ofType: nil)!
            // 需要传递一个本地文件的参数
            let x = self.xAxisFieldName!.split(separator: "&").last
            let y = self.yAxisFieldName!.split(separator: "&").last
            let filepath = fileDirectory + "/" + x! + "-" + y! + ".json"
            buildTask.arguments = [path, self.destinationPath!, self.xAxisFieldName!, self.yAxisFieldName!,filepath]
            print(filepath)
        }
        
        /*
            参数详解:
            buildTask.arguments = [path, self.destinationPath!, self.xAxisFieldName!, self.yAxisFieldName!,filepath]
         arguments的个参数为将要执行的.py文件的路径,  后边的地址可以是多个, 可以在python文件中通过sys.argv[num] 取值
         buildTask的输出output主要是接受python文件中的print出来的内容.  在python文件中可以直接将需要的东西直接写到文件中存在本地.
         */
       
        
        // 脚本执行完毕的回调
        buildTask.terminationHandler = {p in
            print("脚本执行完毕")
        }
        
        buildTask.launch()
        buildTask.waitUntilExit()
        let data = outPip.fileHandleForReading.readDataToEndOfFile()
        var output = String.init(data: data, encoding: .utf8)
        output = output!.replacingOccurrences(of: "\n", with: "")
        if arguments.first == "searchName"{
            self.promptLabel?.stringValue = "字段解析完毕"
            self.promptLabel?.stringValue = "请选择图标类型"
            self.fields = try? (JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : [String]])
        }else if arguments.first == "pie"{
            // 生成饼图
            if output!.count > 0 {
                let templatePath = Bundle.main.path(forResource: "template", ofType: "html")
                var html = try? String.init(contentsOf: URL.init(fileURLWithPath: templatePath!))
                html = html!.replacingOccurrences(of: "jsonfilepath", with: "'" + output!+"'")
                html = html?.replacingOccurrences(of: "titledescription", with: self.selectedTableName + "-" + self.selectedFieldName + "-数据分析")
                
                // 将html写进文件, 并且打开
                let htmlFilePath = output!.replacingOccurrences(of: "json", with: "html")
                try? html?.write(toFile: htmlFilePath, atomically: true, encoding: .utf8)
                self.promptLabel?.stringValue = "图表生成完毕"
                NSWorkspace.shared.openFile(htmlFilePath, withApplication: "Safari")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.lineButton?.isHidden = false
                    self.pieButton?.isHidden = false
                    self.promptLabel?.stringValue = "请继续选择"
                }
            }else {
                self.promptLabel?.stringValue = "图表生成失败, 建议重新启动应用"
            }
             
        }

        // 处理python错误
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorOutput = String.init(data: errorData, encoding: .utf8)
        if let aerror = errorOutput, aerror != "" {
            print("解析错误" + aerror)
        }
        
    }
     
    
    //MARK: button click
    
    @objc func openClick(){
        NSWorkspace.shared.selectFile(location, inFileViewerRootedAtPath: "")// 直接打开文件夹
    }
     
    
   
}

