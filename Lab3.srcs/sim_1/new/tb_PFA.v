`timescale 1ns / 1ps

module PFA_tb();
    // �����ź�
    reg iA;
    reg iB;
    reg iCarry;
    wire oP;
    wire oG;
    wire oSum;
    
    // ʵ����������ģ��
    PFA uut (
        .iA(iA),
        .iB(iB),
        .iCarry(iCarry),
        .oP(oP),
        .oG(oG),
        .oSum(oSum)
    );
    
    // ��ʼ���ͼ��ӹ���
    initial begin
        // ��ʼ������
        iA = 0;
        iB = 0;
        iCarry = 0;
        
        // ���һЩ�ӳ٣����ź��ȶ�
        #10;
        
        // ����һ���򵥵ĺ�������ʾ��ǰ״̬
        $display("���Կ�ʼ - PFAģ��");
        $display("ʱ��\tiA\tiB\tiCarry\toP\toG\toSum");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, iA, iB, iCarry, oP, oG, oSum);
        
        // �������п��ܵ��������
        #10 iA = 0; iB = 0; iCarry = 0;
        #10 iA = 0; iB = 0; iCarry = 1;
        #10 iA = 0; iB = 1; iCarry = 0;
        #10 iA = 0; iB = 1; iCarry = 1;
        #10 iA = 1; iB = 0; iCarry = 0;
        #10 iA = 1; iB = 0; iCarry = 1;
        #10 iA = 1; iB = 1; iCarry = 0;
        #10 iA = 1; iB = 1; iCarry = 1;
        
        // ���һЩ������ӳ٣��Ա�۲����һ�����
        #10;
        
        $display("�������");
        $finish;
    end
endmodule