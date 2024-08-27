// Author: AlexG

module orion (
  input         clk_i,
  input         por_i,
  input         rst_i,
  // IPL
//output [11:0] iplrom_addr_o,
//input  [ 7:0] iplrom_data_i,
  // MONITOR
  output [10:0] monitor_addr_o,
  input  [ 7:0] monitor_data_i,
  // ROM disk
  output [15:0] romdsk_addr_o,
  input  [ 7:0] romdsk_data_i,
  // RAM
  output [17:0] ram_addr_o,
  input  [15:0] ram_data_di_i,
  output [ 7:0] ram_data_do_o,
  output        ram_we_o,
  output        ram_oe_o,
  output        ram_ce_o,
  // PS2
  input         ps2_clk_i,
  input         ps2_data_i,
  // SD CARD
  output        spi_cs_n_o,
  output        spi_sclk_o,
  output        spi_mosi_o,
  input         spi_miso_i,
  // RGB
  output        hsync_n_o,
  output        vsync_n_o,
  output [3:0]  rgb_r_o,
  output [3:0]  rgb_g_o,
  output [3:0]  rgb_b_o,
  // AUDIO
  output        beep_o,
  // LEDS
  output        led0_n_o,
  output        led1_n_o
);

  // Clocks
  wire cpu_f1_s, cpu_f2_s;
  wire cpu_rst_i = rst_i;

  // IPL (initial program load)
  reg         ipl_en_q;
  wire        ipl_en_s;

  // ROM
  wire        rom_en_s;
  wire        rom_re_s;

  // RAM
  wire [17:0] ram_addr_s;
  wire        ram_upper_en_s;
  wire        ram_ldata_en_s;
  wire        ram_ldata_wr_s;
  wire        ram_udata_en_s;
  wire        ram_udata_wr_s;
  wire        ram_ce_s;
  wire        ram_oe_s;
  wire        ram_we_s;

  // CPU
  wire [15:0] cpu_addr_s;
  wire [ 7:0] cpu_do_s;
  wire [ 7:0] cpu_di_s;
  wire        cpu_sync_s;
  wire        cpu_dbin_s;
  wire        cpu_wr_n_s;
  wire        cpu_wr_s = ~cpu_wr_n_s;
  wire        cpu_inte_s;
  wire        cpu_m1_s;
  wire        cpu_ramw_s;

  // Port F4
  wire [ 7:0] pf4_do_s;
  wire        pf4_en_s;
  wire [ 3:0] pf4_cl_s;
  wire [ 3:0] pf4_ch_s;

  // Port F5
  wire [ 7:0] pf5_do_s;
  wire        pf5_en_s;
  wire [15:0] romdsk_addr_s;

  // Port F7
  wire        pf7_en_s;

  // Port F8
  wire        pf8_en_s;
  wire [ 2:0] pf8_vmode_s;

  // Port F9
  wire        pf9_en_s;
  wire [ 1:0] pf9_mbank_s;

  // Port FA
  wire        pfa_en_s;
  wire [ 1:0] pfa_vpage_s;

  // Keyboard
  wire [ 7:0] keyb_addr_s;
  wire [ 7:0] keyb_do_s;
  wire        key_shft_s;
  wire        key_ctrl_s;
  wire        key_alt_s;

  // SD CARD
  wire [ 7:0] spi_do_s;
  wire        spi_en_s;
  wire [ 2:0] spi_cs_n_s;

  // CPU
  vm80a_core cpu (
    .pin_clk        (clk_i),
    .pin_f1         (cpu_f1_s),
    .pin_f2         (cpu_f2_s),
    .pin_reset      (cpu_rst_i),
    .pin_a          (cpu_addr_s),
    .pin_dout       (cpu_do_s),
    .pin_din        (cpu_di_s),
    .pin_hold       (1'b0),
    .pin_ready      (1'b1),
    .pin_int        (1'b0),
    .pin_wr_n       (cpu_wr_n_s),
    .pin_dbin       (cpu_dbin_s),
    .pin_inte       (cpu_inte_s),
    .pin_sync       (cpu_sync_s),
    .pin_aena       (),
    .pin_dena       (),
    .pin_hlda       (),
    .pin_wait       ()
  );

  ori_core ori (
    // Global Interface
    .clk_i          (clk_i),
    .por_i          (por_i),
    .rst_i          (rst_i),
    .vmode_i        (pf8_vmode_s),
    .mbank_i        (pf9_mbank_s),
    .vpage_i        (pfa_vpage_s),
    .ram_upper_en_i (ram_upper_en_s),
    // CPU Interface
    .cpu_f1_o       (cpu_f1_s),
    .cpu_f2_o       (cpu_f2_s),
    .cpu_addr_i     (cpu_addr_s),
    .cpu_data_i     (cpu_do_s),
    .cpu_sync_i     (cpu_sync_s),
    .cpu_dbin_i     (cpu_dbin_s),
    .cpu_m1_o       (cpu_m1_s),
    .cpu_ramw_o     (cpu_ramw_s),
    // RAM Interface
    .ram_addr_o     (ram_addr_s),
    .ram_data_i     (ram_data_di_i),
    .ram_ce_o       (ram_ce_s),
    .ram_oe_o       (ram_oe_s),
    // RGB Video Interface
    .rgb_hsync_n_o  (hsync_n_o),
    .rgb_vsync_n_o  (vsync_n_o),
    .rgb_r_o        (rgb_r_o),
    .rgb_g_o        (rgb_g_o),
    .rgb_b_o        (rgb_b_o)
  );

  port_f8 pf8 (
    .rst_i          (rst_i),
    .data_i         (cpu_do_s[2:0]),
    .en_i           (pf8_en_s),
    .wr_i           (cpu_wr_s),
    .vmode_o        (pf8_vmode_s)
  );

  port_f9 pf9 (
    .rst_i          (rst_i),
    .data_i         (cpu_do_s[1:0]),
    .en_i           (pf9_en_s),
    .wr_i           (cpu_wr_s),
    .mbank_o        (pf9_mbank_s)
  );

  port_fa pfa (
    .rst_i          (rst_i),
    .data_i         (cpu_do_s[1:0]),
    .en_i           (pfa_en_s),
    .wr_i           (cpu_wr_s),
    .vpage_o        (pfa_vpage_s)
  );

  port_f4 pf4 (
    .rst_i          (rst_i),
    .addr_i         (cpu_addr_s[1:0]),
    .data_i         (cpu_do_s),
    .data_o         (pf4_do_s),
    .cs_i           (pf4_en_s),
    .rd_i           (cpu_dbin_s),
    .wr_i           (cpu_wr_s),
    .port_ax_o      (keyb_addr_s),
    .port_bx_i      (keyb_do_s),
    .port_cl_o      (pf4_cl_s),
    .port_ch_i      (pf4_ch_s)
  );
  assign pf4_ch_s = {key_alt_s, key_ctrl_s, key_shft_s, 1'b1};
  assign led1_n_o   = ~pf4_cl_s[3]; // led rus/lat

  keyboard keyb (
    .clk_i          (clk_i),
    .rst_i          (por_i),
    .addr_i         (keyb_addr_s),
    .data_o         (keyb_do_s),
    .key_shft_o     (key_shft_s),
    .key_ctrl_o     (key_ctrl_s),
    .key_alt_o      (key_alt_s),
    // PS/2 interface
    .ps2_clk_i      (ps2_clk_i),
    .ps2_data_i     (ps2_data_i)
  );

  port_f5 pf5 (
    .rst_i          (rst_i),
    .addr_i         (cpu_addr_s[1:0]),
    .data_i         (cpu_do_s),
    .data_o         (pf5_do_s),
    .cs_i           (pf5_en_s),
    .rd_i           (cpu_dbin_s),
    .wr_i           (cpu_wr_s),
    .port_ax_i      (romdsk_data_i),
    .port_bx_o      (romdsk_addr_s[ 7:0]),
    .port_cx_o      (romdsk_addr_s[15:8])
  );

  spi sd (
    .clock_i        (clk_i),
    .reset_i        (rst_i),
    .addr_i         (cpu_addr_s[0]),
    .cs_i           (spi_en_s),
    .wr_i           (cpu_wr_s),
    .rd_i           (cpu_dbin_s),
    .data_i         (cpu_do_s),
    .data_o         (spi_do_s),
    .has_data_o     (),
    // SD card interface
    .spi_cs_n_o     (spi_cs_n_s),
    .spi_sclk_o     (spi_sclk_o),
    .spi_mosi_o     (spi_mosi_o),
    .spi_miso_i     (spi_miso_i),
    .sd_wp_i        (1'b0),
    .sd_pres_n_i    (1'b0)
  );
  assign spi_cs_n_o = spi_cs_n_s[0];
  assign led0_n_o   = spi_cs_n_s[0];

  // IPL
  always @(posedge clk_i or posedge rst_i)
  begin
    if (rst_i)
      ipl_en_q <= 1'b1;
    else if (cpu_addr_s[15:11] == 5'b11111 & cpu_m1_s)
      ipl_en_q <= 1'b0;
  end
  assign ipl_en_s = ipl_en_q;

  // Address decoding
  assign rom_en_s       = cpu_addr_s[15:11] == 5'b11111 | ipl_en_s;    // F800-FFFF
  assign ram_upper_en_s = cpu_addr_s[15:11] == 5'b11110;               // F000-F7FF
  assign pf4_en_s       = cpu_addr_s[15: 8] == 8'b11110100;            // F400-F4FF
  assign pf5_en_s       = cpu_addr_s[15: 8] == 8'b11110101;            // F500-F5FF
  //     pf6_en_s                                 11110110             // F600-F6FF
  assign pf7_en_s       = cpu_addr_s[15: 8] == 8'b11110111;            // F700-F7FF
  assign pf8_en_s       = cpu_addr_s[15: 8] == 8'b11111000;            // F800-F8FF
  assign pf9_en_s       = cpu_addr_s[15: 8] == 8'b11111001;            // F900-F9FF
  assign pfa_en_s       = cpu_addr_s[15: 8] == 8'b11111010;            // FA00-FAFF
  //     pfb_en_s                                 11111011             // FB00-FBFF
  assign ram_ldata_en_s = cpu_addr_s[15:12] != 4'b1111 & pf9_mbank_s[0] == 1'b0;  // 00000-0EFFF
  assign ram_udata_en_s = cpu_addr_s[15:12] != 4'b1111 & pf9_mbank_s[0] == 1'b1;  // 10000-1EFFF
  assign spi_en_s       = cpu_addr_s[ 7: 1] == 7'b0110000 & pf7_en_s;             // F760-F761

  // Read/Write logic
  assign rom_re_s       = cpu_dbin_s & rom_en_s;
  assign ram_ldata_wr_s = cpu_ramw_s & (ram_ldata_en_s | ram_upper_en_s);
  assign ram_udata_wr_s = cpu_ramw_s &  ram_udata_en_s;

  // MUX data CPU
  assign cpu_di_s = rom_re_s                    ? monitor_data_i      :
                    pf4_en_s                    ? pf4_do_s            :
                    pf5_en_s                    ? pf5_do_s            :
                    spi_en_s                    ? spi_do_s            :
                    cpu_dbin_s & ram_upper_en_s ? ram_data_di_i[ 7:0] :
                    cpu_dbin_s & ram_ldata_en_s ? ram_data_di_i[ 7:0] :
                    cpu_dbin_s & ram_udata_en_s ? ram_data_di_i[15:8] :
                    8'hFF;

  // Output mapping
  assign monitor_addr_o = cpu_addr_s[10:0];
  assign romdsk_addr_o  = romdsk_addr_s;
  assign ram_addr_o     = ram_addr_s;
  assign ram_data_do_o  = cpu_do_s;
  assign ram_we_o       = ram_ldata_wr_s | ram_udata_wr_s;
  assign ram_oe_o       = ram_oe_s;
  assign ram_ce_o       = ram_ce_s;
  assign beep_o         = cpu_inte_s;

endmodule
