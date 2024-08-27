// Author: AlexG

module ori_addr_mux (
  input         clk_i,
  input         cke_ras_n_i,
  input         acc_cpu_i,
  input  [ 1:0] mbank_i,
  input  [ 1:0] vpage_i,
  input         ram_upper_en_i,
  input  [ 5:0] num_col_i,
  input  [ 7:0] num_row_i,
  input  [15:0] cpu_addr_i,
  output [17:0] ram_addr_o
);

reg [15:0] ram_addr_q;
reg [ 1:0] ram_bank_q;


always @(posedge clk_i)
begin
  if (cke_ras_n_i) begin
    if (acc_cpu_i) begin
      ram_addr_q = cpu_addr_i;
      if (ram_upper_en_i)
        ram_bank_q = 2'b00;
      else
        ram_bank_q = mbank_i;
    end
    else begin
      ram_addr_q = {vpage_i, num_col_i, num_row_i};
      ram_bank_q = 2'b00;
    end
  end
end

// Output mapping
assign ram_addr_o = {ram_bank_q[1], ram_addr_q, ram_bank_q[0]};

endmodule
