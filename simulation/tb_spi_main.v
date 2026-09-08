`timescale 1ns / 1ps

module tb_spi_main;
    reg clk;
    reg rst;
    reg start;
    reg [7:0] master_tx_data;
    reg [7:0] slave_tx_data;
    wire [7:0] master_rx_data;
    wire [7:0] slave_rx_data;
    wire sclk;
    wire cs_n;
    wire mosi;
    wire miso;
    wire busy;
    wire done;
// DUT
    spi_main #(
        .SPI_DIVIDER(2)
    ) dut (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .master_tx_data (master_tx_data),
        .slave_tx_data  (slave_tx_data),
        .master_rx_data (master_rx_data),
        .slave_rx_data  (slave_rx_data),
        .sclk           (sclk),
        .cs_n           (cs_n),
        .mosi           (mosi),
        .miso           (miso),
        .busy           (busy),
        .done           (done)
    );
    // 50 MHz clock
    // 20 ns period
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
  // Test
    initial begin
        rst = 1'b1;
        start = 1'b0;
        master_tx_data = 8'hA5;
        slave_tx_data  = 8'h3C;
        #100;
        rst = 1'b0;
        #100;
   // Start SPI transfer
        start = 1'b1;
        #20;
        start = 1'b0;
        // Wait for transaction completion
        wait(done);
        #20;
        $display("--------------------------------------");
        $display("       SPI SIMULATION RESULT");
        $display("--------------------------------------");

        $display("Master transmitted : %h", master_tx_data);
        $display("Slave received    : %h", slave_rx_data);

        $display("Slave transmitted  : %h", slave_tx_data);
        $display("Master received   : %h", master_rx_data);
        // Check results
        if (slave_rx_data == master_tx_data)
            $display("MASTER -> SLAVE : PASS");
        else
            $display("MASTER -> SLAVE : FAIL");
        if (master_rx_data == slave_tx_data)
            $display("SLAVE -> MASTER : PASS");
        else
            $display("SLAVE -> MASTER : FAIL");
        $display("--------------------------------------");
        #100;
        $finish;
    end
endmodule
