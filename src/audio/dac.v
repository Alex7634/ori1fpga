// XAPP154 Virtex Synthesizable Delta-Sigma DAC

`define MSBI 7    // Most significant Bit of DAC input
 
// This is a Delta-Sigma Digital to Analog Converter
module dac (
  input            clk_i,
  input            rst_i,
  input  [`MSBI:0] dac_i, // DAC input (excess 2**MSBI)
  output           dac_o  // This is the average output that feeds low pass filter
);

reg [`MSBI+2:0] delta_adder_s;   // Output of Delta adder
reg [`MSBI+2:0] sigma_adder_s;   // Output of Sigma adder
reg [`MSBI+2:0] sigma_latch_q;   // Latches output of Sigma adder
reg [`MSBI+2:0] delta_b_s;       // B input of Delta adder
reg             dac_q;           // For optimum performance, ensure that this ff is in IOB
 
always @(sigma_latch_q) delta_b_s = {sigma_latch_q[`MSBI+2], sigma_latch_q[`MSBI+2]} << (`MSBI+1);
always @(dac_i, delta_b_s) delta_adder_s = dac_i + delta_b_s;
always @(delta_adder_s, sigma_latch_q) sigma_adder_s = delta_adder_s + sigma_latch_q;
 
always @(posedge clk_i, posedge rst_i)
begin
  if (rst_i) begin
    sigma_latch_q <= 1'b1 << (`MSBI+1);
    dac_q         <= 1'b0;
  end
  else begin
    sigma_latch_q <= sigma_adder_s;
    dac_q         <= sigma_latch_q[`MSBI+2];
  end
end

assign dac_o = dac_q;

endmodule
