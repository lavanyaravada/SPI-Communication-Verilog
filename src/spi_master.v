`timescale 1ns / 1ps

module spi_master(
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire       spi_tick,
    input  wire [7:0] tx_data,
    input  wire       miso,
    output reg        sclk,
    output reg        cs_n,
    output reg        mosi,
    output reg [7:0]  rx_data,
    output reg        busy,
    output reg        done
);
    reg [7:0] tx_shift;
    reg [7:0] rx_shift;
    reg [3:0] bit_count;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sclk     <= 1'b0;
            cs_n     <= 1'b1;
            mosi     <= 1'b0;
            tx_shift <= 8'd0;
            rx_shift <= 8'd0;
            rx_data  <= 8'd0;
            bit_count <= 4'd0;
            busy <= 1'b0;
            done <= 1'b0;
    end
     else begin
        // done is a one-clock pulse
            done <= 1'b0;
       // Start a new SPI transaction
            if (!busy && start) begin
                busy      <= 1'b1;
                cs_n      <= 1'b0;
                sclk      <= 1'b0;
                tx_shift  <= tx_data;
                rx_shift  <= 8'd0;
                bit_count <= 4'd0;
       // First MSB is available before first rising edge
                mosi      <= tx_data[7];
      end
// SPI clock timing
    else if (busy && spi_tick) begin
        // Rising edge
       if (sclk == 1'b0) begin
           sclk <= 1'b1;
          // Sample MISO
       rx_shift <= {rx_shift[6:0], miso};
       bit_count <= bit_count + 1'b1;
    end
    // Falling edge
     else begin
        sclk <= 1'b0;
     // Eight bits completed
          if (bit_count == 4'd8) begin
               cs_n <= 1'b1;
                busy <= 1'b0;
                done <= 1'b1;
              rx_data <= rx_shift;
                mosi <= 1'b0;
    end
         else begin
           // Send next bit
             mosi <= tx_shift[6];
                // Shift transmit register
                     tx_shift <= {tx_shift[6:0], 1'b0};
                    end
                end
            end
        end
    end

endmodule
