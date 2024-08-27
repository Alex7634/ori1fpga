// Author: AlexG

module ori_core (
  // Global Interface
  input         clk_i,
  input         por_i,
  input         rst_i,
  input  [ 2:0] vmode_i,
  input  [ 1:0] mbank_i,
  input  [ 1:0] vpage_i,
  input         ram_upper_en_i,
  // CPU Interface
  output        cpu_f1_o,
  output        cpu_f2_o,
  input  [15:0] cpu_addr_i,
  input  [ 7:0] cpu_data_i,
  input         cpu_sync_i,
  input         cpu_dbin_i,
  output        cpu_m1_o,
  output        cpu_ramw_o,
  // RAM Interface
  output [17:0] ram_addr_o,
  input  [15:0] ram_data_i,
  output        ram_ce_o,
  output        ram_oe_o,
  // RGB Video Interface
  output        rgb_hsync_n_o,
  output        rgb_vsync_n_o,
  output [ 3:0] rgb_r_o,
  output [ 3:0] rgb_g_o,
  output [ 3:0] rgb_b_o
);


wire cke_10m_s;

wire cpu_f1_s, cpu_f2_s;
wire cpu_m1_s;
wire cpu_ramw_s;

wire hor_inc_s;
wire[5:0] cnt_hor_s;
wire hsync_n_s, hblank_s;
wire[8:0] cnt_vert_s;
wire vsync_n_s, vblank_s;
wire blank_s;
wire [3:0] pix_col_s;
wire [3:0] rgb_r_s, rgb_g_s, rgb_b_s;

wire acc_cpu_s;
wire cke_pix_s;

wire cke_ras_n_s;
wire[17:0] ram_addr_s;
wire ram_ce_s;
wire ram_oe_s;


// Clock Generator
ori_clk_gen clk_gen (
  .clk_i          (clk_i),
  .por_i          (por_i),
  .cke_10m_o      (cke_10m_s)
);

// Horizontal and Vertical Timing Generator
ori_hor_vert hor_vert (
  .clk_i          (clk_i),
  .cke_10m_i      (cke_10m_s),
  .por_i          (por_i),
  .hor_inc_i      (hor_inc_s),
  .cnt_hor_o      (cnt_hor_s),
  .hsync_n_o      (hsync_n_s),
  .hblank_o       (hblank_s),
  .cnt_vert_o     (cnt_vert_s),
  .vsync_n_o      (vsync_n_s),
  .vblank_o       (vblank_s),
  .blank_o        (blank_s)
);

// Control Module
ori_ctrl ctrl (
  .clk_i          (clk_i),
  .por_i          (por_i),
  .rst_i          (rst_i),
  .cke_10m_i      (cke_10m_s),
  .cpu_sync_i     (cpu_sync_i),
  .cpu_dbin_i     (cpu_dbin_i),
  .cpu_f1_o       (cpu_f1_s),
  .cpu_f2_o       (cpu_f2_s),
  .hor_inc_o      (hor_inc_s),
  .acc_cpu_o      (acc_cpu_s),
  .cke_pix_o      (cke_pix_s),
  .ram_ce_o       (ram_ce_s),
  .ram_oe_o       (ram_oe_s),
  .cpu_ramw_o     (cpu_ramw_s),
  .cke_ras_n_o    (cke_ras_n_s)
);

// CPU Module
ori_cpu cpu (
  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .cpu_f1_i       (cpu_f1_s),
  .cpu_sync_i     (cpu_sync_i),
  .cpu_dbin_i     (cpu_dbin_i),
  .cpu_data_i     (cpu_data_i),
  .cpu_m1_o       (cpu_m1_s)
);

// RAM Address Multiplexer
ori_addr_mux addr_mux (
  .clk_i          (clk_i),
  .cke_ras_n_i    (cke_ras_n_s),
  .acc_cpu_i      (acc_cpu_s),
  .mbank_i        (mbank_i),
  .vpage_i        (vpage_i),
  .ram_upper_en_i (ram_upper_en_i),
  .num_col_i      (cnt_hor_s),
  .num_row_i      (cnt_vert_s[7:0]),
  .cpu_addr_i     (cpu_addr_i),
  .ram_addr_o     (ram_addr_s)
);

// Pixel Generator
ori_pixel pixel (
  .clk_i          (clk_i),
  .cke_10m_i      (cke_10m_s),
  .cke_pix_i      (cke_pix_s),
  .por_i          (por_i),
  .vmode_i        (vmode_i),
  .acc_cpu_i      (acc_cpu_s),
  .ram_data_i     (ram_data_i),
  .pix_col_o      (pix_col_s)
);

// Color Multiplexer
ori_col_mux col_mux (
  .clk_i          (clk_i),
  .cke_10m_i      (cke_10m_s),
  .blank_i        (blank_s),
  .pix_col_i      (pix_col_s),
  .rgb_r_o        (rgb_r_s),
  .rgb_g_o        (rgb_g_s),
  .rgb_b_o        (rgb_b_s)
);


// Output mapping
assign cpu_f1_o   = cpu_f1_s;
assign cpu_f2_o   = cpu_f2_s;
assign cpu_m1_o   = cpu_m1_s;
assign cpu_ramw_o = cpu_ramw_s;

assign rgb_hsync_n_o = hsync_n_s;
assign rgb_vsync_n_o = vsync_n_s;
assign rgb_r_o       = rgb_r_s;
assign rgb_g_o       = rgb_g_s;
assign rgb_b_o       = rgb_b_s;

assign ram_addr_o = ram_addr_s;
assign ram_ce_o   = ram_ce_s;
assign ram_oe_o   = ram_oe_s;

endmodule
