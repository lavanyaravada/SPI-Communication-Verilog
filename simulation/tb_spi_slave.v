`timescale 1ns / 1ps

module tb_spi_slave;
    reg rst;
    reg sclk;
    reg cs_n;
    reg mosi;
    reg [7:0] tx_data;
    reg [7:0] master_data;
    wire miso;
    wire [7:0] rx_data;
    wire done;
    integer i;
// SPI SLAVE
    spi_slave dut (
        .rst     (rst),
        .sclk    (sclk),
        .cs_n    (cs_n),
        .mosi    (mosi),
        .miso    (miso),
        .tx_data (tx_data),
        .rx_data (rx_data),
        .done    (done)
    );
    // TEST
    initial begin
    // Initial values
        rst = 1'b1;
        sclk = 1'b0;
        cs_n = 1'b1;
        mosi = 1'b0;
   // Slave will transmit 3C
        tx_data = 8'h3C;
        // Master will transmit A5
        master_data = 8'hA5;
   // Reset
        #50;
        rst = 1'b0;
        #50;
   // Select slave
        cs_n = 1'b0;
   // Send A5 = 10100101
   // MSB first
        for (i = 7; i >= 0; i = i - 1) begin
            // Put data on MOSI
            mosi = master_data[i];
            // Give slave time to see the data
            #10;
            // Rising edge
            sclk = 1'b1;
            #10;
            // Falling edge
            sclk = 1'b0;
        end
   // Wait
        #20;
        // Deselect slave
        cs_n = 1'b1;
        #20;
   // Display result
        $display("--------------------------------------");
        $display("       SPI SLAVE SIMULATION");
        $display("--------------------------------------");
        $display("Master transmitted : %h", master_data);
        $display("Slave received     : %h", rx_data);
        $display("Slave transmitted  : %h", tx_data);
        $display("--------------------------------------");
  // Check result
        if (rx_data == master_data)
            $display("SLAVE RECEIVE : PASS");
        else
            $display("SLAVE RECEIVE : FAIL");
        $display("--------------------------------------");
        #100;
        $finish;
    end
endmodule
