`timescale 1ns / 1ps

module uart_top_cmd_tb;

    // Parameters
    parameter OPERAND_WIDTH = 512;
    parameter ADDER_WIDTH = 32;
    parameter CLK_FREQ = 125_000_000;
    parameter BAUD_RATE = 115_200;
    parameter CLK_PERIOD = 8; // 125MHz -> 8ns period
    
    // Calculate the number of clock cycles per bit for the UART
    parameter CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
    parameter BIT_PERIOD = CYCLES_PER_BIT * CLK_PERIOD;
    
    // Testbench signals
    reg clk = 0;
    reg rst = 0;
    reg rx = 1;  // UART line idle is high
    wire tx;
    
    // Test data (command byte)
    reg [7:0] test_command = 8'hA5; // Example command
    
    // Instantiate the DUT (Device Under Test)
    uart_top #(
        .OPERAND_WIDTH(OPERAND_WIDTH),
        .ADDER_WIDTH(ADDER_WIDTH),
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .iClk(clk),
        .iRst(rst),
        .iRx(rx),
        .oTx(tx)
    );
    
    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Task for sending a byte via UART
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit (low)
            rx = 0;
            #BIT_PERIOD;
            
            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #BIT_PERIOD;
            end
            
            // Stop bit (high)
            rx = 1;
            #BIT_PERIOD;
        end
    endtask
    
    // Monitor the state and command register
    initial begin
        $monitor("Time: %t, FSM State: %h, Command Register: %h", 
                 $time, dut.rFSM, dut.rCMD);
    end
    
    // Test sequence
    initial begin
        // Initialize all inputs
        rx = 1;
        rst = 1;
        
        // Apply reset for a few clock cycles
        #(10 * CLK_PERIOD);
        rst = 0;
        #(10 * CLK_PERIOD);
        
        // Display test start
        $display("Starting UART Command Reception Test");
        $display("Sending Command Byte: %h", test_command);
        
        // Send the command byte
        send_uart_byte(test_command);
        
        // Wait for the FSM to process the byte
        #(20 * CLK_PERIOD);
        
        // Check if command was correctly received
        if (dut.rCMD == test_command)
            $display("SUCCESS: Command %h correctly received and stored", test_command);
        else
            $display("FAILURE: Expected command %h, got %h", test_command, dut.rCMD);
        
        // Wait for the FSM to move to the next state (should be s_RX1)
        #(10 * CLK_PERIOD);
        if (dut.rFSM == dut.s_RX1)
            $display("SUCCESS: FSM moved to s_RX1 state as expected");
        else
            $display("FAILURE: FSM did not transition to s_RX1, current state: %h", dut.rFSM);
            
        // Finish simulation
        #(50 * CLK_PERIOD);
        $display("Test completed");
        $finish;
    end
    
    // Optional: Create VCD file for waveform viewing
    initial begin
        $dumpfile("uart_cmd_test.vcd");
        $dumpvars(0, uart_top_cmd_tb);
    end

endmodule