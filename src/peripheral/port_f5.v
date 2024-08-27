// Author: AlexG

module port_f5 (
  input        rst_i,
  input  [1:0] addr_i,
  input  [7:0] data_i,
  output [7:0] data_o,
  input        cs_i,
  input        rd_i,
  input        wr_i,
  input  [7:0] port_ax_i,
  output [7:0] port_bx_o,
  output [7:0] port_cx_o
);


reg [7:0] bx_q;
reg [7:0] cx_q;
wire      re_s;
wire      we_s;


assign re_s = (cs_i & rd_i);
assign we_s = (cs_i & wr_i);

always @(negedge we_s or posedge rst_i)
begin
  if (rst_i) begin
    bx_q <= 8'h00;
    cx_q <= 8'h00;
  end
  else begin
    if (addr_i == 2'b01)
      bx_q <= data_i;
    else if (addr_i == 2'b10)
      cx_q <= data_i;
    else if (addr_i == 2'b11 & ~data_i[7])
      cx_q[data_i[3:1]] <= data_i[0];
  end
end

assign data_o = (re_s & addr_i == 2'b00) ? port_ax_i :
                (re_s & addr_i == 2'b01) ? bx_q      :
                (re_s & addr_i == 2'b10) ? cx_q      :
                8'hFF;

assign port_bx_o = bx_q;
assign port_cx_o = cx_q;

endmodule
