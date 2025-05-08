`timescale 1ns / 1ps

module PFA_tb();
    // 定义信号
    reg iA;
    reg iB;
    reg iCarry;
    wire oP;
    wire oG;
    wire oSum;
    
    // 实例化被测试模块
    PFA uut (
        .iA(iA),
        .iB(iB),
        .iCarry(iCarry),
        .oP(oP),
        .oG(oG),
        .oSum(oSum)
    );
    
    // 初始化和监视过程
    initial begin
        // 初始化输入
        iA = 0;
        iB = 0;
        iCarry = 0;
        
        // 添加一些延迟，让信号稳定
        #10;
        
        // 定义一个简单的函数来显示当前状态
        $display("测试开始 - PFA模块");
        $display("时间\tiA\tiB\tiCarry\toP\toG\toSum");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, iA, iB, iCarry, oP, oG, oSum);
        
        // 测试所有可能的输入组合
        #10 iA = 0; iB = 0; iCarry = 0;
        #10 iA = 0; iB = 0; iCarry = 1;
        #10 iA = 0; iB = 1; iCarry = 0;
        #10 iA = 0; iB = 1; iCarry = 1;
        #10 iA = 1; iB = 0; iCarry = 0;
        #10 iA = 1; iB = 0; iCarry = 1;
        #10 iA = 1; iB = 1; iCarry = 0;
        #10 iA = 1; iB = 1; iCarry = 1;
        
        // 添加一些额外的延迟，以便观察最后一个结果
        #10;
        
        $display("测试完成");
        $finish;
    end
endmodule