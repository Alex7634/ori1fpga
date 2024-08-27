// Author: AlexG

module port_f4 (
  input        rst_i,
  input  [1:0] addr_i,
  input  [7:0] data_i,
  output [7:0] data_o,
  input        cs_i,
  input        rd_i,
  input        wr_i,
  output [7:0] port_ax_o,
  input  [7:0] port_bx_i,
  output [3:0] port_cl_o,
  input  [3:0] port_ch_i
);


reg [7:0] ax_q;
reg [3:0] cl_q;
wire      re_s;
wire      we_s;


assign re_s = (cs_i & rd_i);
assign we_s = (cs_i & wr_i);

always @(negedge we_s or posedge rst_i)
begin
  if (rst_i) begin
    ax_q <= 8'hFF;
    cl_q <= 4'hF;
  end
  else begin
    if (addr_i == 2'b00)
      ax_q <= data_i;
    else if (addr_i == 2'b10)
      cl_q <= data_i[3:0];
    else if (addr_i == 2'b11 & ~data_i[7])
      cl_q[data_i[2:1]] <= data_i[0];
  end
end

assign data_o = (re_s & addr_i == 2'b00) ? ax_q              :
                (re_s & addr_i == 2'b01) ? port_bx_i         :
                (re_s & addr_i == 2'b10) ? {port_ch_i, cl_q} :
                8'hFF;

assign port_ax_o = ax_q;
assign port_cl_o = cl_q;

endmodule
