// Author: AlexG

module ori_pixel (
  input         clk_i,
  input         cke_10m_i,
  input         cke_pix_i,
  input         por_i,
  input  [ 2:0] vmode_i,
  input         acc_cpu_i,
  input  [15:0] ram_data_i,
  output [ 3:0] pix_col_o
);

reg [7:0] pix_shift_q, col_shift_q, col_pix_q;
reg [7:0] pix_tmp_q, col_tmp_q;
reg [3:0] dot_col_s;


always @(posedge clk_i or posedge por_i)
begin
  if (por_i) begin
    pix_shift_q <= 8'h00;
    col_shift_q <= 8'h00;
    col_pix_q   <= 8'h00;
    pix_tmp_q   <= 8'h00;
    col_tmp_q   <= 8'h00;
  end
  else begin
    if (cke_10m_i) begin
      pix_shift_q[7:1] <= pix_shift_q[6:0];
      col_shift_q[7:1] <= col_shift_q[6:0];
    end
    if (~acc_cpu_i) begin
      pix_tmp_q <= ram_data_i[ 7:0];
      col_tmp_q <= ram_data_i[15:8];
    end
    if (cke_pix_i) begin
      if (acc_cpu_i) begin
        pix_shift_q <= pix_tmp_q;
        col_shift_q <= col_tmp_q;
        col_pix_q   <= col_tmp_q;
      end
      else begin
        pix_shift_q <= ram_data_i[ 7:0];
        col_shift_q <= ram_data_i[15:8];
        col_pix_q   <= ram_data_i[15:8];
      end
    end
  end
end

always @*
begin
  case (vmode_i)
    // 2color pal1
    3'h0   : dot_col_s = pix_shift_q[7] ? 4'h2 : 4'h0;
    // 2color pal2
    3'h1   : dot_col_s = pix_shift_q[7] ? 4'he : 4'h9;
    // 4color pal1
    3'h4   : case ({pix_shift_q[7], col_shift_q[7]})
               2'b00: dot_col_s = 4'h0;
               2'b01: dot_col_s = 4'h4;
               2'b10: dot_col_s = 4'h2;
               2'b11: dot_col_s = 4'h1;
             endcase
    // 4color pal2
    3'h5   : case ({pix_shift_q[7], col_shift_q[7]})
               2'b00: dot_col_s = 4'h3;
               2'b01: dot_col_s = 4'h7;
               2'b10: dot_col_s = 4'h6;
               2'b11: dot_col_s = 4'h5;
             endcase
    // 16color
    3'h6,
    3'h7   : dot_col_s = pix_shift_q[7] ? col_pix_q[3:0] : col_pix_q[7:4];
    // blank
    default: dot_col_s = 4'h0;

  endcase
end

// Output Mapping
assign pix_col_o = dot_col_s;

endmodule
