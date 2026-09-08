`timescale 1ns / 1ps

module tb_spi_master;
    reg clk;
    reg rst;
    reg start;
    reg [7:0] tx_data;
    reg [7:0] slave_tx_data;
    wire spi_tick;
    wire sclk;
    wire cs_n;
    wire mosi;
    wire miso;
    wire [7:0] master_rx_data;
    wire [7:0] slave_rx_data;
    wire busy;
    wire done;
    // Clock divider
    clock_divider #(
        .DIVIDE(2)
    ) divider_inst (
        .clk    (clk),
        .rst    (rst),
        .enable (busy),
        .tick   (spi_tick)
    );
    // Master
    spi_master master_inst (
        .clk      (clk),
        .rst      (rst),
        .start    (start),
        .spi_tick (spi_tick),
        .tx_data  (tx_data),
        .miso     (miso),
        .sclk     (sclk),
        .cs_n     (cs_n),
        .mosi     (mosi),
        .rx_data  (master_rx_data),
        .busy     (busy),
        .done     (done)
    );
    // Slave used as test partner
    spi_slave slave_inst (
        .rst     (rst),
        .sclk    (sclk),
        .cs_n    (cs_n),
        .mosi    (mosi),
        .miso    (miso),
        .tx_data (slave_tx_data),
        .rx_data (slave_rx_data),
        .done    ()
    );
    // 50 MHz clock
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    initial begin
        rst = 1'b1;
        start = 1'b0;
        tx_data       = 8'hA5;
        slave_tx_data = 8'h3C;
        #100;
        rst = 1'b0;
        #100;
        start = 1'b1;
        #20;
        start = 1'b0;
        wait(done);
        #20;
        $display("========== MASTER TEST ==========");
        $display("Master TX = %h", tx_data);
        $display("Master RX = %h", master_rx_data);
        $display("Slave RX  = %h", slave_rx_data);
        if (master_rx_data == slave_tx_data)
            $display("MASTER RECEIVE : PASS");
        else
            $display("MASTER RECEIVE : FAIL");
        if (slave_rx_data == tx_data)
            $display("MASTER TRANSMIT : PASS");
        else
            $display("MASTER TRANSMIT : FAIL");
        $display("=================================");
        #100;
        $finish;
    end
endmodule
