# VHDL-Digital-Combination-Lock
Video: https://www.bilibili.com/video/BV1Tm4y1h7f2/  
This is a multi-functional clock design based on VHDL.  
It is developed on the NEXYS A7-T100 development board.  
It has a built-in four-digit password with two modes (BTNU, BTNC) to choose from, with BTNR designed as the confirmation key.   
It has a delay function, with the waiting time increasing by 2s for each incorrect input, and resetting to zero upon correct input.  
The status of the lock is displayed through LEDs.  
--Written in Birmingham, UK on 2023.04.08.  

这是一个基于VHDL的多功能时钟设计。  
基于NEXYS A7-T100开发板。  
内置四位数密码，有两种模式(BTNU、BTNC)可以选择，BTNR被设计为确认键。   
具有延时功能，每出错一次等待时长都会增加2s，输入正确即可清零。  
通过LED展示锁的状态。  
--写于英国伯明翰 2023.04.08
