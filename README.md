# VHDL-Digital-Combination-Lock
这是一个基于VHDL的多功能时钟设计。  
基于NEXYS A7-T100开发板。  
内置四位数密码，有两种模式(BTNU、BTNC)可以选择，BTNR被设计为确认键。   
具有延时功能，每出错一次等待时长都会增加2s，输入正确即可清零。  
通过LED展示锁的状态。  
