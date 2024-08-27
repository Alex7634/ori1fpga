// Author: AlexG

module ori_ctrl (
  input  clk_i,
  input  por_i,
  input  rst_i,
  input  cke_10m_i,
  input  cpu_sync_i,
  input  cpu_dbin_i,
  output cpu_f1_o,
  output cpu_f2_o,
  output hor_inc_o,
  output acc_cpu_o,
  output cke_pix_o,
  output ram_ce_o,
  output ram_oe_o,
  output cpu_ramw_o,
  output cke_ras_n_o
);

reg[3:0] cnt_q;
reg cpu_f1_q;
reg cpu_f2_q;
reg hor_inc_q;
reg acc_cpu_q;
wire cke_acc_s;
reg ram_ras_n_q, ram_cas_n_q;
reg ram_ce_q;
reg ram_oe_q;
reg ram_we_q;

// PHI1: XX------
// PHI2: -XXXXX--
always @(posedge clk_i or posedge por_i)
begin
  if (por_i) begin
    cnt_q     <= 4'd0;
    cpu_f1_q  <= 1'b1;
    cpu_f2_q  <= 1'b0;
    hor_inc_q <= 1'b0;
    ram_we_q  <= 1'b0;
  end  
  else begin
    cnt_q <= cnt_q + 4'd1;
    if (cnt_q[2:0] == 3'b111 | cnt_q[2:0] == 3'b000)
      cpu_f1_q <= 1'b1;
    else
      cpu_f1_q <= 1'b0; 
    if (~cnt_q[2] | cnt_q[2:0] == 3'b100)
      cpu_f2_q <= 1'b1;
    else
      cpu_f2_q <= 1'b0;

    if (cnt_q[3:0] == 4'b1101 | cnt_q[3:0] == 4'b1110)
      hor_inc_q <= 1'b1;
    else   
      hor_inc_q <= 1'b0;

  //if (cnt_q[2:0] == 3'b111 | cnt_q[2:1] == 2'b00 | cnt_q[2:0] == 3'b010)
  //  ram_ras_n_q <= 1'b1;
  //else
  //  ram_ras_n_q <= 1'b0;
  //if (cnt_q[2:0] == 3'b001 | cnt_q[2:1] == 2'b01 | cnt_q[2:0] == 3'b100)
  //  ram_cas_n_q <= 1'b1;
  //else
  //  ram_cas_n_q <= 1'b0;

    if (cnt_q[2:0] == 3'd3)
      ram_ce_q <= 1'b1;
    else if (cnt_q[2:0] == 3'd1)
      ram_ce_q <= 1'b0;

    if (cnt_q[2:0] == 3'd3 & acc_cpu_q & ~cpu_dbin_i)
      ram_we_q <= 1'b1;
    else if (cnt_q[2:0] == 3'd1)
      ram_we_q <= 1'b0;

  end
end

assign cke_acc_s = cke_10m_i & cnt_q[2:0] == 3'b001;
always @(posedge clk_i)
begin
  if (cke_acc_s) acc_cpu_q <= cpu_sync_i;
end

// Output mapping
assign cpu_f1_o    = cpu_f1_q;
assign cpu_f2_o    = cpu_f2_q;
assign hor_inc_o   = hor_inc_q;
assign acc_cpu_o   = acc_cpu_q;
assign cke_pix_o   = cke_10m_i & cnt_q[3:0] == 4'd1;
assign cke_ras_n_o = cke_10m_i & cnt_q[2:0] == 3'b011;
assign cpu_ramw_o  = ram_we_q;
assign ram_ce_o    = ram_ce_q;
assign ram_oe_o    = ~ram_we_q & ram_ce_q;

endmodule
