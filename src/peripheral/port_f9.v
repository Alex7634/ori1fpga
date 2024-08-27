// Author: AlexG

module port_f9 (
  input        rst_i,
  input  [1:0] data_i,
  input        en_i,
  input        wr_i,
  output [1:0] mbank_o
);


reg [1:0] mbank_q;
wire      we_s;


assign we_s = (en_i & wr_i);

always @(negedge we_s or posedge rst_i)
begin
  if (rst_i)
    mbank_q <= 2'b00;
  else
    mbank_q <= data_i;
end

assign mbank_o = mbank_q;

endmodule
