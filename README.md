# FileTransfer
在iPhone和电脑之间进行文件传输文件

##使用方法：
把HttpServer和ASProgressPopUpView文件夹加入项目工程
##说明：
[cocoa-web-resource](https://github.com/robin/cocoa-web-resource)已经完成了所有的工作，我只是在上面加了一个progressView，然后把适配的过程总结一下

##需要修改：
1. 设置HttpServer文件下所有文件都为非arc -fno-objc-arc
          
2. docroot为folder引用
          
3. link binary with libraries里添加cfnetwork、coregraphics、libicucore.a.tbd库
          
##效果图
![](https://github.com/luzefeng/FileTransfer/blob/master/Simulator%20Screen%20Shot%202016%E5%B9%B42%E6%9C%8821%E6%97%A5%20%E4%B8%8B%E5%8D%889.22.56.png)
