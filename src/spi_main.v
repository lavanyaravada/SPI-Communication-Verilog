`timescale 1ns / 1ps

module spi_main #(
    parameter integer SPI_DIVIDER = 2
)(
    input wire        clk,
    input wire        rst,
    input wire        start,
    input wire [7:0]  master_tx_data,
    input wire [7:0]  slave_tx_data,
    output wire [7:0] master_rx_data,
    output wire [7:0] slave_rx_data,
    output wire       sclk,
    output wire       cs_n,
    output wire       mosi,
    output wire       miso,
    output wire       busy,
    output wire       done
);
    wire spi_tick;
    // Clock Divider
    clock_divider #(
        .DIVIDE(SPI_DIVIDER)
    ) u_clock_divider (
        .clk    (clk),
        .rst    (rst),
        .enable (busy),
        .tick   (spi_tick)
    );

    // SPI Master
    spi_master u_spi_master (
        .clk      (clk),
        .rst      (rst),
        .start    (start),
        .spi_tick (spi_tick),
        .tx_data  (master_tx_data),
        .miso     (miso),
        .sclk     (sclk),
        .cs_n     (cs_n),
        .mosi     (mosi),
        .rx_data  (master_rx_data),
        .busy     (busy),
        .done     (done)
    );

    // SPI Slave
    spi_slave u_spi_slave (
        .rst     (rst),
        .sclk    (sclk),
        .cs_n    (cs_n),
        .mosi    (mosi),
        .miso    (miso),
        .tx_data (slave_tx_data),
        .rx_data (slave_rx_data),
        .done    ()
    );
endmodule
