`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SHITTTT
// Engineer: 
// 
// Create Date: 2025/03/03 09:51:22
// Design Name: 
// Module Name: uart_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module uart_top #(
    parameter OPERAND_WIDTH   = 512,
    parameter ADDER_WIDTH     = 32,
    parameter   NBYTES        = OPERAND_WIDTH/8,
    // values for the UART (in case we want to change them)
    parameter   CLK_FREQ      = 125_000_000,
    parameter   BAUD_RATE     = 115_200
  )  
  (
    input   wire   iClk, iRst,
    input   wire   iRx,
    output  wire   oTx
  );
  
  // Buffer to exchange data between Pynq-Z2 and laptop
  reg [OPERAND_WIDTH-1:0] rBuffer;//can store 64 bytes
  reg [OPERAND_WIDTH-1:0] rA;//can store 64 bytes
  reg [OPERAND_WIDTH-1:0] rB;//can store 64 bytes
//  reg [NBYTES*8:0] wResult;//can store 64 bytes
  reg [OPERAND_WIDTH:0] rResult;//can store 64 bytes
  wire [OPERAND_WIDTH:0] wResult;//can store 64 bytes
  reg [OPERAND_WIDTH+7:0] rFinal;
  reg [7:0]             rCMD;
  
  // State definition  
  localparam s_IDLE         = 4'b0000;
  localparam s_RX1          = 4'b0001;
  localparam s_RX2          = 4'b0010;
  localparam s_TX           = 4'b0011;
  localparam s_WAIT_TX      = 4'b0100;
  localparam s_DONE         = 4'b0101;
  localparam s_CAL_START    = 4'b0110;
  localparam s_CAL          = 4'b0111;
  localparam s_CMD          = 4'b1000;
   
  // Declare all variables needed for the finite state machine 
  // -> the FSM state
  reg [3:0]   rFSM;  
  
  // Connection to UART TX (inputs = registers, outputs = wires)
  reg         rTxStart;
  reg         rRxDone;
  reg         rStart;
  reg [7:0]   rTxByte;
  wire[7:0]   wRxByte;
  
  wire        wTxBusy;
  wire        wTxDone;
  wire        wRxDone;
  wire        wDone;
      
  uart_tx #(  .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_TX_INST
    (.iClk(iClk),
     .iRst(iRst),
     .iTxStart(rTxStart),
     .iTxByte(rTxByte),
     .oTxSerial(oTx),
     .oTxBusy(wTxBusy),
     .oTxDone(wTxDone)
     );
     
  uart_rx #(  .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_RX_INST
  (.iClk(iClk),
   .iRst(iRst),
   .iRxSerial(iRx),
   .oRxByte(wRxByte),
   .oRxDone(wRxDone)
  );    
  
 mp_adder #(  .OPERAND_WIDTH(OPERAND_WIDTH),.ADDER_WIDTH(ADDER_WIDTH) )
 MP_ADDER_INST
 (
    .iClk(iClk),
    .iRst(iRst),
    .iCmd(rCmd),
    .iStart(rStart),
    .iOpA(rA),
    .iOpB(rB),
    .oRes(wResult),
    .oDone(wDone)
 );
  reg [$clog2(NBYTES+2):0] rCnt;

  
  always @(posedge iClk)
  begin
  // reset all registers upon reset
  if (iRst == 1 ) 
    begin
      rFSM <= s_IDLE;
      rTxStart <= 0;
      rCnt <= 0;
      rTxByte <= 0;
      rBuffer <= 0;
      rA <= 0;
      rB <= 0;
      rResult <= 0;
      rFinal <= 0;
      end 
  else 
    begin
      case (rFSM)
        s_IDLE :
            rFSM <= s_CMD;
            
        s_CMD:
        begin
        if(wRxDone==1)begin
            rCMD <= wRxByte;  // Read the 1 byte command
            rFSM <= s_RX1;
        end 
        else
            rFSM <= s_CMD;
        end
          
        s_RX1:
        begin
        if(rCnt<NBYTES)begin
            if(wRxDone==1)begin
                $display("Now rBit is still smaller than NBYTES which is %h!", rCnt);
                rBuffer <= {rBuffer[OPERAND_WIDTH-9:0], wRxByte};  // ? ֻ�� `wRxDone == 1` ʱд������
                rCnt <= rCnt + 1;
                rFSM <= s_RX1;
            end 
            else
                rFSM <= s_RX1;
        end
        else begin
                $display("Reach the boundary");
                rA <= rBuffer;
                rFSM <= s_RX2;
                rCnt <= 0;
                rBuffer <= 0;
        end
        end
        
        s_RX2:
        begin
        if(rCnt<NBYTES)begin
            if(wRxDone==1)begin
                $display("Now rBit is still smaller than NBYTES which is %h!", rCnt);
                rBuffer <= {rBuffer[OPERAND_WIDTH-9:0], wRxByte};  // ? ֻ�� `wRxDone == 1` ʱд������
                rCnt <= rCnt + 1;
                rFSM <= s_RX2;
            end 
            else
                rFSM <= s_RX2;
        end
        else begin
                $display("Reach the boundary");
                rB <= rBuffer;
                rFSM <= s_CAL_START;
                rCnt <= 0;
        end
        end
        
        s_CAL_START:
        begin
           rStart <= 1;
           rFSM <= s_CAL;
        end
        
        s_CAL:
        begin
            rResult <= wResult;
            rStart <= 0;
            if(wDone==1)begin
              rFinal <= {7'b0000000,wResult[OPERAND_WIDTH:0]};
              rFSM <= s_TX;
              rCnt <= 0;
            end 
            else
                rFSM <= s_CAL;
        end

             
        s_TX :
          begin
            if ( (rCnt < (NBYTES+1)) && (wTxBusy ==0) ) 
              begin
                rFSM <= s_WAIT_TX;
                rTxStart <= 1; 
                //for more bytes
                rTxByte <= rFinal[OPERAND_WIDTH+7:OPERAND_WIDTH];            // we send the uppermost byte
                rFinal <= {rFinal[OPERAND_WIDTH-1:0] , 8'b0000_0000};    // we shift from right to left
                rCnt <= rCnt + 1;
              end 
            else 
              begin
                rFSM <= s_DONE;
                rTxStart <= 0;
                rTxByte <= 0;
                rCnt <= 0;
              end
            end 
            
        s_WAIT_TX :
              begin
                if (wTxDone)
                  rFSM <= s_TX;
                else begin
                  rFSM <= s_WAIT_TX;
                  rTxStart <= 0;                   
                end
              end 
              
        s_DONE :
                rFSM <= s_IDLE;

        default :
              rFSM <= s_IDLE;
          endcase
      end
    end      
    
    
endmodule