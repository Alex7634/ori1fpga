// Author: AlexG

module ori_hor_vert (
  input        clk_i,
  input        cke_10m_i,
  input        por_i,
  input        hor_inc_i, 
  output [5:0] cnt_hor_o,
  output       hsync_n_o,
  output       hblank_o,
  output [8:0] cnt_vert_o,
  output       vsync_n_o,
  output       vblank_o,
  output       blank_o
);

reg  [5:0] cnt_hor_q;
reg        hor_active_q;
reg        hsync_n_q, hblank_q, delay_hblank_q;
wire       ver_inc_s;
reg  [8:0] cnt_vert_q;
reg        vsync_n_q, vblank_q;


// 384x256p @ 50Hz
//
// H freq = 15.625 kHz       0,0000640 / 0,0000001 = 640
// V freq = 50.080 Hz
//
// H active        = 384
// H total         = 640
// H blank         = 256     0,0000256 / 0,0000001 = 256
// H sync width    =  32     0,0000032 / 0,0000001 = 32
// H right border  =  87
// H left border   = 137
//
// V active        = 256     0,016384000 / 0,0000640 = 256
// V total         = 312     0,019968000 / 0,0000640 = 312
// V blank         =  56     0,003584000 / 0,0000640 = 56
// V sync width    =   4
// V top border    =  24
// V bottom border =  28
//
// HStartPos       = 169
// VStartPos       =  28
//
// Pixcel Clock = (640 * 312 * 50.08012821) / 1000000 = 10.0000000009728 MHz
//                             50,080128205128205128205128205128
always @(posedge clk_i or posedge por_i)
begin
  if (por_i) begin
    cnt_hor_q    <= 6'd0;
    hor_active_q <= 1'b0;
    hsync_n_q    <= 1'b1;
    hblank_q     <= 1'b0;
    cnt_vert_q   <= 9'd0;
    vsync_n_q    <= 1'b1;
    vblank_q     <= 1'b0;
  end
  else begin
    if (cke_10m_i) begin
      // The horizontal counter
      if (hor_inc_i) begin
        if (cnt_hor_q == 6'd15 & hor_active_q) begin
          cnt_hor_q <= 6'd0;
          hor_active_q <= 1'b0;
        end
        else
          cnt_hor_q <= cnt_hor_q + 6'd1;
        if (cnt_hor_q == 6'd47)
          hor_active_q <= 1'b1;

        if (cnt_hor_q == 6'd59)
          hsync_n_q <= 1'b0;
        else if (cnt_hor_q == 6'd63)
          hsync_n_q <= 1'b1;

        if (cnt_hor_q == 6'd48)
          hblank_q <= 1'b1;
        else if (cnt_hor_q == 6'd0 & ~hor_active_q)
          hblank_q <= 1'b0;
      end
      // The vertical counter
      if (ver_inc_s) begin
        if (cnt_vert_q == 9'd311)
          cnt_vert_q <= 9'd0;
        else
          cnt_vert_q <= cnt_vert_q + 9'd1;

        if (cnt_vert_q == 9'd283)
          vsync_n_q <= 1'b0;
        else if (cnt_vert_q == 9'd287)
          vsync_n_q <= 1'b1;

        if (cnt_vert_q == 9'd255)
          vblank_q <= 1'b1;
        else if (cnt_vert_q == 9'd311)
          vblank_q <= 1'b0;
      end
    end
  end
end

assign ver_inc_s = hor_inc_i & cnt_hor_q == 6'd59;

always @(posedge clk_i)
begin
  if (cke_10m_i) delay_hblank_q <= hblank_q;
end

// Output mapping
assign cnt_hor_o  = cnt_hor_q;
assign hsync_n_o  = hsync_n_q;
assign hblank_o   = delay_hblank_q;
assign cnt_vert_o = cnt_vert_q;
assign vsync_n_o  = vsync_n_q;
assign vblank_o   = vblank_q;
assign blank_o    = hblank_o | vblank_o;

endmodule
