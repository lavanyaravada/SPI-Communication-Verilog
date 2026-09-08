`timescale 1ns / 1ps

module clock_divider #(
    parameter integer DIVIDE = 250
)(
    input  wire clk,
    input  wire rst,
    input  wire enable,
    output reg  tick
);
    reg [31:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 32'd0;
            tick  <= 1'b0;
        end
        else if (!enable) begin
            count <= 32'd0;
            tick  <= 1'b0;
        end
        else begin
            if (count == DIVIDE-1) begin
                count <= 32'd0;
                tick  <= 1'b1;
            end
            else begin
                count <= count + 1'b1;
                tick  <= 1'b0;
            end
        end
    end
endmodule
