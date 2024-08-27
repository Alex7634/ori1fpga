// Author: AlexG

module ori_cpu (
  input        clk_i,
  input        rst_i,
  input        cpu_f1_i,
  input        cpu_sync_i,
  input        cpu_dbin_i,
  input  [7:0] cpu_data_i,
  output       cpu_m1_o
);


reg       cpu_m1_q;

always @(posedge clk_i)
begin
  if (cpu_f1_i & cpu_sync_i)
    cpu_m1_q <= cpu_data_i[5];
  else if (cpu_f1_i & ~cpu_dbin_i)
    cpu_m1_q <= 1'b0;
end

// Output mapping
assign cpu_m1_o   = cpu_m1_q;

endmodule
