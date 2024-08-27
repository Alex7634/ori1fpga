// Author: AlexG

module port_f8 (
  input        rst_i,
  input  [2:0] data_i,
  input        en_i,
  input        wr_i,
  output [2:0] vmode_o
);


reg [2:0] vmode_q;
wire      we_s;


assign we_s = (en_i & wr_i);

always @(negedge we_s or posedge rst_i)
begin
  if (rst_i)
    vmode_q <= 3'b000;
  else
    vmode_q <= data_i;
end

assign vmode_o = vmode_q;

endmodule
