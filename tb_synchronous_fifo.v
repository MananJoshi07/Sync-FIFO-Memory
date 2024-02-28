module tb_sync_fifo #(
  parameter integer DATA_WIDTH = 8,
  parameter integer FIFO_DEPTH = 16
) (
  input logic clk,
  input logic reset
);

  // DUT instance
  synchronous_fifo #(DATA_WIDTH, FIFO_DEPTH) dut (
    .clk(clk),
    .reset(reset),
    .write_en(write_en),
    .data_in(data_in),
    .read_en(read_en),
    .data_out(data_out),
    .full_flag(full_flag),
    .empty_flag(empty_flag)
  );

  // Internal signals
  logic write_en, read_en;
  logic [DATA_WIDTH-1:0] data_in;

  // function to generate random data
  function logic [DATA_WIDTH-1:0] generate_random_data;
    begin
      generate_random_data = $random;
    end
  endfunction

  // Task to write data to FIFO
  task write_to_fifo;
    input logic [DATA_WIDTH-1:0] data;
    begin
      // Wait for the FIFO to be !full
      while (full_flag) begin
        #1; // Delay for 1 clk cycle
      end

      // Write data and enable write signal
      write_en <= 1'b1;
      data_in <= data;
      @(posedge clk);

      // Reset write enable after 1 clk cycle
      #1;
      write_en <= 1'b0;
    end
  endtask

  // Task to read data from FIFO
  task read_from_fifo;
    output logic [DATA_WIDTH-1:0] data;
    begin
      // Wait for the FIFO to be !empty
      while (empty_flag) begin
        #1; // Delay for 1 clk cycle
      end

      // Enable read signal
      read_en <= 1'b1;
      @(posedge clk);

      // Capture read data
      data = data_out;

      // Reset read enable after 1 clk cycle
      #1;
      read_en <= 1'b0;
    end
  endtask

  // Test case logic
  initial begin
    // Initial reset
    reset <= 1'b1;
    @(posedge clk);
    reset <= 1'b0;

    // Write and read data in a loop
    for (int i = 0; i < 100; i++) begin
      write_to_fifo(generate_random_data()); // Write random data
      @(posedge clk);
      read_from_fifo(data_out); // Read data
      // Check if read data matches written data
      // if (data_out !== data_in) $display("Error: Data mismatch!");
    end

    // Stop simulation
    $finish;
  end

endmodule
