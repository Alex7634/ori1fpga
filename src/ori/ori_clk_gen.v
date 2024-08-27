// Author: AlexG

module ori_clk_gen (
  input  clk_i,
  input  por_i,
  output cke_10m_o
);

reg cke_10m_q;


always @(negedge clk_i, posedge por_i)
begin
  if (por_i)
    cke_10m_q <= 1'b0;
  else
    cke_10m_q <= ~cke_10m_q;
end


// Output mapping
assign cke_10m_o = ~cke_10m_q;

endmodule
