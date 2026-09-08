`timescale 1ns / 1ps

module spi_slave(
    input  wire       rst,
    input  wire       sclk,
    input  wire       cs_n,
    input  wire       mosi,
    output wire       miso,
    input  wire [7:0] tx_data,
    output reg  [7:0] rx_data,
    output reg        done
);
    reg [7:0] rx_shift;
    reg [2:0] bit_count;
    reg miso_reg;
  // MISO 
   // First bit is available immediately when CS goes LOW.
    // Remaining bits are updated on falling SCLK edges.
  
    assign miso = (!cs_n) ?
                  ((bit_count == 3'd0) ? tx_data[7] : miso_reg)
                  : 1'b0;
  // Receive data
   // SPI Mode 0:
    // Data is sampled on rising edge.
    always @(posedge sclk or posedge rst) begin
        if (rst) begin
            rx_shift  <= 8'd0;
            rx_data   <= 8'd0;
            bit_count <= 3'd0;
            done <= 1'b0;
        end
     else if (!cs_n) begin
         rx_shift <= {rx_shift[6:0], mosi};
        if (bit_count == 3'd7) begin
     // Complete 8-bit word
             rx_data <= {rx_shift[6:0], mosi};
                done <= 1'b1;
    // Prepare for next transaction
           bit_count <= 3'd0;
   end
    else begin
        bit_count <= bit_count + 1'b1;
            done <= 1'b0;
        end
     end
    else begin
            done <= 1'b0;
        end
    end
    // Transmit data
    // SPI Mode 0:
    // Data changes on falling edge.
    always @(negedge sclk or posedge rst) begin
        if (rst) begin
            miso_reg <= 1'b0;
        end
    else if (!cs_n) begin
            if (bit_count != 3'd0)
                miso_reg <= tx_data[7-bit_count];
            else
                miso_reg <= 1'b0;
        end
        else begin
            miso_reg <= 1'b0;
        end
    end

endmodule
