`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2024 04:38:18 PM
// Design Name: 
// Module Name: Synchronous_fifo
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

module synchronous_fifo #(
  parameter integer DATA_WIDTH = 8,  // Width of data elements
  parameter integer FIFO_DEPTH = 16   // Depth of the FIFO (number of entries)
) (
  input                   clk,
  input                   reset,
  input                   write_en,
  input  [DATA_WIDTH-1:0] data_in,
  output                  read_en,
  output reg [DATA_WIDTH-1:0] data_out,
  output                  full_flag,
  output                  empty_flag);

  // Internal signals
  reg [FIFO_DEPTH-1:0] write_ptr;
  reg [FIFO_DEPTH-1:0] next_write_ptr;
  reg [FIFO_DEPTH-1:0] read_ptr, next_read_ptr;
  reg [DATA_WIDTH-1:0] memory [FIFO_DEPTH-1:0];

  // Calculate next write pointer
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      next_write_ptr <= {FIFO_DEPTH{1'b0}}; // Reset write pointer to 0
    end else begin
      next_write_ptr = write_ptr + write_en; // Increment if write enabled
    end
  end

  // Calculate next read pointer
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      next_read_ptr <= {FIFO_DEPTH{1'b0}}; // Reset read pointer to 0
    end else begin
      next_read_ptr = read_ptr + read_en; // Increment if read enabled
    end
  end

  // Update write and read pointers
  always @(posedge clk) begin
    write_ptr <= next_write_ptr;
    read_ptr <= next_read_ptr;
  end

  // Memory write logic
  always @(posedge clk) begin
    if (write_en & ~full_flag) begin
      memory[write_ptr] <= data_in;
    end
  end

  // Memory read logic
  always @(posedge clk) begin
    if (read_en & ~empty_flag) begin
      data_out <= memory[read_ptr];
    end
  end

  // Full flag logic
  assign full_flag = (next_write_ptr == read_ptr) & write_en & ~read_en;

  // Empty flag logic
  assign empty_flag = (write_ptr == read_ptr) & ~write_en & read_en;

endmodule
