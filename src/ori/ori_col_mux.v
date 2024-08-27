// Author: AlexG

module ori_col_mux (
  input        clk_i,
  input        cke_10m_i,
  input        blank_i,
  input  [3:0] pix_col_i,
  output [3:0] rgb_r_o,
  output [3:0] rgb_g_o,
  output [3:0] rgb_b_o
);

reg [3:0] col_s;
reg [3:0] rgb_r_q, rgb_g_q, rgb_b_q;

always @*
begin
  if (~blank_i)
    col_s = pix_col_i;
  else
    col_s = 4'h0;
end

always @(posedge clk_i)
begin
  if (cke_10m_i) begin
    rgb_r_q <= {col_s[2], col_s[2], col_s[3], 1'b0};
    rgb_g_q <= {col_s[1], col_s[1], col_s[3], 1'b0};
    rgb_b_q <= {col_s[0], col_s[0], col_s[3], 1'b0};
  end
end

// Output mapping
assign rgb_r_o = rgb_r_q;
assign rgb_g_o = rgb_g_q;
assign rgb_b_o = rgb_b_q;

endmodule
