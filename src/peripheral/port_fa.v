// Author: AlexG

module port_fa (
  input        rst_i,
  input  [1:0] data_i,
  input        en_i,
  input        wr_i,
  output [1:0] vpage_o
);


reg [1:0] vpage_q;
wire      we_s;


assign we_s = (en_i & wr_i);

always @(negedge we_s or posedge rst_i)
begin
  if (rst_i)
    vpage_q <= 2'b11;
  else
    vpage_q <= ~data_i;
end

assign vpage_o = vpage_q;

endmodule
